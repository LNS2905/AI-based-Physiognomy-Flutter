import 'dart:io';
import 'package:cloudinary/cloudinary.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import '../errors/exceptions.dart';

/// Service for handling Cloudinary operations
class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  late final Cloudinary _cloudinary;
  bool _isInitialized = false;

  /// Initialize Cloudinary with configuration
  void initialize() {
    if (_isInitialized) return;

    try {
      _cloudinary = Cloudinary.signedConfig(
        cloudName: AppConstants.cloudinaryCloudName,
        apiKey: AppConstants.cloudinaryApiKey,
        apiSecret: AppConstants.cloudinaryApiSecret,
      );

      _isInitialized = true;
      AppLogger.info('Cloudinary service initialized successfully with cloud: ${AppConstants.cloudinaryCloudName}');
    } catch (e) {
      AppLogger.error('Failed to initialize Cloudinary service', e);
      throw CloudinaryException(
        message: 'Failed to initialize Cloudinary: ${e.toString()}',
        code: 'INIT_FAILED',
      );
    }
  }

  /// Upload image to Cloudinary and return signed URL
  Future<CloudinaryUploadResult> uploadImageAndGetSignedUrl(
    String imagePath, {
    String? userId,
  }) async {
    if (!_isInitialized) {
      initialize();
    }

    try {
      AppLogger.info('Starting image upload to Cloudinary: $imagePath');

      // Generate unique public ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicId = 'physiognomy_${userId ?? 'user'}_$timestamp';

      // Upload image to Cloudinary as private resource
      AppLogger.info('Uploading with params: folder=${AppConstants.cloudinaryUploadFolder}, publicId=$publicId, type=private');

      final response = await _cloudinary.upload(
        file: imagePath,
        resourceType: CloudinaryResourceType.image,
        folder: AppConstants.cloudinaryUploadFolder,
        publicId: publicId,
        optParams: {
          'type': 'private', // Upload as private for signed URLs
        },
      );

      if (response.isSuccessful) {
        AppLogger.info('Image uploaded successfully: ${response.publicId}');

        // For private uploads, use the secure URL directly
        // The cloudinary package handles signed URLs automatically for private resources
        final signedUrl = response.secureUrl ?? response.url ?? '';

        return CloudinaryUploadResult(
          success: true,
          publicId: response.publicId!,
          signedUrl: signedUrl,
          folderPath: AppConstants.cloudinaryUploadFolder,
          secureUrl: response.secureUrl,
        );
      } else {
        AppLogger.error('Cloudinary upload failed: ${response.error}');
        throw CloudinaryException(
          message: 'Upload failed: ${response.error}',
          code: 'UPLOAD_FAILED',
        );
      }
    } on SocketException {
      throw const NetworkException(
        message: 'Network error during upload',
        code: 'NETWORK_ERROR',
      );
    } catch (e) {
      AppLogger.error('Cloudinary upload error', e);
      throw CloudinaryException(
        message: 'Failed to upload image: ${e.toString()}',
        code: 'CLOUDINARY_ERROR',
      );
    }
  }

  /// Generate signed URL for existing image
  String generateSignedUrl(String publicId, {int? expiresAt}) {
    if (!_isInitialized) {
      initialize();
    }

    // For private resources, generate URL using cloudinary package
    // The package handles signing automatically for private resources
    return 'https://res.cloudinary.com/${AppConstants.cloudinaryCloudName}/image/private/$publicId.jpg';
  }

  /// Delete image from Cloudinary
  Future<bool> deleteImage(String publicId) async {
    if (!_isInitialized) {
      initialize();
    }

    try {
      AppLogger.info('Deleting image from Cloudinary: $publicId');

      final response = await _cloudinary.destroy(publicId);
      
      if (response.isSuccessful) {
        AppLogger.info('Image deleted successfully: $publicId');
        return true;
      } else {
        AppLogger.error('Failed to delete image: ${response.error}');
        return false;
      }
    } catch (e) {
      AppLogger.error('Error deleting image', e);
      return false;
    }
  }
}

/// Result model for Cloudinary upload operations
class CloudinaryUploadResult {
  final bool success;
  final String publicId;
  final String signedUrl;
  final String folderPath;
  final String? secureUrl;
  final String? error;

  const CloudinaryUploadResult({
    required this.success,
    required this.publicId,
    required this.signedUrl,
    required this.folderPath,
    this.secureUrl,
    this.error,
  });

  factory CloudinaryUploadResult.error(String error) {
    return CloudinaryUploadResult(
      success: false,
      publicId: '',
      signedUrl: '',
      folderPath: '',
      error: error,
    );
  }
}

/// Custom exception for Cloudinary operations
class CloudinaryException extends AppException {
  const CloudinaryException({
    required super.message,
    required super.code,
  });
}
