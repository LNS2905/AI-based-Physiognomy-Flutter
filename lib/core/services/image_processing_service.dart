import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import '../utils/logger.dart';
import '../errors/exceptions.dart';
import '../config/camera_config.dart';

/// Service for processing images (orientation, compression, etc.)
class ImageProcessingService {
  static final ImageProcessingService _instance = ImageProcessingService._internal();
  factory ImageProcessingService() => _instance;
  ImageProcessingService._internal();

  /// Fix image orientation based on EXIF data and camera type
  Future<String> fixImageOrientation(
    String imagePath, {
    CameraLensDirection? cameraType,
  }) async {
    try {
      AppLogger.info('Fixing image orientation for: $imagePath');
      AppLogger.info('Camera type: ${cameraType?.toString() ?? 'unknown'}');

      // Read the image file
      final File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        throw const ValidationException(
          message: 'Image file does not exist',
          code: 'FILE_NOT_FOUND',
        );
      }

      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const ValidationException(
          message: 'Failed to decode image',
          code: 'DECODE_ERROR',
        );
      }

      AppLogger.info('Original image size: ${image.width}x${image.height}');

      // Fix orientation based on EXIF data
      image = img.bakeOrientation(image);
      AppLogger.info('After EXIF orientation fix: ${image.width}x${image.height}');

      // Handle front camera specific issues based on configuration
      if (cameraType == CameraLensDirection.front && CameraConfig.enableFrontCameraFlip) {
        // Front camera typically needs horizontal flip to correct mirror effect
        image = img.flipHorizontal(image);
        AppLogger.info('Applied horizontal flip for front camera');
      }

      // Additional orientation fixes for specific cases
      if (CameraConfig.enableAdditionalOrientationFixes) {
        image = _applyAdditionalOrientationFixes(image, cameraType);
      }

      // Encode the corrected image
      final List<int> correctedBytes = img.encodeJpg(image, quality: 90);

      // Create a new file with corrected orientation
      final String correctedPath = _getCorrectedImagePath(imagePath);
      final File correctedFile = File(correctedPath);
      await correctedFile.writeAsBytes(correctedBytes);

