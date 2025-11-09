import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'chat_message_model.dart';

part 'conversation_model.g.dart';

/// Conversation status enum
enum ConversationStatus {
  @JsonValue('active')
  active,
  @JsonValue('archived')
  archived,
  @JsonValue('deleted')
  deleted,
}

/// Conversation model
@JsonSerializable()
class ConversationModel extends Equatable {
  final int id;
  final String title;
  final List<ChatMessageModel> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ConversationStatus status;
  final Map<String, dynamic>? metadata;

  const ConversationModel({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.status = ConversationStatus.active,
    this.metadata,
  });

  /// Create a new conversation
  factory ConversationModel.create({
    required int id,
    String? title,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return ConversationModel(
      id: id,
      title: title ?? 'New Conversation',
      messages: [],
      createdAt: now,
      updatedAt: now,
      status: ConversationStatus.active,
      metadata: metadata,
    );
  }

  /// Get the last message
  ChatMessageModel? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.last;
  }

  /// Get unread message count
  int get unreadCount {
    return messages.where((message) => !message.isRead && message.sender == MessageSender.ai).length;
  }

  /// Check if conversation has any messages
  bool get hasMessages => messages.isNotEmpty;

  /// Get conversation preview text
  String get previewText {
    if (messages.isEmpty) return 'No messages yet';
    final lastMsg = lastMessage!;
    if (lastMsg.type == MessageType.text) {
      return lastMsg.content.length > 50 
          ? '${lastMsg.content.substring(0, 50)}...'
          : lastMsg.content;
    }
    return 'Sent an ${lastMsg.type.name}';
  }

  /// Add a message to the conversation
  ConversationModel addMessage(ChatMessageModel message) {
    final updatedMessages = List<ChatMessageModel>.from(messages)..add(message);
    return copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
  }

  /// Update a message in the conversation
  ConversationModel updateMessage(String messageId, ChatMessageModel updatedMessage) {
    final updatedMessages = messages.map((message) {
      return message.id == messageId ? updatedMessage : message;
    }).toList();
    
    return copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove a message from the conversation
  ConversationModel removeMessage(String messageId) {
    final updatedMessages = messages.where((message) => message.id != messageId).toList();
    return copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark all messages as read
  ConversationModel markAllAsRead() {
    final updatedMessages = messages.map((message) {
      return message.sender == MessageSender.ai ? message.copyWith(isRead: true) : message;
    }).toList();
    
    return copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
  }

  /// Copy with method
  ConversationModel copyWith({
    int? id,
    String? title,
    List<ChatMessageModel>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    ConversationStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON serialization
  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        messages,
        createdAt,
        updatedAt,
        status,
        metadata,
      ];

  @override
  String toString() {
    return 'ConversationModel(id: $id, title: $title, messageCount: ${messages.length}, status: $status)';
  }
}
