// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRequestModel _$ChatRequestModelFromJson(Map<String, dynamic> json) =>
    ChatRequestModel(
      message: json['message'] as String,
      conversationId: (json['conversation_id'] as num).toInt(),
      context: json['context'] as Map<String, dynamic>?,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChatRequestModelToJson(ChatRequestModel instance) =>
    <String, dynamic>{
      'message': instance.message,
      'conversation_id': instance.conversationId,
      'context': instance.context,
      'attachments': instance.attachments,
      'metadata': instance.metadata,
    };

ChatResponseModel _$ChatResponseModelFromJson(Map<String, dynamic> json) =>
    ChatResponseModel(
      id: json['id'] as String,
      message: json['message'] as String,
      conversationId: (json['conversation_id'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isComplete: json['isComplete'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChatResponseModelToJson(ChatResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'conversation_id': instance.conversationId,
      'timestamp': instance.timestamp.toIso8601String(),
      'isComplete': instance.isComplete,
      'metadata': instance.metadata,
    };
