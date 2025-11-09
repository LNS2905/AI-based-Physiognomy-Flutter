import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_request_model.g.dart';

/// Chat request model for API calls
@JsonSerializable()
class ChatRequestModel extends Equatable {
  final String message;
  @JsonKey(name: 'conversation_id')
  final int conversationId;
  final Map<String, dynamic>? context;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;

  const ChatRequestModel({
    required this.message,
    required this.conversationId,
    this.context,
    this.attachments,
    this.metadata,
  });

  /// Create a simple text message request
  factory ChatRequestModel.text({
    required String message,
    required int conversationId,
    Map<String, dynamic>? context,
  }) {
    return ChatRequestModel(
      message: message,
      conversationId: conversationId,
      context: context,
    );
  }

  /// Create a request with attachments
  factory ChatRequestModel.withAttachments({
    required String message,
    required List<String> attachments,
    required int conversationId,
    Map<String, dynamic>? context,
  }) {
    return ChatRequestModel(
      message: message,
      conversationId: conversationId,
      context: context,
      attachments: attachments,
    );
  }

  /// Copy with method
  ChatRequestModel copyWith({
    String? message,
    int? conversationId,
    Map<String, dynamic>? context,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return ChatRequestModel(
      message: message ?? this.message,
      conversationId: conversationId ?? this.conversationId,
      context: context ?? this.context,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON serialization
  factory ChatRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRequestModelToJson(this);

  @override
  List<Object?> get props => [
        message,
        conversationId,
        context,
        attachments,
        metadata,
      ];

  @override
  String toString() {
    return 'ChatRequestModel(message: $message, conversationId: $conversationId)';
  }
}

/// Chat response model from API
@JsonSerializable()
class ChatResponseModel extends Equatable {
  final String id;
  final String message;
  @JsonKey(name: 'conversation_id')
  final int conversationId;
  final DateTime timestamp;
  final bool isComplete;
  final Map<String, dynamic>? metadata;

  const ChatResponseModel({
    required this.id,
    required this.message,
    required this.conversationId,
    required this.timestamp,
    this.isComplete = true,
    this.metadata,
  });

  /// Copy with method
  ChatResponseModel copyWith({
    String? id,
    String? message,
    int? conversationId,
    DateTime? timestamp,
    bool? isComplete,
    Map<String, dynamic>? metadata,
  }) {
    return ChatResponseModel(
      id: id ?? this.id,
      message: message ?? this.message,
      conversationId: conversationId ?? this.conversationId,
      timestamp: timestamp ?? this.timestamp,
      isComplete: isComplete ?? this.isComplete,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON serialization
  factory ChatResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatResponseModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        message,
        conversationId,
        timestamp,
        isComplete,
        metadata,
      ];

  @override
  String toString() {
    return 'ChatResponseModel(id: $id, conversationId: $conversationId, isComplete: $isComplete)';
  }
}
