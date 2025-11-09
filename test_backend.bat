@echo off
echo ========================================
echo TESTING BACKEND ENDPOINTS
echo Backend: http://160.250.180.132:3000
echo ========================================
echo.

echo [1] Testing Health Check...
curl -X GET http://160.250.180.132:3000/health
echo.
echo.

echo [2] Testing Register Endpoint...
curl -X POST http://160.250.180.132:3000/users/signUp ^
  -H "Content-Type: application/json" ^
  -d "{\"full_name\":\"Test User\",\"email\":\"test@example.com\",\"password\":\"Test123!@#\"}"
echo.
echo.

echo [3] Testing Login Endpoint...
curl -X POST http://160.250.180.132:3000/auth/user ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@example.com\",\"password\":\"Test123!@#\"}"
echo.
echo.

echo [4] Testing Chat Start Endpoint...
curl -X POST http://160.250.180.132:3000/api/v1/chat/start ^
  -H "Content-Type: application/json" ^
  -d "{\"user_id\":1}"
echo.
echo.

echo ========================================
echo TEST COMPLETED
echo ========================================
pause
