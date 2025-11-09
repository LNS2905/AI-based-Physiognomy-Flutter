// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_start_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatStartRequest _$ChatStartRequestFromJson(Map<String, dynamic> json) =>
    ChatStartRequest(
      userId: (json['user_id'] as num).toInt(),
      chartId: (json['chart_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ChatStartRequestToJson(ChatStartRequest instance) =>
    <String, dynamic>{'user_id': instance.userId, 'chart_id': instance.chartId};

ChatStartResponse _$ChatStartResponseFromJson(Map<String, dynamic> json) =>
    ChatStartResponse(
      conversationId: (json['conversation_id'] as num).toInt(),
      title: json['title'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChatStartResponseToJson(ChatStartResponse instance) =>
    <String, dynamic>{
      'conversation_id': instance.conversationId,
      'title': instance.title,
      'createdAt': instance.createdAt?.toIso8601String(),
      'metadata': instance.metadata,
    };
