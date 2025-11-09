import 'dart:async';
import '../../../../core/network/http_service.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/chat_request_model.dart';
import '../models/chat_message_model.dart';
import '../models/chat_start_model.dart';

/// Repository for handling AI chat API operations
class ChatRepository {
  final HttpService _httpService;

  ChatRepository({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  /// Start a new conversation
  /// Returns a map with conversationId and optional welcome message
  Future<ApiResult<Map<String, dynamic>>> startConversation(int userId, {int? chartId}) async {
    try {
      AppLogger.info('Starting new conversation for user: $userId');
      
      final request = ChatStartRequest(
        userId: userId,
        chartId: chartId,
      );
      
      // Chat API endpoint with /api/v1 prefix (ngrok backend)
      final response = await _httpService.post(
        '/api/v1/chat/start',
        body: request.toJson(),
      );

      // Backend response format:
      // {
      //   "success": true,
      //   "conversation_id": 42,
      //   "message": "Welcome message from backend..."
      // }
      final conversationId = response['conversation_id'] as int;
      final welcomeMessage = response['message'] as String?;
      
      AppLogger.info('Started conversation: $conversationId');
      return Success({
        'conversation_id': conversationId,
        'welcome_message': welcomeMessage,
      });
    } catch (e) {
      AppLogger.error('Failed to start conversation', e);
      return Error(_mapErrorToFailure(e));
    }
  }

  /// Send a message to the AI and get response
  Future<ApiResult<ChatMessageModel>> sendMessage(ChatRequestModel request) async {
    try {
      AppLogger.info('Sending chat message: ${request.message} to conversation: ${request.conversationId}');
      
      // Chat API endpoint with /api/v1 prefix (ngrok backend)
      final response = await _httpService.post(
        '/api/v1/chat/message',
        body: request.toJson(),
      );

      // Backend response format:
      // {
      //   "success": true,
      //   "answer": "AI response...",
      //   "tools_used": [],
      //   "conversation_id": 1
      // }
      final messageContent = response['answer'] as String? ?? 
                            response['message'] as String? ?? 
                            'No response';
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Convert API response to ChatMessageModel
      final aiMessage = ChatMessageModel.ai(
        id: messageId,
        content: messageContent,
        isDelivered: true,
        metadata: response,
      );

      AppLogger.info('Received AI response: ${aiMessage.id}');
      return Success(aiMessage);
    } catch (e) {
      AppLogger.error('Failed to send chat message', e);
      return Error(_mapErrorToFailure(e));
    }
  }

  /// Get conversation history
  Future<ApiResult<List<ChatMessageModel>>> getConversationHistory(int conversationId) async {
    try {
      AppLogger.info('Fetching conversation history: $conversationId');
      
      // Chat API endpoint with /api/v1 prefix (ngrok backend)
      final response = await _httpService.get(
        '/api/v1/chat/history/$conversationId',
      );

      // Backend response format:
      // {
      //   "success": true,
      //   "messages": [
      //     {
      //       "id": 5,
      //       "conversationId": 36,
      //       "role": "user",
      //       "content": "...",
      //       "createAt": "..."
      //     }
      //   ]
      // }
      List<ChatMessageModel> messages = [];
      
      if (response.containsKey('messages') && response['messages'] is List) {
        final messagesList = response['messages'] as List;
        messages = messagesList.map((msg) {
          final isUser = msg['role'] == 'user';
          final content = msg['content']?.toString() ?? '';
          final id = msg['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
          
          return isUser
              ? ChatMessageModel.user(id: id, content: content)
              : ChatMessageModel.ai(id: id, content: content);
        }).toList();
      }
      
      AppLogger.info('Fetched ${messages.length} messages from conversation');
      return Success(messages);
    } catch (e) {
      AppLogger.error('Failed to fetch conversation history', e);
      return Error(_mapErrorToFailure(e));
    }
  }





  /// Map errors to appropriate failures
  Failure _mapErrorToFailure(dynamic error) {
    if (error is NetworkException) {
      return NetworkFailure(
        message: error.message,
        code: error.code,
      );
    } else if (error is ServerException) {
      return ServerFailure(
        message: error.message,
        code: error.code,
      );
    } else {
      return UnknownFailure(
        message: error.toString(),
        code: 'CHAT_ERROR',
      );
    }
  }
}
