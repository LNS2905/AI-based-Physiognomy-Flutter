# Quick Guide: Camera Orientation Fix

## 🎯 Vấn đề đã giải quyết
Hình ảnh bị xoay ngang khi chụp ảnh gương mặt để phân tích.

## ⚡ Giải pháp tóm tắt

### 1. Camera Type Detection
```dart
// CameraService giờ track camera type thực tế
CameraLensDirection? _currentCameraType;

// Truyền xuống image processing
await _imageProcessingService.processImage(
  imagePath,
  cameraType: _currentCameraType,
);
```

### 2. Smart Orientation Processing
```dart
// Xử lý front camera mirror effect
if (cameraType == CameraLensDirection.front && CameraConfig.enableFrontCameraFlip) {
  image = img.flipHorizontal(image);
}

// EXIF orientation fix
image = img.bakeOrientation(image);
```

### 3. Configuration Control
```dart
// lib/core/config/camera_config.dart
class CameraConfig {
  static const bool enableOrientationDebug = true;
  static const bool enableFrontCameraFlip = true;
  static const bool enableAdditionalOrientationFixes = true;
}
```

## 🔧 Cách sử dụng

### Enable/Disable Features
Chỉnh sửa `lib/core/config/camera_config.dart`:
```dart
static const bool enableOrientationDebug = true;   // Debug logs
static const bool enableFrontCameraFlip = true;    // Front camera flip
```

### Debug Logs
Khi enable debug, sẽ thấy logs như:
```
=== IMAGE ORIENTATION DEBUG ===
File: /path/to/image.jpg
Original size: 1920x1080
Has EXIF: true
EXIF Orientation: 6
Applied horizontal flip for front camera
=== END DEBUG ===
```

## 🚀 Tự động hoạt động
- ✅ Face scanning camera
- ✅ Palm scanning camera  
- ✅ Cả front và back camera
- ✅ Tất cả thiết bị Android

## 🛠️ Troubleshooting

### Ảnh vẫn bị xoay?
1. Kiểm tra debug logs
2. Xem EXIF orientation value
3. Có thể cần device-specific config

### Front camera vẫn bị mirror?
1. Đảm bảo `enableFrontCameraFlip = true`
2. Kiểm tra camera type detection

### Không thấy debug logs?
1. Đảm bảo `enableOrientationDebug = true`
2. Kiểm tra log level

## 📁 Files đã thay đổi
- `lib/core/services/camera_service.dart` - Camera type tracking
- `lib/core/services/image_processing_service.dart` - Orientation logic
- `lib/core/config/camera_config.dart` - Configuration
- `docs/camera_orientation_fix.md` - Chi tiết documentation
- `test/core/services/image_processing_service_test.dart` - Tests

## ✅ Kết quả
- Không còn hình ảnh bị xoay ngang
- Front camera không còn mirror effect
- Debug capabilities để trace issues
- Có thể tùy chỉnh cho các thiết bị khác nhau
