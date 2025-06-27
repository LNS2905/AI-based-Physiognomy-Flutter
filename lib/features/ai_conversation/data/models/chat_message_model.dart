import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_message_model.g.dart';

/// Enum for message types
enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('system')
  system,
}

/// Enum for message sender
enum MessageSender {
  @JsonValue('user')
  user,
  @JsonValue('ai')
  ai,
  @JsonValue('system')
  system,
}

/// Chat message model
@JsonSerializable()
class ChatMessageModel extends Equatable {
  final String id;
  final String content;
  final MessageType type;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isDelivered;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  const ChatMessageModel({
    required this.id,
    required this.content,
    required this.type,
    required this.sender,
    required this.timestamp,
    this.isDelivered = true,
    this.isRead = false,
    this.metadata,
  });

  /// Create a user message
  factory ChatMessageModel.user({
    required String id,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessageModel(
      id: id,
      content: content,
      type: type,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      isDelivered: true,
      isRead: true,
      metadata: metadata,
    );
  }

  /// Create an AI message
  factory ChatMessageModel.ai({
    required String id,
    required String content,
    MessageType type = MessageType.text,
    bool isDelivered = true,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessageModel(
      id: id,
      content: content,
      type: type,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      isDelivered: isDelivered,
      isRead: false,
      metadata: metadata,
    );
  }

  /// Create a system message
  factory ChatMessageModel.system({
    required String id,
    required String content,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessageModel(
      id: id,
      content: content,
      type: MessageType.system,
      sender: MessageSender.system,
      timestamp: DateTime.now(),
      isDelivered: true,
      isRead: true,
      metadata: metadata,
    );
  }

  /// Copy with method
  ChatMessageModel copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isDelivered,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isDelivered: isDelivered ?? this.isDelivered,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON serialization
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        content,
        type,
        sender,
        timestamp,
        isDelivered,
        isRead,
        metadata,
      ];

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, content: $content, type: $type, sender: $sender, timestamp: $timestamp)';
  }
}
