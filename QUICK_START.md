# 🚀 Quick Start Guide

## Chạy ứng dụng

### 1. Cài đặt dependencies
```bash
flutter pub get
```

### 2. Chạy ứng dụng

#### Trên Chrome (Web)
```bash
flutter run -d chrome
```

#### Chọn device
```bash
flutter run
```
Sau đó chọn:
- [1] Windows (nếu đã enable Developer Mode)
- [2] Chrome (web)

### 3. Kiểm tra code quality
```bash
flutter analyze
```

### 4. Generate code (nếu cần)
```bash
flutter packages pub run build_runner build
```

## 🔧 Troubleshooting

### Lỗi "Building with plugins requires symlink support"
- Chạy: `start ms-settings:developers`
- Bật "Developer Mode" trong Windows Settings
- Restart terminal và thử lại

### Lỗi CardTheme
- Đã được sửa bằng cách comment out cardTheme tạm thời
- App vẫn chạy bình thường với theme mặc định

### Lỗi Flutter command not found
- Kiểm tra Flutter đã được thêm vào PATH
- Hoặc sử dụng đường dẫn đầy đủ đến Flutter

## 📱 Tính năng hiện tại

### ✅ Đã hoàn thành
- **Splash Screen**: Màn hình khởi động với logo
- **Welcome Screen**: Màn hình chào mừng theo Figma design với social login
- **Login Screen**: Màn hình đăng nhập theo Figma design với form validation
- **Sign Up Screen**: Màn hình đăng ký theo Figma design với comprehensive validation
- **Authentication System**: Provider và repository sẵn sàng
- **Navigation**: GoRouter với tất cả routes
- **Theme System**: Material Design 3 với colors
- **Error Handling**: Comprehensive error management
- **Storage**: Secure storage và shared preferences
- **HTTP Service**: API client với logging
- **Logging**: Chi tiết cho debugging

### 🔄 Cần implement
- Social Login Integration (Google/Apple)
- Face Scanning UI
- Profile UI
- Chatbot UI
- Demographics UI
- Result UI

## 🏗️ Cấu trúc để thêm tính năng mới

### 1. Tạo feature folder
```
features/
└── feature_name/
    ├── data/
    │   ├── models/
    │   └── repositories/
    └── presentation/
        ├── pages/
        ├── providers/
        └── widgets/
```

### 2. Tạo model
```dart
@JsonSerializable()
class FeatureModel extends Equatable {
  // Define properties
}
```

### 3. Tạo repository
```dart
class FeatureRepository {
  final HttpService _httpService;
  
  Future<ApiResult<FeatureModel>> getData() async {
    // API calls
  }
}
```

### 4. Tạo provider
```dart
class FeatureProvider extends BaseProvider {
  // State management
}
```

### 5. Tạo UI
```dart
class FeaturePage extends StatelessWidget {
  // UI implementation
}
```

### 6. Thêm route
```dart
// Trong app_router.dart
GoRoute(
  path: '/feature',
  name: 'feature',
  builder: (context, state) => const FeaturePage(),
),
```

## 🔄 Navigation Flow

```
Splash (2s) → Welcome → Login ⇄ Sign Up → Home
```

**Current Screens:**
- ✅ **Splash**: Logo và loading
- ✅ **Welcome**: Social login options + "Login to account"
- ✅ **Login**: Email/password form + social login + back navigation + "Sign Up" link
- ✅ **Sign Up**: Full registration form + social signup + back navigation + "Sign In" link
- ✅ **Home**: Dashboard với navigation

## 🎯 Next Steps

1. **Integrate Social Login**: Google/Apple authentication
2. **Connect AuthProvider**: Link login form với authentication logic
3. **Integrate APIs**: Kết nối với backend thực
4. **Add Tests**: Unit và widget tests
5. **Optimize Performance**: Profile và optimize

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra `flutter doctor`
2. Xem logs trong console
3. Kiểm tra ARCHITECTURE.md để hiểu patterns
4. Follow Flutter best practices

---

**Lưu ý**: Đây là foundation architecture. Các màn hình cụ thể cần được implement dựa trên requirements thực tế.
