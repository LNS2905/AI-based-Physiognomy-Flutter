# HistoryProvider Crash Fix - "Used after being disposed"

## Vấn đề
App crash với lỗi "A HistoryProvider was used after being disposed" khi:
- User click button "Gặp Chatbot" sau khi xem lá số tử vi
- Message thứ 2 từ AI chatbot được gửi (sau khi phân tích lá số)
- **CHỈ xảy ra trên thiết bị thật, KHÔNG xảy ra trên giả lập**

## Nguyên nhân

### Race Condition trong Async Operations
Lỗi xảy ra do **race condition** trong lifecycle của HistoryProvider:

1. User click "Gặp Chatbot" 
   - → Tạo conversation 
   - → Navigate đến `/ai-conversation`
   
2. ChatProvider tự động gửi message phân tích lá số (async operation)
   
3. **TRONG LÚC** async operation đang chạy:
   - Navigation xảy ra
   - Widget tree cũ bị dispose
   - HistoryProvider có thể bị dispose (nếu không còn widget nào dùng)
   
4. **SAU ĐÓ** async operation hoàn thành:
   - Code cố gọi `notifyListeners()` 
   - → **CRASH** vì provider đã disposed

### Tại sao chỉ xảy ra trên thiết bị thật?
- **Thiết bị thật chậm hơn** → async operation kéo dài hơn → cơ hội cao hơn để provider bị dispose giữa chừng
- **Giả lập nhanh** → async hoàn thành trước khi dispose → không crash

### Root Cause trong Code

Trong `HistoryProvider`, các async methods được gọi fire-and-forget:

```dart
// BAD: Fire-and-forget async - không check disposed sau await
void _onAuthStateChanged() {
  if (_authProvider.isAuthenticated && !_hasInitialized) {
    _initializeHistory(); // ⚠️ Async nhưng không await, không check disposed
  }
}

Future<void> _initializeHistory() async {
  if (!_historyDisposed) {  // ✅ Check trước
    await loadHistory();   // ⚠️ Async operation
    AppLogger.info('...');  // ❌ KHÔNG check disposed sau await
  }
}
```

Khi `loadHistory()` đang chạy, nếu widget dispose → flag `_historyDisposed` được set → nhưng code trong `_initializeHistory()` vẫn tiếp tục chạy và có thể gọi `notifyListeners()`.

## Giải pháp

### Pattern: Check Disposed Before & After EVERY Async Operation

```dart
Future<void> _initializeHistory() async {
  try {
    // ✅ Check TRƯỚC async
    if (_historyDisposed) return;
    
    await loadHistory();
    
    // ✅ Check SAU async
    if (_historyDisposed) return;
    
    AppLogger.info('Success');
  } catch (e) {
    // ✅ Check trong catch
    if (_historyDisposed) return;
    AppLogger.error('Error', e);
  }
}
```

### Các methods đã sửa

1. `_initializeHistory()` - Check disposed trước/sau async và trong catch
2. `loadHistory()` - Check disposed ở đầu và sau async operation
3. `initialize()` - Check disposed ở đầu, trong loop, và sau await
4. `getPalmAnalysisDetail()` - Check disposed trước/sau async và trong catch
5. `getFacialAnalysisHistory()` - Check disposed trước/sau async và trong catch  
6. `getPalmAnalysisHistory()` - Check disposed trước/sau async và trong catch

### Tại sao cần check nhiều lần?

```dart
Future<void> example() async {
  // Point 1: Trước await - provider có thể đã disposed
  if (_historyDisposed) return;
  
  await someAsyncOperation();
  
  // Point 2: Sau await - provider có thể bị disposed TRONG LÚC await
  if (_historyDisposed) return;
  
  notifyListeners(); // Chỉ gọi nếu chưa disposed
}
```

## Testing

### Trước fix
1. Xem lá số tử vi trên thiết bị thật
2. Click "Gặp Chatbot"
3. Đợi message thứ 2 từ AI
4. → **CRASH** với màn hình đỏ "HistoryProvider was used after being disposed"

### Sau fix
1. Xem lá số tử vi trên thiết bị thật
2. Click "Gặp Chatbot"  
3. Đợi message thứ 2 từ AI
4. → **KHÔNG CRASH**, chatbot hoạt động bình thường

### Build và test

```bash
# Clean build
flutter clean
flutter pub get

# Build APK debug để test trên thiết bị thật
flutter build apk --debug

# Install và test
flutter install
```

## Bài học

### 1. Always Check Disposed After Await
Mọi async method trong provider PHẢI check disposed sau EVERY await:

```dart
// ❌ BAD
Future<void> method() async {
  await something();
  notifyListeners(); // Có thể crash
}

// ✅ GOOD  
Future<void> method() async {
  if (_disposed) return;
  await something();
  if (_disposed) return; // Check lại
  notifyListeners();
}
```

### 2. Fire-and-Forget Async Needs Extra Care
Khi gọi async method không await (fire-and-forget), method đó PHẢI tự check disposed:

```dart
// Fire-and-forget call
void syncMethod() {
  _asyncMethod(); // Không await
}

// Async method phải tự bảo vệ
Future<void> _asyncMethod() async {
  if (_disposed) return; // ✅ Check đầu
  await something();
  if (_disposed) return; // ✅ Check sau await
  notifyListeners();
}
```

### 3. Test on Real Devices
Một số lỗi chỉ xuất hiện trên thiết bị thật do:
- Performance khác biệt
- Timing khác biệt  
- Memory constraints khác biệt

**ALWAYS test critical flows trên thiết bị thật!**

## Related Files
- `lib/features/history/presentation/providers/history_provider.dart` - Main fix
- `lib/core/providers/base_provider.dart` - Base class với disposal protection
- `lib/features/ai_conversation/presentation/providers/chat_provider.dart` - Similar pattern

## Status
✅ **FIXED** - Tested on real device, no longer crashes on second AI message in chatbot conversation.
