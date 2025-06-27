import 'dart:io';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../errors/exceptions.dart';
import '../utils/logger.dart';

/// Service for handling camera operations following the app's architecture patterns
class CameraService {
  static CameraService? _instance;
  static CameraService get instance => _instance ??= CameraService._();
  
  CameraService._();

  List<CameraDescription>? _cameras;
  CameraController? _controller;
  bool _isInitialized = false;

  /// Get available cameras
  List<CameraDescription>? get cameras => _cameras;
  
  /// Get camera controller
  CameraController? get controller => _controller;
  
  /// Check if camera is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize camera service
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing camera service');
      
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        throw const ValidationException(
          message: 'No cameras available on this device',
          code: 'NO_CAMERAS',
        );
      }

      AppLogger.info('Found ${_cameras!.length} cameras');
      _isInitialized = true;
    } catch (e) {
      AppLogger.error('Failed to initialize camera service', e);
      throw ValidationException(
        message: 'Failed to initialize camera: ${e.toString()}',
        code: 'CAMERA_INIT_ERROR',
      );
    }
  }

  /// Request camera permissions
  Future<bool> requestPermissions() async {
    try {
      AppLogger.info('Requesting camera permissions');
      
      final cameraStatus = await Permission.camera.request();
      
      if (cameraStatus.isGranted) {
        AppLogger.info('Camera permission granted');
        return true;
      } else if (cameraStatus.isDenied) {
        AppLogger.warning('Camera permission denied');
        return false;
      } else if (cameraStatus.isPermanentlyDenied) {
        AppLogger.warning('Camera permission permanently denied');
        throw const ValidationException(
          message: 'Camera permission is permanently denied. Please enable it in settings.',
          code: 'PERMISSION_PERMANENTLY_DENIED',
        );
      }
      
      return false;
    } catch (e) {
      AppLogger.error('Failed to request camera permissions', e);
      throw ValidationException(
        message: 'Failed to request permissions: ${e.toString()}',
        code: 'PERMISSION_ERROR',
      );
    }
  }

  /// Check if camera permissions are granted
  Future<bool> hasPermissions() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      AppLogger.error('Failed to check camera permissions', e);
      return false;
    }
  }

  /// Start camera with specified configuration
  Future<void> startCamera({
    CameraDescription? camera,
    ResolutionPreset resolution = ResolutionPreset.high,
    bool enableAudio = false,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Check permissions
      final hasPermission = await hasPermissions();
      if (!hasPermission) {
        final granted = await requestPermissions();
        if (!granted) {
          throw const ValidationException(
            message: 'Camera permission is required for face scanning',
            code: 'PERMISSION_REQUIRED',
          );
        }
      }

      // Use front camera by default for face scanning, fallback to first available
      final selectedCamera = camera ?? 
          _cameras!.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras!.first,
          );

      AppLogger.info('Starting camera: ${selectedCamera.name}');

      // Dispose existing controller if any
      await stopCamera();

      // Create new controller
      _controller = CameraController(
        selectedCamera,
        resolution,
        enableAudio: enableAudio,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Initialize controller
      await _controller!.initialize();
      
      AppLogger.info('Camera started successfully');
    } catch (e) {
      AppLogger.error('Failed to start camera', e);
      await stopCamera();
      
      if (e is ValidationException) {
        rethrow;
      }
      
      throw ValidationException(
        message: 'Failed to start camera: ${e.toString()}',
        code: 'CAMERA_START_ERROR',
      );
    }
  }

  /// Stop camera and dispose controller
  Future<void> stopCamera() async {
    try {
      if (_controller != null) {
        AppLogger.info('Stopping camera');
        await _controller!.dispose();
        _controller = null;
      }
    } catch (e) {
      AppLogger.error('Error stopping camera', e);
    }
  }

  /// Capture image and return file path
  Future<String> captureImage() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        throw const ValidationException(
          message: 'Camera is not initialized',
          code: 'CAMERA_NOT_INITIALIZED',
        );
      }

      AppLogger.info('Capturing image');

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'face_scan_$timestamp.jpg';
      final filePath = path.join(directory.path, fileName);

      // Capture image
      final XFile image = await _controller!.takePicture();
      
      // Copy to our desired location
      final File capturedFile = File(image.path);
      final File savedFile = await capturedFile.copy(filePath);
      
      // Clean up temporary file
      try {
        await capturedFile.delete();
      } catch (e) {
        AppLogger.warning('Failed to delete temporary file', e);
      }

      AppLogger.info('Image captured successfully: $filePath');
      return savedFile.path;
    } catch (e) {
      AppLogger.error('Failed to capture image', e);
      
      if (e is ValidationException) {
        rethrow;
      }
      
      throw ValidationException(
        message: 'Failed to capture image: ${e.toString()}',
        code: 'CAPTURE_ERROR',
      );
    }
  }

  /// Switch between front and back camera
  Future<void> switchCamera() async {
    try {
      if (_cameras == null || _cameras!.length < 2) {
        throw const ValidationException(
          message: 'No other camera available',
          code: 'NO_OTHER_CAMERA',
        );
      }

      final currentCamera = _controller?.description;
      if (currentCamera == null) return;

      // Find the other camera
      final otherCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection != currentCamera.lensDirection,
        orElse: () => _cameras!.first,
      );

      AppLogger.info('Switching to camera: ${otherCamera.name}');
      
      // Restart with new camera
      await startCamera(camera: otherCamera);
    } catch (e) {
      AppLogger.error('Failed to switch camera', e);
      
      if (e is ValidationException) {
        rethrow;
      }
      
      throw ValidationException(
        message: 'Failed to switch camera: ${e.toString()}',
        code: 'CAMERA_SWITCH_ERROR',
      );
    }
  }

  /// Dispose service and clean up resources
  Future<void> dispose() async {
    AppLogger.info('Disposing camera service');
    await stopCamera();
    _isInitialized = false;
    _cameras = null;
  }
}
