// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatHistoryModel _$ChatHistoryModelFromJson(Map<String, dynamic> json) =>
    ChatHistoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      conversation: ConversationModel.fromJson(
        json['conversation'] as Map<String, dynamic>,
      ),
      messageCount: (json['messageCount'] as num).toInt(),
      lastMessagePreview: json['lastMessagePreview'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$ChatHistoryModelToJson(ChatHistoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
      'thumbnailUrl': instance.thumbnailUrl,
      'isFavorite': instance.isFavorite,
      'tags': instance.tags,
      'conversation': instance.conversation,
      'messageCount': instance.messageCount,
      'lastMessagePreview': instance.lastMessagePreview,
      'lastMessageTime': instance.lastMessageTime.toIso8601String(),
      'unreadCount': instance.unreadCount,
    };

HistoryFilterConfig _$HistoryFilterConfigFromJson(Map<String, dynamic> json) =>
    HistoryFilterConfig(
      filter:
          $enumDecodeNullable(_$HistoryFilterEnumMap, json['filter']) ??
          HistoryFilter.all,
      sort:
          $enumDecodeNullable(_$HistorySortEnumMap, json['sort']) ??
          HistorySort.newest,
      searchQuery: json['searchQuery'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      dateFrom: json['dateFrom'] == null
          ? null
          : DateTime.parse(json['dateFrom'] as String),
      dateTo: json['dateTo'] == null
          ? null
          : DateTime.parse(json['dateTo'] as String),
    );

Map<String, dynamic> _$HistoryFilterConfigToJson(
  HistoryFilterConfig instance,
) => <String, dynamic>{
  'filter': _$HistoryFilterEnumMap[instance.filter]!,
  'sort': _$HistorySortEnumMap[instance.sort]!,
  'searchQuery': instance.searchQuery,
  'tags': instance.tags,
  'dateFrom': instance.dateFrom?.toIso8601String(),
  'dateTo': instance.dateTo?.toIso8601String(),
};

const _$HistoryFilterEnumMap = {
  HistoryFilter.all: 'all',
  HistoryFilter.faceAnalysis: 'faceAnalysis',
  HistoryFilter.palmAnalysis: 'palmAnalysis',
  HistoryFilter.chatConversation: 'chatConversation',
  HistoryFilter.favorites: 'favorites',
  HistoryFilter.recent: 'recent',
  HistoryFilter.thisWeek: 'thisWeek',
  HistoryFilter.thisMonth: 'thisMonth',
};

const _$HistorySortEnumMap = {
  HistorySort.newest: 'newest',
  HistorySort.oldest: 'oldest',
  HistorySort.alphabetical: 'alphabetical',
  HistorySort.mostUsed: 'mostUsed',
  HistorySort.favorites: 'favorites',
};
