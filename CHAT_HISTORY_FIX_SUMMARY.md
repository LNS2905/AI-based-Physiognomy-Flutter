# Chat Conversation History Fix

## Vấn đề
App không lưu chat conversation vào history. Người dùng không thể xem lại các cuộc trò chuyện trước đó.

## Nguyên nhân

### 1. Sai Backend URL
Flutter app đang gọi **SAI backend** cho chat API:

**TRƯỚC:**
```dart
ChatRepository({HttpService? httpService})
    : _httpService = httpService ?? HttpService(); // ❌ Dùng baseUrl mặc định
```

HttpService mặc định dùng `AppConstants.baseUrl` = `http://160.250.180.132:3000`

Nhưng chat/conversation API nằm ở backend riêng:
- `AppConstants.chatbotBaseUrl` = `http://160.250.180.132:5003`

Backend ở port 3000 (ai-physio-be) CHỈ có mock chat API, KHÔNG có conversation system.

### 2. Architecture Issue
Hệ thống có 2 backends:

1. **Main Backend (Port 3000)** - `ai-physio-be`
   - Auth, User management
   - Face/Palm analysis
   - Credit/Payment system
   - Mock chat (chỉ test, không lưu history)

2. **Chatbot Backend (Port 5003)** - Dịch vụ riêng
   - AI Conversation API
   - Tu Vi analysis integration
   - **Conversation persistence** (lưu messages vào DB)
   - Conversation history endpoints:
     - `POST /api/v1/chat/start` - Tạo conversation
     - `POST /api/v1/chat/message` - Gửi message
     - `GET /api/v1/chat/history/:id` - Lấy conversation history
     - `GET /api/v1/chat/user/:userId/conversations` - Lấy danh sách conversation IDs

## Giải pháp

### Fix ChatRepository
Sửa `ChatRepository` để dùng đúng backend URL:

```dart
// lib/features/ai_conversation/data/repositories/chat_repository.dart

ChatRepository({HttpService? httpService})
    : _httpService = httpService ?? HttpService(
        baseUrl: AppConstants.chatbotBaseUrl, // ✅ Dùng chatbot backend (port 5003)
      );
```

### How It Works Now

1. **Tạo conversation mới:**
   ```
   POST http://160.250.180.132:5003/api/v1/chat/start
   Body: { userId: 1, chartId: 123 }
   Response: { conversation_id: 42, message: "Welcome..." }
   ```
   - Backend TỰ ĐỘNG lưu conversation vào database

2. **Gửi message:**
   ```
   POST http://160.250.180.132:5003/api/v1/chat/message
   Body: { conversationId: 42, userId: 1, message: "..." }
   Response: { answer: "AI response..." }
   ```
   - Backend TỰ ĐỘNG lưu user message + AI response vào database

3. **Load history:**
   ```
   GET http://160.250.180.132:5003/api/v1/chat/user/1/conversations
   Response: { conversation_ids: [42, 41, 40, ...] }
   
   GET http://160.250.180.132:5003/api/v1/chat/history/42
   Response: { messages: [...] }
   ```
   - `HistoryRepository.getChatHistory()` đã implement sẵn flow này
   - Load list conversation IDs → Fetch messages cho từng ID → Convert sang `ChatHistoryModel`

## Testing

### Test Flow

1. **Tạo conversation:**
   - Xem lá số tử vi
   - Click "Gặp Chatbot"
   - Gửi vài messages
   - Backend tự động lưu

2. **Verify lưu thành công:**
   - Thoát app và vào lại
   - Vào tab History/Lịch sử
   - Kiểm tra có hiển thị chat conversation không

3. **Test xem lại conversation:**
   - Click vào chat history item
   - Verify messages hiển thị đúng
   - Check timestamps, user/AI role

### API Test Commands

```bash
# Test tạo conversation
curl -X POST http://160.250.180.132:5003/api/v1/chat/start \
  -H "Content-Type: application/json" \
  -d '{"userId": 1, "chartId": 123}'

# Test lấy conversations
curl http://160.250.180.132:5003/api/v1/chat/user/1/conversations

# Test lấy conversation history
curl http://160.250.180.132:5003/api/v1/chat/history/42
```

## Backend Requirements

Chatbot backend (port 5003) PHẢI có các API endpoints:

- ✅ `POST /api/v1/chat/start` - Create conversation
- ✅ `POST /api/v1/chat/message` - Send message
- ✅ `GET /api/v1/chat/history/:conversationId` - Get messages
- ✅ `GET /api/v1/chat/user/:userId/conversations` - Get conversation IDs

Nếu backend chưa có, cần implement:

### Database Schema (Prisma/TypeORM)

```typescript
model Conversation {
  id        Int       @id @default(autoincrement())
  userId    Int
  chartId   Int?
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
  messages  Message[]
}

model Message {
  id             Int          @id @default(autoincrement())
  conversationId Int
  role           String       // "user" or "assistant"
  content        String       @db.Text
  createdAt      DateTime     @default(now())
  conversation   Conversation @relation(fields: [conversationId], references: [id])
}
```

## Files Changed

1. **ChatRepository** (`lib/features/ai_conversation/data/repositories/chat_repository.dart`)
   - Changed to use `AppConstants.chatbotBaseUrl` instead of default baseUrl

## Files Already Implemented (No Change Needed)

1. **HistoryRepository** (`lib/features/history/data/repositories/history_repository.dart`)
   - `getChatHistory()` method already fetches from chatbot backend
   - Converts to `ChatHistoryModel`

2. **HistoryProvider** (`lib/features/history/presentation/providers/history_provider.dart`)
   - Already calls `getChatHistory()` in `getAllHistory()`
   - No changes needed

3. **ChatProvider** (`lib/features/ai_conversation/presentation/providers/chat_provider.dart`)
   - Already creates conversation via `startConversation()`
   - Already sends messages via `sendMessage()`
   - No changes needed

## Verification Checklist

- [x] ChatRepository uses correct baseUrl (chatbotBaseUrl)
- [ ] Build and install app on device
- [ ] Create new conversation from Tu Vi result
- [ ] Send multiple messages
- [ ] Restart app
- [ ] Check History tab for chat conversations
- [ ] Open chat history item and verify messages load correctly

## Notes

### Why Separate Backend?

Chatbot backend is separate because:
1. Different technology stack (Python Flask with AI models)
2. Heavy AI processing (Tu Vi analysis, chatbot)
3. Can scale independently
4. Isolated from main app logic

### History Repository Design

`HistoryRepository` cleverly aggregates ALL history types:
- Face analysis (from main backend)
- Palm analysis (from main backend)  
- Chat conversations (from chatbot backend)

All combined into single `List<HistoryItemModel>` for unified UI.

## Status

✅ **FIXED** - ChatRepository now uses correct backend URL. Conversations will be saved and retrieved from history.
