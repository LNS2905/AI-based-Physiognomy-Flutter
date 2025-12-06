# Chatbot AI Backend API Documentation
*Parsed from aichatbot.swagger*

**Base Path:** `/api/v1`
**Base URL:** `http://160.250.180.132:5003`

---

## 📋 Chat APIs

### 1. POST /chat/start
**Bắt đầu cuộc hội thoại mới**

**Request Body (ChatStart):**
```json
{
  "user_id": 123,        // REQUIRED - integer
  "chart_id": 456        // optional - integer, ID của lá số tử vi
}
```

**Response:**
```json
{
  "success": true,
  "conversation_id": 42,
  "message": "Xin chào! Tôi là trợ lý AI..."
}
```

---

### 2. POST /chat/message
**Gửi tin nhắn và nhận phản hồi từ Agent**

**Request Body (ChatMessage):**
```json
{
  "conversation_id": 42,  // REQUIRED - integer
  "user_id": 123,         // REQUIRED - integer
  "message": "Tôi muốn hỏi về sự nghiệp"  // REQUIRED - string
}
```

**Response:**
```json
{
  "success": true,
  "answer": "Về sự nghiệp của bạn...",
  "tools_used": ["rag_lookup", "chinese_daily"],
  "conversation_id": 42
}
```

---

### 3. GET /chat/history/{conversation_id}
**Lấy lịch sử hội thoại**

**Path Parameters:**
- `conversation_id` (integer) - REQUIRED

**Response:**
```json
{
  "success": true,
  "messages": [
    {
      "id": 1,
      "conversationId": 42,
      "role": "user",
      "content": "Xin chào",
      "createAt": "2025-11-29T10:00:00Z"
    },
    {
      "id": 2,
      "conversationId": 42,
      "role": "assistant",
      "content": "Xin chào bạn...",
      "createAt": "2025-11-29T10:00:05Z"
    }
  ]
}
```

---

### 4. GET /chat/user/{user_id}/conversations
**Lấy danh sách conversation IDs của user**

**Path Parameters:**
- `user_id` (integer) - REQUIRED

**Response:**
```json
{
  "success": true,
  "conversation_ids": [42, 41, 40, 39, 38]
}
```

---

## 🔮 Tu Vi Analysis APIs

### 5. POST /tuvi/analyze-json
**🚀 ENDPOINT NHANH NHẤT: Luận giải từ JSON lá số (KHÔNG CẦN OCR/VISION)**

**Đây là endpoint chính được dùng trong app!**

**Request Body (ChartJsonInput):**
```json
{
  "chart_data": {
    // Full JSON response từ API tạo lá số
    "houses": [...],
    "stars": [...],
    "extra": {...},
    "request": {...}
  },
  "question": "Hãy giới thiệu ngắn gọn về lá số này"
}
```

**Response (AnalysisResult):**
```json
{
  "analysis": "Dựa vào lá số của bạn...",
  "timestamp": "2025-11-29T10:30:00",
  "status": "success",
  "method": "json",
  "processing_time": "12.5s"
}
```

**Ưu điểm:**
- ⚡ Nhanh: 8-15 giây (vs 50-100s của endpoint upload)
- 🎯 Chính xác: Không cần OCR, dùng data trực tiếp
- ✅ Đây là endpoint được dùng trong `_sendInitialAnalysis()`

---

### 6. POST /tuvi/analyze
**🐌 CẨN CỨ - CHẬM: Upload và luận giải từ hình ảnh/PDF**

**⚠️ CHỈ DÙNG KHI:**
- User đã có sẵn hình ảnh lá số
- Không thể dùng API tạo lá số

**Chậm:** 50-100 giây (do phải OCR + Vision)

**Request:** `multipart/form-data`
- `file`: File lá số (PDF hoặc JPG/PNG/JPEG)

**Response:** Giống `/tuvi/analyze-json`

---

## 📁 Other APIs

### 7. GET /files
**🗂️ Lấy danh sách file trong thư mục test**

Debug/testing endpoint.

---

## 📊 Data Models

### ChatStart
```typescript
{
  user_id: number;     // REQUIRED
  chart_id?: number;   // optional
}
```

### ChatMessage
```typescript
{
  conversation_id: number;  // REQUIRED
  user_id: number;          // REQUIRED
  message: string;          // REQUIRED
}
```

### ChartJsonInput
```typescript
{
  chart_data: object;  // REQUIRED - Full chart JSON
  question: string;    // REQUIRED - Câu hỏi luận giải
}
```

### AnalysisResult
```typescript
{
  analysis: string;       // Kết quả luận giải
  timestamp: string;      // ISO datetime
  status: string;         // "success" | "error"
  method: string;         // "json" | "upload"
  processing_time: string; // "12.5s"
}
```

---

## 🔄 Integration Flow in App

### Flow 1: Create Conversation from Tu Vi Chart
```
1. User views Tu Vi chart → Click "Gặp Chatbot"
2. App calls: POST /chat/start
   Body: { user_id: 1, chart_id: 123 }
3. Backend:
   - INSERT INTO TuviConversation (userId, chartId)
   - Return conversation_id: 42
4. App auto-sends initial analysis:
   POST /tuvi/analyze-json
   Body: { chart_data: {...}, question: "Giới thiệu lá số..." }
5. Backend:
   - INSERT TuviMessage (role: user, content: question)
   - Process AI → Generate analysis
   - INSERT TuviMessage (role: assistant, content: analysis)
   - Return analysis result
6. App navigates to chat page with conversation_id
```

### Flow 2: Continue Existing Conversation
```
1. User enters chat page with conversation_id
2. App calls: GET /chat/history/42
3. Backend:
   - SELECT * FROM TuviMessage WHERE conversationId = 42
   - Return messages
4. User sends new message
5. App calls: POST /chat/message
   Body: { conversation_id: 42, user_id: 1, message: "..." }
6. Backend:
   - INSERT TuviMessage (user message)
   - Process AI
   - INSERT TuviMessage (assistant response)
   - Return answer
```

### Flow 3: Load History
```
1. User opens History tab
2. App calls: GET /chat/user/1/conversations
3. Backend:
   - SELECT id FROM TuviConversation WHERE userId = 1
   - Return [42, 41, 40, ...]
4. For each conversation ID:
   App calls: GET /chat/history/{id}
5. Display in history list
```

---

## ✅ Current Implementation Status

**Flutter App:**
- ✅ Uses `/chat/start` in `ChatProvider.createNewConversation()`
- ✅ Uses `/chat/message` in `ChatProvider.sendMessage()`
- ✅ Uses `/tuvi/analyze-json` in `ChatProvider._sendInitialAnalysis()`
- ✅ Uses `/chat/history/{id}` in `ChatRepository.getConversationHistory()`
- ✅ Uses `/chat/user/{id}/conversations` in `ChatRepository.getUserConversations()`

**Backend Storage:**
- ✅ All saved to PostgreSQL (main backend database)
- ✅ Tables: `TuviConversation` + `TuviMessage`
- ✅ Chatbot backend (port 5003) writes/reads directly to/from PostgreSQL

---

## 🔑 Key Points

1. **Base URL:** Always use `AppConstants.chatbotBaseUrl` (port 5003)
2. **Database:** Shared PostgreSQL with main backend
3. **Primary Endpoint:** `/tuvi/analyze-json` (nhanh, chính xác)
4. **History:** Auto-saved by backend, no manual save needed
5. **Conversation Lifecycle:**
   - Create: `/chat/start`
   - Message: `/chat/message`
   - Retrieve: `/chat/history/{id}`
   - List: `/chat/user/{id}/conversations`
