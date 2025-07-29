/// Camera configuration for orientation handling and device-specific fixes
class CameraConfig {
  static const bool enableOrientationDebug = true;
  static const bool enableFrontCameraFlip = true;
  static const bool enableAdditionalOrientationFixes = true;
  
  /// Device-specific orientation fixes
  /// These can be adjusted based on testing with different devices
  static const Map<String, Map<String, dynamic>> deviceSpecificFixes = {
    'default': {
      'frontCameraFlip': true,
      'backCameraFlip': false,
      'additionalRotation': 0,
    },
    // Add device-specific configurations here if needed
    // 'Samsung': {
    //   'frontCameraFlip': true,
    //   'backCameraFlip': false,
    //   'additionalRotation': 0,
    // },
  };
  
  /// Get device-specific configuration
  static Map<String, dynamic> getDeviceConfig(String? deviceModel) {
    return deviceSpecificFixes[deviceModel] ?? deviceSpecificFixes['default']!;
  }
}
