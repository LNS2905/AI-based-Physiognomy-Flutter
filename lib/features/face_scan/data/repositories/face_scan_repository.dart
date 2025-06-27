import '../../../../core/network/api_result.dart';
import '../../../../core/network/http_service.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
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
}