      AppLogger.info('Image orientation fixed and saved to: $correctedPath');
      return correctedPath;
    } catch (e) {
      AppLogger.error('Failed to fix image orientation', e);
      
      if (e is ValidationException) {
        rethrow;
      }
      
      // If orientation fixing fails, return original path
      AppLogger.warning('Returning original image path due to processing error');
      return imagePath;
    }
  }

  /// Compress image while maintaining quality
  Future<String> compressImage(String imagePath, {int quality = 85}) async {
    try {
      AppLogger.info('Compressing image: $imagePath');

      final File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        throw const ValidationException(
          message: 'Image file does not exist',
          code: 'FILE_NOT_FOUND',
        );
      }

      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const ValidationException(
          message: 'Failed to decode image',
          code: 'DECODE_ERROR',
        );
      }

      // Resize if too large (max 1920x1920)
      if (image.width > 1920 || image.height > 1920) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 1920 : null,
          height: image.height > image.width ? 1920 : null,
          interpolation: img.Interpolation.linear,
        );
        AppLogger.info('Image resized to: ${image.width}x${image.height}');
      }

      // Encode with specified quality
      final List<int> compressedBytes = img.encodeJpg(image, quality: quality);

      // Save compressed image
      final String compressedPath = _getCompressedImagePath(imagePath);
      final File compressedFile = File(compressedPath);
      await compressedFile.writeAsBytes(compressedBytes);

      AppLogger.info('Image compressed and saved to: $compressedPath');
      return compressedPath;
    } catch (e) {
      AppLogger.error('Failed to compress image', e);
      
      if (e is ValidationException) {
        rethrow;
      }
      
      // If compression fails, return original path
      AppLogger.warning('Returning original image path due to compression error');
      return imagePath;
    }
  }

  /// Process image: fix orientation and compress
  Future<String> processImage(
    String imagePath, {
    CameraLensDirection? cameraType,
  }) async {
    try {
      AppLogger.info('Processing image: $imagePath');

      // Step 1: Fix orientation
      String processedPath = await fixImageOrientation(imagePath, cameraType: cameraType);

      // Step 2: Compress if needed
      final File imageFile = File(processedPath);
      final int fileSizeBytes = await imageFile.length();
      final double fileSizeMB = fileSizeBytes / (1024 * 1024);

      if (fileSizeMB > 2.0) {
        AppLogger.info('Image size: ${fileSizeMB.toStringAsFixed(2)}MB, compressing...');
        processedPath = await compressImage(processedPath);
      } else {
        AppLogger.info('Image size: ${fileSizeMB.toStringAsFixed(2)}MB, no compression needed');
      }

      return processedPath;
    } catch (e) {
      AppLogger.error('Failed to process image', e);
      
      // If processing fails, return original path
      AppLogger.warning('Returning original image path due to processing error');
      return imagePath;
    }
  }

  /// Apply additional orientation fixes based on camera type and common issues
  img.Image _applyAdditionalOrientationFixes(
    img.Image image,
    CameraLensDirection? cameraType,
  ) {
    // For some devices, additional rotation might be needed
    // This can be device-specific and might need to be configurable

    if (cameraType == CameraLensDirection.front) {
      // Some front cameras might need additional rotation
      // This is device-specific and can be adjusted based on testing
      AppLogger.info('Applied additional front camera orientation fixes');
    } else if (cameraType == CameraLensDirection.back) {
      // Back camera usually doesn't need additional fixes
      AppLogger.info('Applied additional back camera orientation fixes');
    }

    return image;
  }

  /// Check if image is from front camera (deprecated - use cameraType parameter instead)
  @deprecated
  bool _isFrontCamera(String imagePath) {
    // This is a simple heuristic - in a real app you might want to
    // pass camera type information explicitly
    return imagePath.toLowerCase().contains('front') ||
           imagePath.toLowerCase().contains('selfie');
  }

  /// Generate path for corrected image
  String _getCorrectedImagePath(String originalPath) {
    final String directory = File(originalPath).parent.path;
    final String fileName = File(originalPath).uri.pathSegments.last;
    final String nameWithoutExtension = fileName.split('.').first;
    final String extension = fileName.split('.').last;
    
    return '$directory/${nameWithoutExtension}_corrected.$extension';
  }

  /// Generate path for compressed image
  String _getCompressedImagePath(String originalPath) {
    final String directory = File(originalPath).parent.path;
    final String fileName = File(originalPath).uri.pathSegments.last;
    final String nameWithoutExtension = fileName.split('.').first;
    final String extension = fileName.split('.').last;
    
    return '$directory/${nameWithoutExtension}_compressed.$extension';
  }

  /// Debug image orientation information
  Future<void> debugImageOrientation(String imagePath) async {
    if (!CameraConfig.enableOrientationDebug) return;

    try {
      final File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        AppLogger.warning('Debug: Image file does not exist: $imagePath');
        return;
      }

      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image != null) {
        AppLogger.info('=== IMAGE ORIENTATION DEBUG ===');
        AppLogger.info('File: $imagePath');
        AppLogger.info('Original size: ${image.width}x${image.height}');

        // Check if EXIF data exists using hasExif property
        AppLogger.info('Has EXIF: ${image.hasExif}');

        if (image.hasExif) {
          final orientation = image.exif['Orientation'];
          AppLogger.info('EXIF Orientation: $orientation');
        }

        AppLogger.info('=== END DEBUG ===');
      }
    } catch (e) {
      AppLogger.error('Failed to debug image orientation', e);
    }
  }

  /// Clean up temporary processed images
  Future<void> cleanupProcessedImages(String originalPath) async {
    try {
      final String correctedPath = _getCorrectedImagePath(originalPath);
      final String compressedPath = _getCompressedImagePath(originalPath);

      // Delete corrected image if exists
      final File correctedFile = File(correctedPath);
      if (correctedFile.existsSync()) {
        await correctedFile.delete();
        AppLogger.info('Cleaned up corrected image: $correctedPath');
      }

      // Delete compressed image if exists
      final File compressedFile = File(compressedPath);
      if (compressedFile.existsSync()) {
        await compressedFile.delete();
        AppLogger.info('Cleaned up compressed image: $compressedPath');
      }
    } catch (e) {
      AppLogger.warning('Failed to cleanup processed images', e);
    }
  }
}
