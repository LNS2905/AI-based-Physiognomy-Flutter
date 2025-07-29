import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../errors/exceptions.dart';
import '../utils/logger.dart';
import 'image_processing_service.dart';

/// Service for handling camera operations following the app's architecture patterns
class CameraService {
  static CameraService? _instance;
  static CameraService get instance => _instance ??= CameraService._();
  
  CameraService._();

  List<CameraDescription>? _cameras;
  CameraController? _controller;
  bool _isInitialized = false;
  CameraLensDirection? _currentCameraType;
  final ImageProcessingService _imageProcessingService = ImageProcessingService();

  /// Get available cameras
  List<CameraDescription>? get cameras => _cameras;
  
  /// Get camera controller
  CameraController? get controller => _controller;
  
  /// Check if camera is initialized
  bool get isInitialized => _isInitialized;

  /// Get current camera type
  CameraLensDirection? get currentCameraType => _currentCameraType;

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

  /// Request camera permissions (simplified for better compatibility)
  Future<bool> requestPermissions() async {
    try {
      AppLogger.info('Requesting camera permissions');

      // For development, we'll rely on the camera plugin's built-in permission handling
      // The camera plugin will automatically request permissions when needed
      AppLogger.info('Camera permissions will be handled by camera plugin');
      return true;
    } catch (e) {
      AppLogger.error('Failed to request camera permissions', e);
      throw ValidationException(
        message: 'Failed to request permissions: ${e.toString()}',
        code: 'PERMISSION_ERROR',
      );
    }
  }

  /// Check if camera permissions are granted (simplified)
  Future<bool> hasPermissions() async {
    try {
      // For development, we'll assume permissions are available
      // The camera plugin will handle permission requests automatically
      return true;
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

      // The camera plugin will handle permissions automatically
      AppLogger.info('Starting camera with automatic permission handling');

      // Use front camera by default for face scanning, fallback to first available
      final selectedCamera = camera ?? 
          _cameras!.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras!.first,
          );

      AppLogger.info('Starting camera: ${selectedCamera.name}');

      // Store current camera type
      _currentCameraType = selectedCamera.lensDirection;

      // Dispose existing controller if any
      await stopCamera();

      // Create new controller with minimal configuration
      _controller = CameraController(
        selectedCamera,
        resolution,
        enableAudio: enableAudio,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Initialize controller
      await _controller!.initialize();

      // Lock capture orientation to portrait to prevent orientation tracking
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);

      AppLogger.info('Camera started successfully with locked orientation');
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

      // Debug original image orientation
      await _imageProcessingService.debugImageOrientation(savedFile.path);

      // Process image to fix orientation and optimize
      final String processedPath = await _imageProcessingService.processImage(
        savedFile.path,
        cameraType: _currentCameraType,
      );

      // If processing created a new file, clean up the original
      if (processedPath != savedFile.path) {
        try {
          await savedFile.delete();
          AppLogger.info('Cleaned up original unprocessed image');
        } catch (e) {
          AppLogger.warning('Failed to delete original image', e);
        }
      }

      AppLogger.info('Image processed and ready: $processedPath');
      return processedPath;
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
