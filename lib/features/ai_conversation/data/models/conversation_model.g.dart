// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    ConversationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      status:
          $enumDecodeNullable(_$ConversationStatusEnumMap, json['status']) ??
          ConversationStatus.active,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ConversationModelToJson(ConversationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'messages': instance.messages,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'status': _$ConversationStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
    };

const _$ConversationStatusEnumMap = {
  ConversationStatus.active: 'active',
  ConversationStatus.archived: 'archived',
  ConversationStatus.deleted: 'deleted',
};
