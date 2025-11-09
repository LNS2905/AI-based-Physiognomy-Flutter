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
  Future<ApiResult<int>> startConversation(int userId, {int? chartId}) async {
    try {
      AppLogger.info('Starting new conversation for user: $userId');
      
      final request = ChatStartRequest(
        userId: userId,
        chartId: chartId,
      );
      
      final response = await _httpService.post(
        '/api/v1/chat/start',
        body: request.toJson(),
      );

      final conversationId = response['conversation_id'] as int;
      
      AppLogger.info('Started conversation: $conversationId');
      return Success(conversationId);
    } catch (e) {
      AppLogger.error('Failed to start conversation', e);
      return Error(_mapErrorToFailure(e));
    }
  }

  /// Send a message to the AI and get response
  Future<ApiResult<ChatMessageModel>> sendMessage(ChatRequestModel request) async {
    try {
      AppLogger.info('Sending chat message: ${request.message} to conversation: ${request.conversationId}');
      
      final response = await _httpService.post(
        '/api/v1/chat/message',
        body: request.toJson(),
      );

      // Parse response - API might return message directly or in nested structure
      String messageContent;
      String messageId;
      
      if (response.containsKey('message')) {
        messageContent = response['message'] as String;
        messageId = response['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      } else if (response.containsKey('response')) {
        messageContent = response['response'] as String;
        messageId = response['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      } else {
        // If response format is different, try to get the first string value
        messageContent = response.values.firstWhere(
          (v) => v is String,
          orElse: () => 'No response',
        ) as String;
        messageId = DateTime.now().millisecondsSinceEpoch.toString();
      }
      
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
      
      final response = await _httpService.get(
        '/api/v1/chat/history/$conversationId',
      );

      // Parse response - expecting array of messages
      List<ChatMessageModel> messages = [];
      
      if (response.containsKey('messages') && response['messages'] is List) {
        final messagesList = response['messages'] as List;
        messages = messagesList.map((msg) {
          final isUser = msg['role'] == 'user' || msg['sender'] == 'user';
          final content = msg['content']?.toString() ?? msg['message']?.toString() ?? '';
          final id = msg['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
          
          return isUser
              ? ChatMessageModel.user(id: id, content: content)
              : ChatMessageModel.ai(id: id, content: content);
        }).toList();
      } else if (response['data'] is List) {
        final messagesList = response['data'] as List;
        messages = messagesList.map((msg) {
          final isUser = msg['role'] == 'user' || msg['sender'] == 'user';
          final content = msg['content']?.toString() ?? msg['message']?.toString() ?? '';
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
