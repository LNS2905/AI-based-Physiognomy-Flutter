# API VERIFICATION CHECKLIST
**Date:** 2025-11-09  
**Backend:** http://160.250.180.132:3000  
**Status:** Ready to test

---

## ✅ 1. AUTH APIs

### 1.1 Register (`POST /users/signUp`)
**Mobile Code:**
```dart
CreateUserDTO {
  username, password, confirmPassword,
  firstName, lastName, email, phone, age, gender, avatar
}
```
**Swagger Spec:**
```json
{
  "username": "string" (optional),
  "password": "string",
  "confirmPassword": "string",
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "phone": "string",
  "age": number,
  "gender": "male|female",
  "avatar": "string" (optional)
}
```
- ✅ **MATCH PERFECT!**

**Test Steps:**
1. Open app → Go to SignUp page
2. Fill: firstName, lastName, email, phone, age, gender, password
3. Click "Create Account"
4. Expected: Success → Auto-login → Navigate to Home

---

### 1.2 Login (`POST /auth/user`)
**Mobile Code:**
```dart
AuthRequest {
  username: string,
  password: string
}
```
**Swagger Spec:**
```json
{
  "username": "string",
  "password": "string"
}
```
- ✅ **MATCH PERFECT!**

**Test Steps:**
1. Go to Login page
2. Enter email as username + password
3. Click "Login"
4. Expected: Success → Navigate to Home

---

### 1.3 Google Login (`POST /auth/google/mobile`)
**Mobile Code:**
```dart
GoogleLoginRequest {
  token: string  // Firebase ID token
}
```
**Swagger Spec:**
```json
{
  "token": "string"
}
```
- ✅ **MATCH PERFECT!**
- ⚠️ **KNOWN ISSUE:** Backend returns 500 (server-side Google OAuth config)

**Test Steps:**
1. Click "Sign in with Google"
2. Select Google account
3. Expected: Currently fails with 500 error
4. **Fix needed:** Backend Google OAuth config

---

### 1.4 Get Current User (`GET /auth/me`)
**Endpoint:** `http://160.250.180.132:3000/auth/me`  
**Headers:** `Authorization: Bearer {JWT}`

**Test Steps:**
1. After login, app auto calls this
2. Expected: Returns user data with credits

---

## ✅ 2. FACE ANALYSIS APIs

### 2.1 Save Analysis (`POST /facial-analysis`)
**Mobile Code:**
```dart
FacialAnalysisDto {
  userId, resultText, faceShape, harmonyScore,
  probabilities, harmonyDetails, metrics,
  annotatedImage, processedAt
}
```
**Swagger Spec:**
```json
Same fields as mobile code
```
- ✅ **MATCH PERFECT!**

**Test Steps:**
1. Go to Face Scan
2. Take photo
3. Wait for AI analysis
4. Expected: Results saved to backend

---

### 2.2 Get User Analyses (`GET /facial-analysis/user/{userId}`)
**Endpoint:** `http://160.250.180.132:3000/facial-analysis/user/{userId}`

**Test Steps:**
1. Go to Face Analysis History
2. Expected: Show list of past analyses

---

## ✅ 3. PALM ANALYSIS APIs

### 3.1 Save Analysis (`POST /palm-analysis`)
**Mobile Code:**
```dart
PalmAnalysisDto {
  userId, annotatedImage, palmLinesDetected,
  targetLines, imageHeight, imageWidth, imageChannels,
  summaryText, interpretations, lifeAspects
}
```
**Swagger Spec:**
```json
Same fields as mobile code
```
- ✅ **MATCH PERFECT!**

**Test Steps:**
1. Go to Palm Scan
2. Take photo
3. Wait for AI analysis
4. Expected: Results saved to backend

---

### 3.2 Get User Analyses (`GET /palm-analysis/user/{userId}`)
**Endpoint:** `http://160.250.180.132:3000/palm-analysis/user/{userId}`

**Test Steps:**
1. Go to Palm Analysis History
2. Expected: Show list of past analyses

---

## ✅ 4. PAYMENT/CREDITS APIs

### 4.1 Get Credit Packages
**Check if endpoint exists in backend**

**Test Steps:**
1. Go to Payment/Packages page
2. Expected: Show 4 packages (Starter, Basic, Popular, Premium)

---

### 4.2 Create Checkout Session (`POST /users/me/recharge`)
**Endpoint:** `http://160.250.180.132:3000/users/me/recharge`

**Test Steps:**
1. Select a credit package
2. Click "Buy Now"
3. Expected: Open Stripe Checkout page
4. Use test card: `4242 4242 4242 4242`
5. Complete payment
6. Expected: Redirect back to app with success

---

### 4.3 Check Credits
**Verify credits display in:**
- Profile page
- Before sending chatbot message
- After payment success

---

## ✅ 5. TỬ VI APIs (Port 8000)

### 5.1 Create Chart (`POST /charts`)
**Endpoint:** `http://160.250.180.132:8000/charts`  
**Backend:** lasotuvi (FastAPI)

**Test Steps:**
1. Go to Tử Vi module
2. Enter birth info (day, month, year, hour, gender, name)
3. Click "Tạo lá số"
4. Expected: Chart created successfully

---

### 5.2 AI Analysis (`POST /tuvi/analyze-json`)
**Endpoint:** `http://160.250.180.132:8000/tuvi/analyze-json`

**Test Steps:**
1. After creating chart
2. Ask question: "Sự nghiệp của tôi năm nay thế nào?"
3. Expected: AI returns detailed analysis

---

## ⚠️ KNOWN ISSUES

### Issue 1: Google Login 500 Error
**Status:** Backend issue  
**Fix:** Server needs Google OAuth config  
**Workaround:** Use email/password registration

### Issue 2: Backend Unhealthy
**Status:** Database schema warning  
**Impact:** APIs still work, but health check fails  
**Fix:** Run `npx prisma db push` on server

### Issue 3: Chatbot 404
**Status:** Expected - chatbot not deployed yet  
**Impact:** AI Conversation feature won't work  
**Fix:** Deploy chatbot backend later

---

## 🧪 TEST PRIORITY

### HIGH Priority (Critical for app function):
1. ✅ Register + Login
2. ✅ Face Scan + Save
3. ✅ Palm Scan + Save
4. ✅ Tử Vi Chart Creation

### MEDIUM Priority:
5. ✅ Payment/Credits
6. ✅ View History (Face, Palm)
7. ✅ Profile Management

### LOW Priority (Known to fail):
8. ❌ Google Login (500 error - backend issue)
9. ❌ Chatbot (not deployed)

---

## 📱 TESTING INSTRUCTIONS

**Device:** Android Emulator (currently running)

**Steps:**
1. App already running on emulator
2. Currently on Welcome/Login screen
3. Follow test steps above for each feature
4. Report any errors you encounter

**Expected Success Rate:**
- ✅ 80% features should work
- ❌ 20% known issues (Google OAuth, Chatbot)

---

## 🔧 QUICK FIXES IF NEEDED

### If Register Fails:
- Check backend logs: `docker logs glowlab_backend`
- Verify email format is valid
- Try different username

### If Face/Palm Analysis Fails:
- Check physiognomy-api container: `docker ps | grep physiognomy`
- Port 8001 may need reverse proxy

### If Payment Fails:
- Check Stripe keys in backend `.env`
- Verify payment controller exists

---

**Ready to test!** Let me know results of each feature.
