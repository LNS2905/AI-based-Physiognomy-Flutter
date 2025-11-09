# Kiểm tra API Format - Chatbot Implementation

## ✅ So sánh Implementation với API Docs

### 1. **POST /api/v1/chat/start** - Bắt đầu cuộc hội thoại

**API Docs yêu cầu:**
```json
{
  "user_id": integer (required),
  "chart_id": integer (optional)
}
```

**Implementation của chúng ta:**
```dart
// Model: ChatStartRequest
@JsonSerializable()
class ChatStartRequest extends Equatable {
  @JsonKey(name: 'user_id')  // ✅ Đúng tên field
  final int userId;           // ✅ Đúng kiểu integer
  @JsonKey(name: 'chart_id')  // ✅ Đúng tên field
  final int? chartId;         // ✅ Optional, đúng kiểu integer
}

// Repository call
final response = await _httpService.post(
  '/api/v1/chat/start',      // ✅ Đúng endpoint
  body: request.toJson(),     // ✅ Serialize thành JSON
);
```

**Request sẽ gửi đi:**
```json
{
  "user_id": 123,
  "chart_id": 456
}
```
✅ **CHÍNH XÁC** - Match 100% với API docs

---

### 2. **POST /api/v1/chat/message** - Gửi tin nhắn

**API Docs yêu cầu:**
```json
{
  "conversation_id": integer (required),
  "message": string (required)
}
```

**Implementation của chúng ta:**
```dart
// Model: ChatRequestModel
@JsonSerializable()
class ChatRequestModel extends Equatable {
  final String message;              // ✅ Đúng kiểu string
  @JsonKey(name: 'conversation_id')  // ✅ Đúng tên field
  final int conversationId;          // ✅ Required, đúng kiểu integer
}

// Repository call
final response = await _httpService.post(
  '/api/v1/chat/message',    // ✅ Đúng endpoint
  body: request.toJson(),     // ✅ Serialize thành JSON
);
```

**Request sẽ gửi đi:**
```json
{
  "conversation_id": 789,
  "message": "Xin chào AI"
}
```
✅ **CHÍNH XÁC** - Match 100% với API docs

**⚠️ LƯU Ý:** 
- Model có thêm các field `context`, `attachments`, `metadata` (optional) cho tương lai
- Nhưng khi gửi, chỉ gửi 2 fields bắt buộc theo API docs
- Các field optional sẽ không được serialize nếu null (nhờ `includeIfNull: false` mặc định)

---

### 3. **GET /api/v1/chat/history/{conversation_id}** - Lấy lịch sử

**API Docs yêu cầu:**
- Path parameter: `conversation_id` (integer)
- Response: Array of messages

**Implementation của chúng ta:**
```dart
final response = await _httpService.get(
  '/api/v1/chat/history/$conversationId',  // ✅ Đúng endpoint
);

// Parse response
if (response.containsKey('messages') && response['messages'] is List) {
  // Parse từ key 'messages'
} else if (response['data'] is List) {
  // Hoặc parse từ key 'data'
}
```

✅ **CHÍNH XÁC** - Endpoint đúng, hỗ trợ nhiều format response

---

## ✅ Các điểm ĐÚNG theo API Docs

1. **Base Path**: `/api/v1` - ✅ Đúng
2. **Content-Type**: `application/json` - ✅ Tự động set bởi HttpService
3. **Field Names**: Sử dụng `@JsonKey(name: '...')` để match chính xác - ✅
4. **Data Types**:
   - `user_id`: int ✅
   - `chart_id`: int? ✅
   - `conversation_id`: int ✅
   - `message`: String ✅
5. **Required/Optional**: Đúng theo spec - ✅

---

## ⚠️ Điểm cần lưu ý

### Response Format Flexibility

API docs không specify rõ response format, nên chúng ta implement flexible parsing:

```dart
// Cho /chat/message endpoint
if (response.containsKey('message')) {
  messageContent = response['message'];
} else if (response.containsKey('response')) {
  messageContent = response['response'];
} else {
  // Fallback: lấy string value đầu tiên
  messageContent = response.values.firstWhere((v) => v is String);
}
```

**Lý do:** API docs chỉ nói "Success" mà không specify exact response structure.

---

## 🔍 Test Scenarios cần kiểm tra

### Test 1: Start Conversation
```dart
// Request
POST /api/v1/chat/start
{
  "user_id": 1,
  "chart_id": 5  // optional
}

// Expected Response (dự đoán)
{
  "conversation_id": 123
}
```

### Test 2: Send Message
```dart
// Request
POST /api/v1/chat/message
{
  "conversation_id": 123,
  "message": "Tử vi của tôi thế nào?"
}

// Expected Response (dự đoán)
{
  "message": "Dựa vào lá số tử vi...",
  "id": "msg_456",
  ... other fields
}
```

### Test 3: Get History
```dart
// Request
GET /api/v1/chat/history/123

// Expected Response (dự đoán)
{
  "messages": [
    {
      "role": "user",
      "content": "Xin chào",
      "id": "msg_1"
    },
    {
      "role": "ai",
      "content": "Chào bạn!",
      "id": "msg_2"
    }
  ]
}
```

---

## ✅ KẾT LUẬN

### Implementation CHÍNH XÁC 100% theo API Docs cho:

1. ✅ **Endpoints** - Đúng path hoàn toàn
2. ✅ **Request Format** - Field names và types chính xác
3. ✅ **Required/Optional** - Đúng theo spec
4. ✅ **JSON Serialization** - Đúng snake_case (conversation_id, user_id, chart_id)
5. ✅ **HTTP Methods** - POST cho start/message, GET cho history

### Điểm linh hoạt (vì API docs không specify):

1. ⚠️ **Response parsing** - Hỗ trợ nhiều format khác nhau
2. ⚠️ **Error handling** - Handle theo convention chung
3. ⚠️ **Extra fields** - Model có thêm fields cho mở rộng tương lai

---

## 📝 Checklist để test với backend thực

- [ ] Backend đang chạy tại `http://192.168.100.55:3000/ai`
- [ ] User đã login và có valid access token
- [ ] User có credits > 0
- [ ] Test POST /api/v1/chat/start với valid user_id
- [ ] Test POST /api/v1/chat/message với conversation_id từ bước trên
- [ ] Test GET /api/v1/chat/history/{conversation_id}
- [ ] Kiểm tra response format từ backend có match expectations không
- [ ] Log toàn bộ request/response để debug nếu cần

---

## 🎯 ĐÁNH GIÁ CUỐI CÙNG

### Implementation: ✅ CHÍNH XÁC 100%

- Endpoints: ✅
- Request format: ✅  
- Field names: ✅
- Data types: ✅
- JSON serialization: ✅
- Required/optional: ✅

**READY TO TEST VỚI BACKEND!** 🚀
