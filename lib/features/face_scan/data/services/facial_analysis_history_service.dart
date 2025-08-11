import '../../../../core/network/http_service.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';
import '../models/facial_analysis_server_model.dart';

/// Service for managing facial analysis history data from server API
class FacialAnalysisHistoryService {
  final HttpService _httpService;
  final EnhancedAuthProvider _authProvider;

  FacialAnalysisHistoryService({
    HttpService? httpService,
    required EnhancedAuthProvider authProvider,
  })  : _httpService = httpService ?? HttpService(),
        _authProvider = authProvider;

  /// Get facial analysis history for current user
  Future<ApiResult<List<FacialAnalysisServerModel>>> getFacialAnalysisHistory() async {
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

      // Parse response - the API returns { "success": true, "data": [...] }
      final bool success = response['success'] ?? false;
      if (!success) {
        throw ServerException(
          message: 'Server returned unsuccessful response',
          code: 'SERVER_ERROR',
        );
      }

      final List<dynamic> dataList = response['data'] ?? [];
      final List<FacialAnalysisServerModel> historyItems = [];

      for (int i = 0; i < dataList.length; i++) {
        final item = dataList[i];
        try {
          // Parse server response using FacialAnalysisServerModel
          final serverModel = FacialAnalysisServerModel.fromJson(item);
          historyItems.add(serverModel);
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

  /// Get a specific facial analysis by ID
  Future<ApiResult<FacialAnalysisServerModel>> getFacialAnalysisById(int analysisId) async {
    try {
      AppLogger.info('Getting facial analysis by ID: $analysisId');

      // For now, we'll get all history and find the specific item
      // In a real implementation, you might have a dedicated endpoint
      final historyResult = await getFacialAnalysisHistory();
      
      if (historyResult is Success<List<FacialAnalysisServerModel>>) {
        final analysis = historyResult.data.firstWhere(
          (item) => item.id == analysisId,
          orElse: () => throw Exception('Analysis not found'),
        );
        
        AppLogger.info('Facial analysis found: ${analysis.id}');
        return Success(analysis);
      } else {
        return Error(historyResult.failure!);
      }
    } catch (e) {
      AppLogger.error('Exception in getFacialAnalysisById', e);
      return Error(UnknownFailure(
        message: 'Failed to get facial analysis: ${e.toString()}',
        code: 'FACIAL_ANALYSIS_BY_ID_ERROR',
      ));
    }
  }

  /// Delete a facial analysis by ID
  Future<ApiResult<bool>> deleteFacialAnalysis(int analysisId) async {
    try {
      AppLogger.info('Deleting facial analysis: $analysisId');

      await _httpService.delete('/facial-analysis/$analysisId');
      
      AppLogger.info('Facial analysis deleted successfully: $analysisId');
      return const Success(true);
    } on AuthException catch (e) {
      AppLogger.error('Authentication error in deleteFacialAnalysis', e);
      return Error(AuthFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      AppLogger.error('Network error in deleteFacialAnalysis', e);
      return Error(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      AppLogger.error('Server error in deleteFacialAnalysis', e);
      return Error(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      AppLogger.error('Exception in deleteFacialAnalysis', e);
      return Error(UnknownFailure(
        message: 'Failed to delete facial analysis: ${e.toString()}',
        code: 'DELETE_FACIAL_ANALYSIS_ERROR',
      ));
    }
  }
}