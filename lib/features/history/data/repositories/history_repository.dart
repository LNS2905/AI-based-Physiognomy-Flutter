import '../../../../core/network/http_service.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../face_scan/data/models/cloudinary_analysis_response_model.dart';
import '../../../face_scan/data/models/facial_analysis_server_model.dart';
import '../../../palm_scan/data/models/palm_analysis_response_model.dart';
import '../../../palm_scan/data/models/palm_analysis_server_model.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';
import '../../../ai_conversation/data/repositories/chat_repository.dart';
import '../../../ai_conversation/data/models/conversation_model.dart';
import '../../../ai_conversation/data/models/chat_message_model.dart';
import '../models/history_item_model.dart';
import '../models/chat_history_model.dart';

/// Repository for managing history data from API
class HistoryRepository {
  final HttpService _httpService;
  final EnhancedAuthProvider _authProvider;
  final ChatRepository _chatRepository;

  HistoryRepository({
    HttpService? httpService,
    required EnhancedAuthProvider authProvider,
    ChatRepository? chatRepository,
  })  : _httpService = httpService ?? HttpService(),
        _authProvider = authProvider,
        _chatRepository = chatRepository ?? ChatRepository(httpService: httpService);

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
          // Parse server response using FacialAnalysisServerModel
          final serverModel = FacialAnalysisServerModel.fromJson(item);
          
          // Convert server model to CloudinaryAnalysisResponseModel for history display
          final analysisResult = _convertServerModelToCloudinaryModel(serverModel);
          
          // Create history item
          final historyItem = FaceAnalysisHistoryModel.fromAnalysis(
            id: 'face_${serverModel.id}',
            analysisResult: analysisResult,
            originalImageUrl: serverModel.annotatedImage,
            annotatedImageUrl: serverModel.annotatedImage,
            reportUrl: null,
            metadata: {
              'analysis_version': '1.0.0',
              'device_type': 'mobile',
              'api_source': true,
              'serverId': serverModel.id.toString(),
            },
          );

