# 🔥 Firebase Project Setup Guide

## Bước 1: Tạo Firebase Project

1. Vào: https://console.firebase.google.com/
2. Click **"Add project"**
3. Nhập tên project: `tuong-hoc-ai` (hoặc tên bạn muốn)
4. Click **"Continue"** → **"Create project"**

---

## Bước 2: Thêm Android App

1. **Project Overview** → Click icon **Android** 
2. **Android package name:** `com.physiognomy.app.ai_physiognomy`
3. **App nickname:** `Tướng học AI`
4. **SHA-1 fingerprint:** 
   ```
   BA:3F:4A:A7:9F:82:37:3F:B7:2E:1D:C9:04:FB:56:89:BD:73:EA:D9
   ```
5. Click **"Register app"**
6. **Download google-services.json**
7. Click **"Next"** → **"Next"** → **"Continue to console"**

---

## Bước 3: Thêm iOS App (Optional)

1. **Project Overview** → Click icon **iOS**
2. **iOS bundle ID:** `com.physiognomy.app.ai-physiognomy`
3. **App nickname:** `Tướng học AI`
4. Click **"Register app"**
5. **Download GoogleService-Info.plist**
6. Click **"Next"** → **"Next"** → **"Continue to console"**

---

## Bước 4: Enable Google Authentication

1. **Build** → **Authentication** → **"Get started"**
2. Click tab **"Sign-in method"**
3. Click **"Google"** → Toggle **"Enable"**
4. **Project support email:** Chọn email của bạn
5. Click **"Save"**

---

## Bước 5: Lấy Web Client ID

### Option A: Từ Firebase Console
1. ⚙️ **Project Settings** → **Service accounts**
2. Click **"Manage service account permissions"**
3. Trong Google Cloud Console → **APIs & Services** → **Credentials**
4. Tìm **"Web client (auto created by Google Service)"**
5. **Copy Client ID** (dạng: `123456789-xxxxx.apps.googleusercontent.com`)

### Option B: Trực tiếp Google Cloud Console
1. Vào: https://console.cloud.google.com/apis/credentials
2. Chọn project Firebase vừa tạo
3. Copy **"Web client (auto created by Google Service)"** Client ID

---

## Bước 6: Copy Config Files

1. **Copy google-services.json:**
   - Từ Downloads → `android/app/google-services.json`
   
2. **Copy GoogleService-Info.plist (iOS):**
   - Từ Downloads → `ios/Runner/GoogleService-Info.plist`

---

## Bước 7: Update Flutter Code

Chạy script tự động:
```bash
python update_firebase_project.py
```

Script sẽ hỏi bạn nhập **Web Client ID** và tự động update code.

---

## Bước 8: Clean và Rebuild

```bash
flutter clean
flutter pub get
flutter run
```

---

## ✅ Checklist

- [ ] Tạo Firebase project
- [ ] Thêm Android app với SHA-1
- [ ] Download google-services.json
- [ ] Thêm iOS app (nếu có)
- [ ] Download GoogleService-Info.plist (nếu có)
- [ ] Enable Google Authentication
- [ ] Lấy Web Client ID
- [ ] Copy google-services.json vào `android/app/`
- [ ] Copy GoogleService-Info.plist vào `ios/Runner/`
- [ ] Chạy `python update_firebase_project.py`
- [ ] Flutter clean + pub get + run
- [ ] Test Google Sign-In

---

## 🐛 Troubleshooting

### Lỗi ApiException: 10
- **Nguyên nhân:** SHA-1 fingerprint chưa được add vào Firebase
- **Fix:** Add SHA-1 vào Firebase Console → Project Settings → Your apps

### Lỗi com.google.android.gms.common.api.ApiException: 12
- **Nguyên nhân:** google-services.json chưa được copy đúng
- **Fix:** Kiểm tra file `android/app/google-services.json`

### Google Sign-In không hiển thị popup
- **Nguyên nhân:** Web Client ID sai hoặc thiếu
- **Fix:** Kiểm tra `lib/core/services/google_sign_in_service.dart`

---

## 📞 Support

Nếu gặp vấn đề, kiểm tra:
1. Firebase Console → Authentication → Sign-in method → Google đã enable chưa
2. SHA-1 fingerprint đã add vào Firebase chưa
3. Package name có khớp: `com.physiognomy.app.ai_physiognomy`
