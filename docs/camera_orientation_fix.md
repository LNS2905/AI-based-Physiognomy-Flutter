# Camera Orientation Fix Documentation

## Vấn đề
Hình ảnh bị xoay ngang khi chụp ảnh gương mặt để phân tích, đặc biệt với front camera.

## Nguyên nhân chính

### 1. Front Camera Detection không chính xác
- Hàm `_isFrontCamera()` cũ chỉ dựa vào tên file
- Tên file được tạo theo timestamp, không chứa thông tin camera type

### 2. EXIF Orientation Processing
- EXIF data có thể không được ghi đúng hoặc bị mất
- Camera plugin có thể không xử lý orientation nhất quán

### 3. Front Camera Mirror Effect
- Front camera thường có mirror effect cần xử lý riêng
- Cần flip horizontal để sửa mirror effect

### 4. Device-specific Issues
- Một số thiết bị có behavior khác nhau với camera orientation

## Giải pháp đã triển khai

### 1. Cải thiện Camera Type Detection
```dart
// CameraService giờ track camera type
CameraLensDirection? _currentCameraType;

// Truyền camera type xuống image processing
final String processedPath = await _imageProcessingService.processImage(
  savedFile.path,
  cameraType: _currentCameraType,
);
```

### 2. Cải thiện Image Processing Logic
```dart
// Xử lý orientation dựa trên camera type thực tế
if (cameraType == CameraLensDirection.front && CameraConfig.enableFrontCameraFlip) {
  image = img.flipHorizontal(image);
  AppLogger.info('Applied horizontal flip for front camera');
}
```

### 3. Thêm Configuration System
```dart
// Camera configuration cho orientation handling
class CameraConfig {
  static const bool enableOrientationDebug = true;
  static const bool enableFrontCameraFlip = true;
  static const bool enableAdditionalOrientationFixes = true;
}
```

### 4. Thêm Debug Capabilities
```dart
// Debug image orientation information
await _imageProcessingService.debugImageOrientation(savedFile.path);
```

## Cách sử dụng

### 1. Enable/Disable Features
Chỉnh sửa `lib/core/config/camera_config.dart`:
```dart
static const bool enableOrientationDebug = true;  // Bật debug logging
static const bool enableFrontCameraFlip = true;   // Bật flip cho front camera
```

### 2. Device-specific Configuration
Thêm configuration cho thiết bị cụ thể:
```dart
static const Map<String, Map<String, dynamic>> deviceSpecificFixes = {
  'Samsung Galaxy S21': {
    'frontCameraFlip': true,
    'backCameraFlip': false,
    'additionalRotation': 0,
  },
};
```

### 3. Debug Orientation Issues
Khi `enableOrientationDebug = true`, sẽ có log chi tiết:
```
=== IMAGE ORIENTATION DEBUG ===
File: /path/to/image.jpg
Original size: 1920x1080
Has EXIF: true
EXIF Orientation: 6
=== END DEBUG ===
```

## Testing

### 1. Test với Front Camera
- Chụp ảnh với front camera
- Kiểm tra xem ảnh có bị mirror không
- Kiểm tra orientation có đúng không

### 2. Test với Back Camera
- Chụp ảnh với back camera
- Kiểm tra orientation có đúng không

### 3. Test trên nhiều thiết bị
- Test trên các thiết bị Android khác nhau
- Test trên iOS nếu có

## Troubleshooting

### 1. Ảnh vẫn bị xoay
- Kiểm tra debug log để xem EXIF orientation
- Có thể cần điều chỉnh `additionalRotation` trong config
- Kiểm tra device-specific configuration

### 2. Front camera vẫn bị mirror
- Đảm bảo `enableFrontCameraFlip = true`
- Kiểm tra camera type detection có đúng không

### 3. Performance issues
- Có thể tắt debug logging: `enableOrientationDebug = false`
- Kiểm tra image compression settings

## Future Improvements

1. **Auto-detect device-specific fixes**: Tự động detect và apply fixes cho từng loại thiết bị
2. **Machine learning orientation detection**: Sử dụng ML để detect orientation
3. **User preference settings**: Cho phép user tùy chỉnh orientation behavior
4. **Real-time preview orientation**: Fix orientation trong camera preview
