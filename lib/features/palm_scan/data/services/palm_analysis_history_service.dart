import '../../../../core/network/http_service.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';
import '../models/palm_analysis_server_model.dart';

/// Service for managing palm analysis history data from server API
class PalmAnalysisHistoryService {
  final HttpService _httpService;
  final EnhancedAuthProvider _authProvider;

  PalmAnalysisHistoryService({
    HttpService? httpService,
    required EnhancedAuthProvider authProvider,
  })  : _httpService = httpService ?? HttpService(),
        _authProvider = authProvider;

  /// Get palm analysis history for current user
  Future<ApiResult<List<PalmAnalysisServerModel>>> getPalmAnalysisHistory() async {
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

      // Parse response - the API returns { "success": true, "data": [...] }
      final bool success = response['success'] ?? false;
      if (!success) {
        throw ServerException(
          message: 'Server returned unsuccessful response',
          code: 'SERVER_ERROR',
        );
      }

      final List<dynamic> dataList = response['data'] ?? [];
      final List<PalmAnalysisServerModel> historyItems = [];

      for (int i = 0; i < dataList.length; i++) {
        final item = dataList[i];
        try {
          // Parse server response using PalmAnalysisServerModel
          final serverModel = PalmAnalysisServerModel.fromJson(item);
          historyItems.add(serverModel);
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

  /// Get a specific palm analysis by ID
  Future<ApiResult<PalmAnalysisServerModel>> getPalmAnalysisById(int analysisId) async {
    try {
      AppLogger.info('Getting palm analysis by ID: $analysisId');

      // For now, we'll get all history and find the specific item
      // In a real implementation, you might have a dedicated endpoint
      final historyResult = await getPalmAnalysisHistory();
      
      if (historyResult is Success<List<PalmAnalysisServerModel>>) {
        final analysis = historyResult.data.firstWhere(
          (item) => item.id == analysisId,
          orElse: () => throw Exception('Analysis not found'),
        );
        
        AppLogger.info('Palm analysis found: ${analysis.id}');
        return Success(analysis);
      } else {
        return Error(historyResult.failure!);
      }
    } catch (e) {
      AppLogger.error('Exception in getPalmAnalysisById', e);
      return Error(UnknownFailure(
        message: 'Failed to get palm analysis: ${e.toString()}',
        code: 'PALM_ANALYSIS_BY_ID_ERROR',
      ));
    }
  }

  /// Save palm analysis result to server
  Future<ApiResult<PalmAnalysisServerModel>> savePalmAnalysis({
    required String annotatedImage,
    required String summaryText,
    required List<InterpretationServerModel> interpretations,
    required List<LifeAspectServerModel> lifeAspects,
    int palmLinesDetected = 0,
    int detectedHeartLine = 0,
    int detectedHeadLine = 0,
    int detectedLifeLine = 0,
    int detectedFateLine = 0,
    String targetLines = 'heart,head,life,fate',
    double imageHeight = 480.0,
    double imageWidth = 640.0,
    double imageChannels = 3.0,
  }) async {
    final userId = _authProvider.userId;
    if (userId == null) {
      AppLogger.error('No current user found for saving palm analysis');
      return Error(AuthFailure(
        message: 'User not authenticated',
        code: 'NO_CURRENT_USER',
      ));
    }

    try {
      AppLogger.info('Saving palm analysis for user: $userId');

      final requestBody = {
        'userId': userId,
        'annotatedImage': annotatedImage,
        'palmLinesDetected': palmLinesDetected,
        'detectedHeartLine': detectedHeartLine,
        'detectedHeadLine': detectedHeadLine,
        'detectedLifeLine': detectedLifeLine,
        'detectedFateLine': detectedFateLine,
        'targetLines': targetLines,
        'imageHeight': imageHeight,
        'imageWidth': imageWidth,
        'imageChannels': imageChannels,
        'summaryText': summaryText,
        'interpretations': interpretations.map((e) => e.toJson()).toList(),
        'lifeAspects': lifeAspects.map((e) => e.toJson()).toList(),
      };

      final response = await _httpService.post(
        '/palm-analysis',
        body: requestBody,
      );

      // Parse the saved analysis from response
      final savedAnalysis = PalmAnalysisServerModel.fromJson(response['data']);
      
      AppLogger.info('Palm analysis saved successfully: ${savedAnalysis.id}');
      return Success(savedAnalysis);
    } on AuthException catch (e) {
      AppLogger.error('Authentication error in savePalmAnalysis', e);
      return Error(AuthFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      AppLogger.error('Network error in savePalmAnalysis', e);
      return Error(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      AppLogger.error('Server error in savePalmAnalysis', e);
      return Error(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      AppLogger.error('Exception in savePalmAnalysis', e);
      return Error(UnknownFailure(
        message: 'Failed to save palm analysis: ${e.toString()}',
        code: 'SAVE_PALM_ANALYSIS_ERROR',
      ));
    }
  }

  /// Delete a palm analysis by ID
  Future<ApiResult<bool>> deletePalmAnalysis(int analysisId) async {
    try {
      AppLogger.info('Deleting palm analysis: $analysisId');

      await _httpService.delete('/palm-analysis/$analysisId');
      
      AppLogger.info('Palm analysis deleted successfully: $analysisId');
      return const Success(true);
    } on AuthException catch (e) {
      AppLogger.error('Authentication error in deletePalmAnalysis', e);
      return Error(AuthFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      AppLogger.error('Network error in deletePalmAnalysis', e);
      return Error(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      AppLogger.error('Server error in deletePalmAnalysis', e);
      return Error(ServerFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      AppLogger.error('Exception in deletePalmAnalysis', e);
      return Error(UnknownFailure(
        message: 'Failed to delete palm analysis: ${e.toString()}',
        code: 'DELETE_PALM_ANALYSIS_ERROR',
      ));
    }
  }
}
