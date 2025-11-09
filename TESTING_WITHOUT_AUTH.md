# Testing Chatbot Without Authentication

## Overview
Đã tạm thời disable authentication check trong chức năng "Gặp Chatbot" để test nhanh hơn khi API authentication bị hỏng.

## Changes Made

### File Modified: `lib/features/tu_vi/presentation/pages/tu_vi_result_page.dart`

#### 1. Bypass Authentication Check
```dart
// TODO: TEMPORARY - Bypass authentication for testing
// Uncomment these lines when API auth is fixed:
// if (authProvider.currentUser == null) {
//   if (mounted) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Vui lòng đăng nhập để sử dụng chatbot'),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
//   return;
// }
// final user = authProvider.currentUser!;
```

#### 2. Mock User Data
```dart
// TEMPORARY: Mock user for testing (user_id = 1 as per API docs)
const mockUser = User(
  id: 1,
  email: 'test@example.com',
  firstName: 'Test',
  lastName: 'User',
);
```

#### 3. Use Mock User
```dart
// Set user in chat provider (using mock user for testing)
chatProvider.setUser(mockUser);
```

## Testing Flow

### Bây giờ bạn có thể test:
1. ✅ Mở màn hình xem lá số tử vi (không cần đăng nhập)
2. ✅ Click nút "Gặp Chatbot"
3. ✅ App sẽ tự động sử dụng `user_id = 1` để gọi API
4. ✅ Navigate sang chatbot screen
5. ✅ Test gửi/nhận tin nhắn với AI

### API Calls sẽ sử dụng:
```json
POST /api/v1/chat/start
{
  "user_id": 1,
  "chart_id": <actual_chart_id>
}
```

## Restore Authentication

### Khi API authentication đã fix, làm theo các bước:

1. **Uncomment authentication check:**
```dart
// Remove this line:
// const mockUser = User(...);

// Uncomment these lines:
final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);

if (authProvider.currentUser == null) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vui lòng đăng nhập để sử dụng chatbot'),
        backgroundColor: Colors.red,
      ),
    );
  }
  return;
}

final user = authProvider.currentUser!;
```

2. **Restore original user assignment:**
```dart
// Change from:
chatProvider.setUser(mockUser);

// Back to:
chatProvider.setUser(user);
```

3. **Remove mock user constant**

4. **Test with real authentication**

## Notes

⚠️ **IMPORTANT**: 
- Mock user ID là `1` theo tài liệu API test mode
- Khi restore authentication, nhớ remove tất cả comment `TODO: TEMPORARY`
- File này (`TESTING_WITHOUT_AUTH.md`) nên được xóa sau khi restore authentication

## Quick Commands

### Revert changes nhanh:
```bash
git diff lib/features/tu_vi/presentation/pages/tu_vi_result_page.dart
git checkout lib/features/tu_vi/presentation/pages/tu_vi_result_page.dart
```

---
**Created**: 2025-11-09  
**Purpose**: Temporary testing without authentication  
**Status**: Active (should be removed when auth is fixed)
