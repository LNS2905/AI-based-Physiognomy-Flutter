import 'dart:async';
import '../../../../core/network/http_service.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/providers/base_provider.dart';
import '../models/chat_request_model.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';

/// Repository for handling AI chat API operations
class ChatRepository {
  final HttpService _httpService;

  ChatRepository({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  /// Send a message to the AI and get response
  Future<ApiResult<ChatMessageModel>> sendMessage(ChatRequestModel request) async {
    try {
      AppLogger.info('Sending chat message: ${request.message}');
      
      final response = await _httpService.post(
        '/api/chat/send',
        body: request.toJson(),
      );

      final chatResponse = ChatResponseModel.fromJson(response);
      
      // Convert API response to ChatMessageModel
      final aiMessage = ChatMessageModel.ai(
        id: chatResponse.id,
        content: chatResponse.message,
        isDelivered: chatResponse.isComplete,
        metadata: chatResponse.metadata,
      );

      AppLogger.info('Received AI response: ${aiMessage.id}');
      return Success(aiMessage);
    } catch (e) {
      AppLogger.error('Failed to send chat message', e);
      return Error(_mapErrorToFailure(e));
    }
  }

  /// Get conversation history
  Future<ApiResult<ConversationModel>> getConversation(String conversationId) async {
    try {
      AppLogger.info('Fetching conversation: $conversationId');
      
      final response = await _httpService.get(
        '/api/chat/conversations/$conversationId',
      );

      final conversation = ConversationModel.fromJson(response);
      
      AppLogger.info('Fetched conversation with ${conversation.messages.length} messages');
      return Success(conversation);
    } catch (e) {
      AppLogger.error('Failed to fetch conversation', e);
      return Error(_mapErrorToFailure(e));
    }
  }

  /// Get list of conversations
  Future<ApiResult<List<ConversationModel>>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      AppLogger.info('Fetching conversations: page $page, limit $limit');
      
      final response = await _httpService.get(
        '/api/chat/conversations',
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final List<dynamic> conversationsJson = response['conversations'] ?? [];
      final conversations = conversationsJson
          .map((json) => ConversationModel.fromJson(json))
          .toList();
      
      AppLogger.info('Fetched ${conversations.length} conversations');
      return Success(conversations);
    } catch (e) {
      AppLogger.error('Failed to fetch conversations', e);
      return Error(_mapErrorToFailure(e));
    }
  }

  /// Create a new conversation
  Future<ApiResult<ConversationModel>> createConversation({
    String? title,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.info('Creating new conversation');
      
      final response = await _httpService.post(
        '/api/chat/conversations',
        body: {
          if (title != null) 'title': title,
          if (metadata != null) 'metadata': metadata,
        },
      );

      final conversation = ConversationModel.fromJson(response);
      
      AppLogger.info('Created conversation: ${conversation.id}');
      return Success(conversation);
    } catch (e) {
      AppLogger.error('Failed to create conversation', e);
      return Error(_mapErrorToFailure(e));
    }
  }

  /// Delete a conversation
  Future<ApiResult<bool>> deleteConversation(String conversationId) async {
    try {
      AppLogger.info('Deleting conversation: $conversationId');
      
      await _httpService.delete('/api/chat/conversations/$conversationId');
      
      AppLogger.info('Deleted conversation: $conversationId');
      return Success(true);
    } catch (e) {
      AppLogger.error('Failed to delete conversation', e);
      return Error(_mapErrorToFailure(e));
    }
  }

  /// Update conversation title
  Future<ApiResult<ConversationModel>> updateConversationTitle(
    String conversationId,
    String title,
  ) async {
    try {
      AppLogger.info('Updating conversation title: $conversationId');
      
      final response = await _httpService.put(
        '/api/chat/conversations/$conversationId',
        body: {'title': title},
      );

      final conversation = ConversationModel.fromJson(response);
      
      AppLogger.info('Updated conversation title: ${conversation.id}');
      return Success(conversation);
    } catch (e) {
      AppLogger.error('Failed to update conversation title', e);
      return Error(_mapErrorToFailure(e));
    }
  }

  /// Stream messages for real-time chat (if supported by backend)
  Stream<ChatMessageModel> streamMessages(String conversationId) async* {
    try {
      AppLogger.info('Starting message stream for conversation: $conversationId');
      
      // This would typically use WebSocket or Server-Sent Events
      // For now, we'll implement a simple polling mechanism
      // In a real implementation, you'd use packages like web_socket_channel
      
      Timer.periodic(const Duration(seconds: 2), (timer) async {
        try {
          final result = await getConversation(conversationId);
          result.when(
            success: (conversation) {
              // Emit new messages if any
              // This is a simplified implementation
            },
            error: (failure) {
              AppLogger.error('Error in message stream', failure.message);
              timer.cancel();
            },
            loading: () {},
          );
        } catch (e) {
          AppLogger.error('Error in message stream polling', e);
          timer.cancel();
        }
      });
    } catch (e) {
      AppLogger.error('Failed to start message stream', e);
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
