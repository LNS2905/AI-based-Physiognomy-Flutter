import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/http_service.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/api_config.dart';
import '../models/face_scan_request_model.dart';
import '../models/face_scan_response_model.dart';

/// Repository for face scanning operations
class FaceScanRepository {
  final HttpService _httpService;

  FaceScanRepository({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  /// Start face analysis
  Future<ApiResult<FaceScanResponseModel>> startFaceAnalysis(
    FaceScanRequestModel request,
  ) async {
    try {
      AppLogger.info('Starting face analysis');

      final response = await _httpService.post(
        'face-scan/analyze',
        body: request.toJson(),
      );

      final scanResponse = FaceScanResponseModel.fromJson(response);
      AppLogger.info('Face analysis started successfully: ${scanResponse.id}');
      return Success(scanResponse);
    } catch (e) {
      AppLogger.error('Exception in startFaceAnalysis', e);
      return Error(
        UnknownFailure(
          message: 'Failed to start face analysis: ${e.toString()}',
          code: 'FACE_SCAN_ERROR',
        ),
      );
    }
  }

  /// Get face analysis status
  Future<ApiResult<FaceScanResponseModel>> getFaceAnalysisStatus(
    String analysisId,
  ) async {
    try {
      AppLogger.info('Getting face analysis status: $analysisId');

      final response = await _httpService.get(
        'face-scan/analyze/$analysisId',
      );

      final scanResponse = FaceScanResponseModel.fromJson(response);
      AppLogger.info('Face analysis status retrieved: ${scanResponse.status}');
      return Success(scanResponse);
    } catch (e) {
      AppLogger.error('Exception in getFaceAnalysisStatus', e);
      return Error(
        UnknownFailure(
          message: 'Failed to get analysis status: ${e.toString()}',
          code: 'FACE_SCAN_STATUS_ERROR',
        ),
      );
    }
  }

  /// Upload image for face analysis
  Future<ApiResult<Map<String, dynamic>>> uploadImage(
    String imagePath,
  ) async {
    try {
      AppLogger.info('Uploading image for face analysis');

      final response = await _httpService.uploadFile(
        'face-scan/upload',
        filePath: imagePath,
        fieldName: 'image',
      );

      return response;
    } catch (e) {
      AppLogger.error('Exception in uploadImage', e);
      return Error(
        UnknownFailure(
          message: 'Failed to upload image: ${e.toString()}',
          code: 'IMAGE_UPLOAD_ERROR',
        ),
      );
    }
  }

  /// Get user's face analysis history
  Future<ApiResult<List<FaceScanResponseModel>>> getFaceAnalysisHistory() async {
    try {
      AppLogger.info('Getting face analysis history');

      final response = await _httpService.get(
        'face-scan/history',
      );

      final List<dynamic> historyList = response['history'] ?? [];
      final history = historyList
          .map((item) => FaceScanResponseModel.fromJson(item))
          .toList();
      AppLogger.info('Face analysis history retrieved: ${history.length} items');
      return Success(history);
    } catch (e) {
      AppLogger.error('Exception in getFaceAnalysisHistory', e);
      return Error(
        UnknownFailure(
          message: 'Failed to get analysis history: ${e.toString()}',
          code: 'FACE_SCAN_HISTORY_ERROR',
        ),
      );
    }
  }

  /// Delete face analysis
  Future<ApiResult<bool>> deleteFaceAnalysis(String analysisId) async {
    try {
      AppLogger.info('Deleting face analysis: $analysisId');

      await _httpService.delete(
        'face-scan/analyze/$analysisId',
      );

      AppLogger.info('Face analysis deleted successfully');
      return const Success(true);
    } catch (e) {
      AppLogger.error('Exception in deleteFaceAnalysis', e);
      return Error(
        UnknownFailure(
          message: 'Failed to delete analysis: ${e.toString()}',
          code: 'FACE_SCAN_DELETE_ERROR',
        ),
      );
    }
  }

  /// Analyze face using direct API call (for uploaded images)
  Future<ApiResult<Map<String, dynamic>>> analyzeFaceDirectly(
    String imagePath,
  ) async {
    try {
      AppLogger.info('Analyzing face directly via API');

      final apiUrl = ApiConfig.currentFaceAnalysisUrl;
      AppLogger.info('Using API URL: $apiUrl');

      final file = File(imagePath);
      if (!file.existsSync()) {
        throw const ValidationException(
          message: 'Image file does not exist',
          code: 'FILE_NOT_FOUND',
        );
      }

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add headers for ngrok
      request.headers.addAll({
        'ngrok-skip-browser-warning': 'true',
        'Accept': 'application/json',
      });

      // Add file with correct field name and content type
      final contentType = _getContentType(imagePath);
      final multipartFile = await http.MultipartFile.fromPath(
        'file', // API expects 'file' field name
        imagePath,
        filename: path.basename(imagePath),
        contentType: contentType,
      );
      request.files.add(multipartFile);

      AppLogger.info('Request headers: ${request.headers}');
      AppLogger.info('Request files: ${request.files.length}');
      AppLogger.info('File field name: file');
      AppLogger.info('File name: ${path.basename(imagePath)}');
      AppLogger.info('File content type: $contentType');
      AppLogger.info('File extension: ${path.extension(imagePath)}');

      // Send request
      final streamedResponse = await request.send().timeout(
        ApiConfig.requestTimeout,
      );
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.info('Response status: ${response.statusCode}');
      AppLogger.info('Response headers: ${response.headers}');
      AppLogger.info('Response body length: ${response.body.length}');
      if (response.statusCode != 200) {
        AppLogger.error('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        AppLogger.info('Face analysis completed successfully');

        // Process zip response
        final analysisResult = await _processZipResponse(response.bodyBytes);
        return Success(analysisResult);
      } else {
        AppLogger.error('Face analysis failed with status: ${response.statusCode}');
        return Error(
          NetworkFailure(
            message: 'Face analysis failed: ${response.reasonPhrase}',
            code: 'API_ERROR_${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Exception in analyzeFaceDirectly', e);
      return Error(
        UnknownFailure(
          message: 'Failed to analyze face: ${e.toString()}',
          code: 'FACE_ANALYSIS_ERROR',
        ),
      );
    }
  }

  /// Process zip response from face analysis API
  Future<Map<String, dynamic>> _processZipResponse(Uint8List zipBytes) async {
    try {
      AppLogger.info('Processing zip response from face analysis');

      // Decode zip file
      final archive = ZipDecoder().decodeBytes(zipBytes);

      // Get temporary directory to save extracted files
      final tempDir = await getTemporaryDirectory();
      final extractDir = Directory(path.join(tempDir.path, 'face_analysis_${DateTime.now().millisecondsSinceEpoch}'));
      await extractDir.create(recursive: true);

      String? annotatedImagePath;
      String? reportImagePath;
      Map<String, dynamic>? analysisData;

      // Extract files from zip
      for (final file in archive) {
        if (file.isFile) {
          final filePath = path.join(extractDir.path, file.name);
          final extractedFile = File(filePath);
          await extractedFile.writeAsBytes(file.content as List<int>);

          // Process different file types
          switch (file.name) {
            case 'annotated_image.jpg':
              annotatedImagePath = filePath;
              AppLogger.info('Extracted annotated image: $filePath');
              break;
            case 'report.jpg':
              reportImagePath = filePath;
              AppLogger.info('Extracted report image: $filePath');
              break;
            case 'analysis.json':
              final jsonContent = utf8.decode(file.content as List<int>);
              analysisData = json.decode(jsonContent) as Map<String, dynamic>;
              AppLogger.info('Extracted analysis JSON data');
              break;
          }
        }
      }

      // Return structured result
      return {
        'success': true,
        'annotated_image_path': annotatedImagePath,
        'report_image_path': reportImagePath,
        'analysis_data': analysisData,
        'extract_directory': extractDir.path,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      AppLogger.error('Failed to process zip response', e);
      throw ValidationException(
        message: 'Failed to process analysis results: ${e.toString()}',
        code: 'ZIP_PROCESSING_ERROR',
      );
    }
  }

  /// Get content type based on file extension
  /// Supports: ["image/jpeg", "image/png", "image/webp", "image/heic", "image/heif"]
  MediaType _getContentType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.webp':
        return MediaType('image', 'webp');
      case '.heic':
        return MediaType('image', 'heic');
      case '.heif':
        return MediaType('image', 'heif');
      default:
        // Default to JPEG for unknown image types
        return MediaType('image', 'jpeg');
    }
  }
}
