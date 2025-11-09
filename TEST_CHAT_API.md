# Test Chat API Endpoint

## Vấn đề hiện tại
API trả về 404 Not Found. Có 2 khả năng về endpoint:

### Option 1: Chat API ở base URL (không có /ai)
```
POST http://160.250.180.132:3000/api/v1/chat/start
```

### Option 2: Chat API ở old backend (có /ai)
```
POST http://160.250.180.132:3000/ai/api/v1/chat/start
```

## Test bằng curl (Windows PowerShell)

### Test Option 1 (base URL):
```powershell
curl -X POST "http://160.250.180.132:3000/api/v1/chat/start" `
  -H "Content-Type: application/json" `
  -d '{"user_id": 1, "chart_id": 42}'
```

### Test Option 2 (old backend với /ai):
```powershell
curl -X POST "http://160.250.180.132:3000/ai/api/v1/chat/start" `
  -H "Content-Type: application/json" `
  -d '{"user_id": 1, "chart_id": 42}'
```

## Nếu cả 2 đều không work, thử không có /v1:
```powershell
# Option 3
curl -X POST "http://160.250.180.132:3000/chat/start" `
  -H "Content-Type: application/json" `
  -d '{"user_id": 1, "chart_id": 42}'

# Option 4
curl -X POST "http://160.250.180.132:3000/ai/chat/start" `
  -H "Content-Type: application/json" `
  -d '{"user_id": 1, "chart_id": 42}'
```

## Sau khi tìm được endpoint đúng:

### Nếu Option 1 đúng:
Cần update `AppConstants.oldBackendBaseUrl` hoặc routing logic để chat API dùng `baseUrl` thay vì `oldBackendBaseUrl`.

### Nếu Option 2 đúng:
Code hiện tại sau khi sửa sẽ work! Chạy lại app và test.

### Nếu Option 3 hoặc 4 đúng:
Cần update endpoint trong `ChatRepository`:
- Từ: `/api/v1/chat/start`
- Sang: `/chat/start`

## Next Steps
1. Chạy các test curl ở trên
2. Báo cho tôi biết command nào return 200 OK hoặc có response hợp lệ
3. Tôi sẽ update code cho đúng
