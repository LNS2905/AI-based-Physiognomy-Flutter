import '../../../../core/network/http_service.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../face_scan/data/models/cloudinary_analysis_response_model.dart';
import '../../../palm_scan/data/models/palm_analysis_response_model.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';
import '../models/history_item_model.dart';

/// Repository for managing history data from API
class HistoryRepository {
  final HttpService _httpService;
  final EnhancedAuthProvider _authProvider;

  HistoryRepository({
    HttpService? httpService,
    required EnhancedAuthProvider authProvider,
  })  : _httpService = httpService ?? HttpService(),
        _authProvider = authProvider;

  /// Get facial analysis history for current user
  Future<ApiResult<List<FaceAnalysisHistoryModel>>> getFacialAnalysisHistory() async {
    final userId = _authProvider.userId;
    if (userId == null) {
      AppLogger.error('No current user found for facial analysis history');
      return Error(AuthFailure(
        message: 'User not authenticated',
        code: 'NO_CURRENT_USER',
      ));
    }
    try {
      AppLogger.info('Getting facial analysis history for user: $userId');

      final response = await _httpService.get(
        '/facial-analysis/user/$userId',
      );

      // Parse response - assuming it returns a list of facial analysis
      final List<dynamic> dataList = response['data'] ?? [];
      final List<FaceAnalysisHistoryModel> historyItems = [];

      for (int i = 0; i < dataList.length; i++) {
        final item = dataList[i];
        try {
          // Create CloudinaryAnalysisResponseModel from API data
          final analysisResult = CloudinaryAnalysisResponseModel.fromJson(item);
          
          // Create history item
          final historyItem = FaceAnalysisHistoryModel.fromAnalysis(
            id: 'face_${item['id'] ?? i}',
            analysisResult: analysisResult,
            originalImageUrl: item['originalImageUrl'] ?? '',
            annotatedImageUrl: item['annotatedImageUrl'] ?? '',
            reportUrl: item['reportUrl'],
            metadata: {
              'analysis_version': '1.0.0',
              'device_type': 'mobile',
              'api_source': true,
            },
          );

          historyItems.add(historyItem.copyWith(
            createdAt: item['createdAt'] != null 
                ? DateTime.parse(item['createdAt']) 
                : DateTime.now(),
            updatedAt: item['updatedAt'] != null 
                ? DateTime.parse(item['updatedAt']) 
                : DateTime.now(),
          ));
        } catch (e) {
          AppLogger.warning('Failed to parse facial analysis item $i: $e');
          continue;
        }
      }

      AppLogger.info('Facial analysis history retrieved: ${historyItems.length} items');
      return Success(historyItems);
    } on AuthException catch (e) {
      AppLogger.error('Authentication error in getFacialAnalysisHistory', e);
      return Error(AuthFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      AppLogger.error('Network error in getFacialAnalysisHistory', e);
      return Error(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      AppLogger.error('Server error in getFacialAnalysisHistory', e);
      return Error(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      AppLogger.error('Exception in getFacialAnalysisHistory', e);
      return Error(UnknownFailure(
        message: 'Failed to get facial analysis history: ${e.toString()}',
        code: 'FACIAL_ANALYSIS_HISTORY_ERROR',
      ));
    }
  }

  /// Get palm analysis history for current user
  Future<ApiResult<List<PalmAnalysisHistoryModel>>> getPalmAnalysisHistory() async {
    final userId = _authProvider.userId;
    if (userId == null) {
      AppLogger.error('No current user found for palm analysis history');
      return Error(AuthFailure(
        message: 'User not authenticated',
        code: 'NO_CURRENT_USER',
      ));
    }
    try {
      AppLogger.info('Getting palm analysis history for user: $userId');

      final response = await _httpService.get(
        '/palm-analysis/user/$userId',
      );

      // Parse response - assuming it returns a list of palm analysis
      final List<dynamic> dataList = response['data'] ?? [];
      final List<PalmAnalysisHistoryModel> historyItems = [];

      for (int i = 0; i < dataList.length; i++) {
        final item = dataList[i];
        try {
          // Create PalmAnalysisResponseModel from API data
          final analysisResult = PalmAnalysisResponseModel.fromJson(item);
          
          // Create history item
          final historyItem = PalmAnalysisHistoryModel.fromAnalysis(
            id: 'palm_${item['id'] ?? i}',
            analysisResult: analysisResult,
            originalImageUrl: item['originalImageUrl'] ?? '',
            annotatedImageUrl: item['annotatedImageUrl'] ?? '',
            comparisonImageUrl: item['comparisonImageUrl'] ?? '',
            metadata: {
              'analysis_version': '1.0.0',
              'device_type': 'mobile',
              'api_source': true,
            },
          );

          historyItems.add(historyItem.copyWith(
            createdAt: item['createdAt'] != null 
                ? DateTime.parse(item['createdAt']) 
                : DateTime.now(),
            updatedAt: item['updatedAt'] != null 
                ? DateTime.parse(item['updatedAt']) 
                : DateTime.now(),
          ));
        } catch (e) {
          AppLogger.warning('Failed to parse palm analysis item $i: $e');
          continue;
        }
      }

      AppLogger.info('Palm analysis history retrieved: ${historyItems.length} items');
      return Success(historyItems);
    } on AuthException catch (e) {
      AppLogger.error('Authentication error in getPalmAnalysisHistory', e);
      return Error(AuthFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      AppLogger.error('Network error in getPalmAnalysisHistory', e);
      return Error(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      AppLogger.error('Server error in getPalmAnalysisHistory', e);
      return Error(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      AppLogger.error('Exception in getPalmAnalysisHistory', e);
      return Error(UnknownFailure(
        message: 'Failed to get palm analysis history: ${e.toString()}',
        code: 'PALM_ANALYSIS_HISTORY_ERROR',
      ));
    }
  }

  /// Get all history items for current user (combines facial and palm analysis)
  Future<ApiResult<List<HistoryItemModel>>> getAllHistory() async {
    final userId = _authProvider.userId;
    if (userId == null) {
      AppLogger.error('No current user found for history');
      return Error(AuthFailure(
        message: 'User not authenticated',
        code: 'NO_CURRENT_USER',
      ));
    }
    try {
      AppLogger.info('Getting all history for user: $userId');

      // Get both facial and palm analysis history concurrently
      final results = await Future.wait([
        getFacialAnalysisHistory(),
        getPalmAnalysisHistory(),
      ]);

      final List<HistoryItemModel> allHistoryItems = [];

      // Add facial analysis history
      final facialResult = results[0];
      if (facialResult is Success<List<FaceAnalysisHistoryModel>>) {
        allHistoryItems.addAll(facialResult.data);
      } else {
        AppLogger.warning('Failed to get facial analysis history: ${facialResult.failure?.message}');
      }

      // Add palm analysis history
      final palmResult = results[1];
      if (palmResult is Success<List<PalmAnalysisHistoryModel>>) {
        allHistoryItems.addAll(palmResult.data);
      } else {
        AppLogger.warning('Failed to get palm analysis history: ${palmResult.failure?.message}');
      }

      // Sort by creation date (newest first)
      allHistoryItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      AppLogger.info('All history retrieved: ${allHistoryItems.length} items');
      return Success(allHistoryItems);
    } catch (e) {
      AppLogger.error('Exception in getAllHistory', e);
      return Error(UnknownFailure(
        message: 'Failed to get all history: ${e.toString()}',
        code: 'ALL_HISTORY_ERROR',
      ));
    }
  }
}