          // Use processedAt date from server
          final createdAtStr = serverModel.createdAt ?? serverModel.processedAt;
          historyItems.add(historyItem.copyWith(
            createdAt: DateTime.parse(createdAtStr),
            updatedAt: DateTime.parse(serverModel.updatedAt ?? createdAtStr),
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
          // Parse server response using PalmAnalysisServerModel
          final serverModel = PalmAnalysisServerModel.fromJson(item);
          
          // Convert server model to PalmAnalysisResponseModel for history display
          final analysisResult = _convertServerModelToResponseModel(serverModel);
          
          // Create history item with full server data in metadata
          final historyItem = PalmAnalysisHistoryModel.fromAnalysis(
            id: 'palm_${serverModel.id}',
            analysisResult: analysisResult,
            originalImageUrl: '',
            annotatedImageUrl: serverModel.annotatedImage,
            comparisonImageUrl: '',
            metadata: {
              'analysis_version': '1.0.0',
              'device_type': 'mobile',
              'api_source': true,
              'server_id': serverModel.id,
              'summaryText': serverModel.summaryText,
              'interpretations': serverModel.interpretations.map((i) => {
                'id': i.id,
                'analysisId': i.analysisId,
                'lineType': i.lineType,
                'pattern': i.pattern,
                'meaning': i.meaning,
                'lengthPx': i.lengthPx, // Keep as int
                'confidence': i.confidence,
                'createdAt': i.createdAt,
              }).toList(),
              'lifeAspects': serverModel.lifeAspects.map((a) => {
                'id': a.id,
                'analysisId': a.analysisId,
                'aspect': a.aspect,
                'content': a.content,
              }).toList(),
            },
          );

          historyItems.add(historyItem.copyWith(
            createdAt: DateTime.parse(serverModel.createdAt),
            updatedAt: DateTime.parse(serverModel.updatedAt),
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

  /// Get chat history for current user
  Future<ApiResult<List<ChatHistoryModel>>> getChatHistory() async {
    final userId = _authProvider.userId;
    if (userId == null) {
      AppLogger.error('No current user found for chat history');
      return Error(AuthFailure(
        message: 'User not authenticated',
        code: 'NO_CURRENT_USER',
      ));
    }

    try {
      AppLogger.info('Getting chat history for user: $userId');

      // 1. Get list of conversation IDs
      final conversationIdsResult = await _chatRepository.getUserConversations(userId.toString());
      
      AppLogger.info('Chat history API result type: ${conversationIdsResult.runtimeType}');
      
      if (conversationIdsResult is! Success<List<int>>) {
        AppLogger.error('Failed to get conversation IDs: ${conversationIdsResult.failure?.message}');
        return Error(conversationIdsResult.failure!);
      }

      final conversationIds = (conversationIdsResult as Success<List<int>>).data;
      AppLogger.info('Found ${conversationIds.length} conversation IDs: $conversationIds');
      final List<ChatHistoryModel> historyItems = [];

      // 2. Fetch details for each conversation
      // Limit to last 20 conversations to avoid performance issues
      final idsToFetch = conversationIds.take(20).toList();
      
      for (final id in idsToFetch) {
        try {
          final historyResult = await _chatRepository.getConversationHistory(id);
          
          if (historyResult is Success<List<ChatMessageModel>>) {
            final messages = historyResult.data;
            if (messages.isNotEmpty) {
              // Create conversation model
              // Infer timestamps from messages
              // Messages are likely sorted by time, but let's be safe
              messages.sort((a, b) {
                 // Assuming id is timestamp-based or we can parse a timestamp field if available
                 // For now, we'll rely on the order or metadata if available
                 return a.id.compareTo(b.id); 
              });
              
              // Try to get timestamp from message ID if it's a timestamp
              DateTime createdAt = DateTime.now();
              DateTime updatedAt = DateTime.now();
              
              if (messages.isNotEmpty) {
                try {
                  // Try to parse timestamp from ID (format: timestamp_random)
                  final parts = messages.first.id.split('_');
                  if (parts.isNotEmpty && int.tryParse(parts[0]) != null) {
                    createdAt = DateTime.fromMillisecondsSinceEpoch(int.parse(parts[0]));
                  }
                  
                  final lastParts = messages.last.id.split('_');
                  if (lastParts.isNotEmpty && int.tryParse(lastParts[0]) != null) {
                    updatedAt = DateTime.fromMillisecondsSinceEpoch(int.parse(lastParts[0]));
                  }
                } catch (_) {
                  // Fallback to current time if parsing fails
                }
              }

              // Generate title from first user message
              String title = 'Cuộc trò chuyện #$id';
              final firstUserMessage = messages.where((msg) => msg.sender == MessageSender.user).firstOrNull;
              if (firstUserMessage != null) {
                title = firstUserMessage.content.length > 30 
                    ? '${firstUserMessage.content.substring(0, 30)}...' 
                    : firstUserMessage.content;
              }

              final conversation = ConversationModel(
                id: id,
                title: title,
                messages: messages,
                createdAt: createdAt,
                updatedAt: updatedAt,
              );

              final historyItem = ChatHistoryModel.fromConversation(
                id: 'chat_$id',
                conversation: conversation,
              );

              historyItems.add(historyItem);
            }
          }
        } catch (e) {
          AppLogger.warning('Failed to fetch conversation $id: $e');
          continue;
        }
      }

      AppLogger.info('Chat history retrieved: ${historyItems.length} items');
      return Success(historyItems);
    } catch (e) {
      AppLogger.error('Exception in getChatHistory', e);
      return Error(UnknownFailure(
        message: 'Failed to get chat history: ${e.toString()}',
        code: 'CHAT_HISTORY_ERROR',
      ));
    }
  }

  /// Convert PalmAnalysisServerModel to PalmAnalysisResponseModel for display
  PalmAnalysisResponseModel _convertServerModelToResponseModel(PalmAnalysisServerModel serverModel) {
    // Assume 1 hand for palm analysis (server doesn't track actual hands)
    const assumedHandsDetected = 1;
    
    return PalmAnalysisResponseModel(
      status: 'success',
      message: 'Palm analysis completed',
      userId: serverModel.userId.toString(),
      processedAt: serverModel.createdAt,
      handsDetected: assumedHandsDetected, // Use fixed value instead of palmLinesDetected
      processingTime: 0.0,
      analysisType: 'palm_analysis',
      annotatedImageUrl: serverModel.annotatedImage,
      comparisonImageUrl: null,
      analysis: PalmAnalysisDataModel(
        handsDetected: assumedHandsDetected, // Use fixed value
        handsData: [],
        measurements: {},
        palmLines: {
          'heart': serverModel.detectedHeartLine.toDouble(),
          'head': serverModel.detectedHeadLine.toDouble(),
          'life': serverModel.detectedLifeLine.toDouble(),
          'fate': serverModel.detectedFateLine.toDouble(),
        },
        fingerAnalysis: {},
      ),
      measurementsSummary: MeasurementsSummaryModel(
        averagePalmWidth: serverModel.imageWidth,
        averageHandLength: serverModel.imageHeight,
        totalHands: assumedHandsDetected, // Use fixed value
        leftHands: 0,
        rightHands: 1, // Assume right hand
        palmTypes: [],
        confidenceScores: {
          'overall': 0.8,
        },
      ),
    );
  }

  /// Get all history items for current user (combines facial, palm, and chat analysis)
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

      // Get facial, palm, and chat analysis history concurrently
      final results = await Future.wait([
        getFacialAnalysisHistory(),
        getPalmAnalysisHistory(),
        getChatHistory(),
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

      // Add chat history
      final chatResult = results[2];
      if (chatResult is Success<List<ChatHistoryModel>>) {
        allHistoryItems.addAll(chatResult.data);
      } else {
        AppLogger.warning('Failed to get chat history: ${chatResult.failure?.message}');
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

  /// Convert FacialAnalysisServerModel to CloudinaryAnalysisResponseModel
  CloudinaryAnalysisResponseModel _convertServerModelToCloudinaryModel(FacialAnalysisServerModel serverModel) {
    return CloudinaryAnalysisResponseModel(
      status: 'success',
      message: 'Analysis completed successfully',
      userId: serverModel.userId,
      processedAt: serverModel.processedAt,
      annotatedImageUrl: serverModel.annotatedImage,
      analysis: CloudinaryAnalysisDataModel(
        metadata: CloudinaryMetadataModel(
          reportTitle: 'Facial Analysis Report',
          sourceFilename: 'historical_analysis_${serverModel.id}',
          timestampUTC: serverModel.processedAt,
        ),
        analysisResult: CloudinaryAnalysisResultModel(
          face: CloudinaryFaceModel(
            shape: CloudinaryFaceShapeModel(
              primary: serverModel.faceShape,
              probabilities: serverModel.probabilities,
            ),
            proportionality: CloudinaryProportionalityModel(
              overallHarmonyScore: serverModel.harmonyScore,
              harmonyScores: serverModel.harmonyDetails,
              metrics: serverModel.metrics.map((m) => CloudinaryMetricModel(
                label: m.label,
                pixels: m.pixels,
                percentage: m.percentage,
                orientation: m.orientation,
              )).toList(),
            ),
          ),
        ),
        result: serverModel.resultText,
      ),
    );
  }
}
