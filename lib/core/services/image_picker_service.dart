import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../utils/logger.dart';
import '../errors/exceptions.dart';

/// Service for handling image selection from gallery or camera
class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      AppLogger.info('Opening gallery to pick image');
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        AppLogger.info('Image selected from gallery: ${image.path}');
        
        // Validate file exists
        final file = File(image.path);
        if (!file.existsSync()) {
          throw const ValidationException(
            message: 'Selected image file does not exist',
            code: 'FILE_NOT_FOUND',
          );
        }

        // Validate file size (max 10MB)
        final fileSize = await file.length();
        const maxSize = 10 * 1024 * 1024; // 10MB
        if (fileSize > maxSize) {
          throw const ValidationException(
            message: 'Image file is too large. Maximum size is 10MB.',
            code: 'FILE_TOO_LARGE',
          );
        }

        // Validate file extension
        final extension = image.path.toLowerCase().split('.').last;
        if (!['jpg', 'jpeg', 'png', 'bmp', 'webp'].contains(extension)) {
          throw const ValidationException(
            message: 'Unsupported image format. Please select JPG, PNG, BMP, or WebP.',
            code: 'UNSUPPORTED_FORMAT',
          );
        }

        // Fix EXIF orientation
        await _fixImageOrientation(image.path);

        return image.path;
      } else {
        AppLogger.info('No image selected from gallery');
        return null;
      }
    } catch (e) {
      AppLogger.error('Failed to pick image from gallery', e);
      
      if (e is ValidationException) {
        rethrow;
      }
      
      throw ValidationException(
        message: 'Failed to select image: ${e.toString()}',
        code: 'IMAGE_PICKER_ERROR',
      );
    }
  }

  /// Fix image orientation based on EXIF data
  Future<void> _fixImageOrientation(String imagePath) async {
    try {
      AppLogger.info('Checking and fixing image orientation for: $imagePath');
      
      // Read the image file
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      
      // Decode the image
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        AppLogger.warning('Failed to decode image for orientation fix');
        return;
      }

      // The image package automatically handles EXIF orientation when decoding
      // We just need to re-encode and save it
      // This removes the EXIF orientation tag and bakes the rotation into the image data
      
      // Encode back to the original format
      List<int>? encodedImage;
      final extension = imagePath.toLowerCase().split('.').last;
      
      if (extension == 'png') {
        encodedImage = img.encodePng(image);
      } else {
        // Default to JPEG for jpg, jpeg, and other formats
        encodedImage = img.encodeJpg(image, quality: 85);
      }

      // Save the corrected image back to the same path
      await imageFile.writeAsBytes(encodedImage);
      
      AppLogger.info('Image orientation fixed successfully');
    } catch (e) {
      // Log error but don't throw - orientation fix is not critical
      AppLogger.warning('Failed to fix image orientation (non-critical): $e');
    }
  }

  /// Pick image from camera
  Future<String?> pickImageFromCamera() async {
    try {
      AppLogger.info('Opening camera to take photo');
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        AppLogger.info('Image captured from camera: ${image.path}');
        
        // Validate file exists
        final file = File(image.path);
        if (!file.existsSync()) {
          throw const ValidationException(
            message: 'Captured image file does not exist',
            code: 'FILE_NOT_FOUND',
          );
        }

        return image.path;
      } else {
        AppLogger.info('No image captured from camera');
        return null;
      }
    } catch (e) {
      AppLogger.error('Failed to capture image from camera', e);
      
      if (e is ValidationException) {
        rethrow;
      }
      
      throw ValidationException(
        message: 'Failed to capture image: ${e.toString()}',
        code: 'CAMERA_PICKER_ERROR',
      );
    }
  }

  /// Show image source selection dialog
  Future<String?> showImageSourceDialog() async {
    // This method would typically show a dialog to choose between gallery and camera
    // For now, we'll just use gallery as the primary source
    return await pickImageFromGallery();
  }

  /// Validate if file is a valid image
  bool isValidImageFile(String? path) {
    if (path == null || path.isEmpty) return false;
    
    final file = File(path);
    if (!file.existsSync()) return false;
    
    final extension = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'bmp', 'webp'].contains(extension);
  }

  /// Get file size in bytes
  Future<int> getFileSize(String path) async {
    try {
      final file = File(path);
      return await file.length();
    } catch (e) {
      AppLogger.error('Failed to get file size', e);
      return 0;
    }
  }

  /// Get file size in human readable format
  Future<String> getFileSizeFormatted(String path) async {
    final bytes = await getFileSize(path);
    
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
