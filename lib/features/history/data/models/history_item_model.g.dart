// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryItemModel _$HistoryItemModelFromJson(Map<String, dynamic> json) =>
    HistoryItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$HistoryItemTypeEnumMap, json['type']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$HistoryItemModelToJson(HistoryItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$HistoryItemTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
      'thumbnailUrl': instance.thumbnailUrl,
      'isFavorite': instance.isFavorite,
      'tags': instance.tags,
    };

const _$HistoryItemTypeEnumMap = {
  HistoryItemType.faceAnalysis: 'face_analysis',
  HistoryItemType.palmAnalysis: 'palm_analysis',
  HistoryItemType.chatConversation: 'chat_conversation',
};

FaceAnalysisHistoryModel _$FaceAnalysisHistoryModelFromJson(
  Map<String, dynamic> json,
) => FaceAnalysisHistoryModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  analysisResult: CloudinaryAnalysisResponseModel.fromJson(
    json['analysisResult'] as Map<String, dynamic>,
  ),
  originalImageUrl: json['originalImageUrl'] as String?,
  annotatedImageUrl: json['annotatedImageUrl'] as String?,
  reportUrl: json['reportUrl'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  isFavorite: json['isFavorite'] as bool? ?? false,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$FaceAnalysisHistoryModelToJson(
  FaceAnalysisHistoryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'metadata': instance.metadata,
  'thumbnailUrl': instance.thumbnailUrl,
  'isFavorite': instance.isFavorite,
  'tags': instance.tags,
  'analysisResult': instance.analysisResult,
  'originalImageUrl': instance.originalImageUrl,
  'annotatedImageUrl': instance.annotatedImageUrl,
  'reportUrl': instance.reportUrl,
};

PalmAnalysisHistoryModel _$PalmAnalysisHistoryModelFromJson(
  Map<String, dynamic> json,
) => PalmAnalysisHistoryModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  analysisResult: PalmAnalysisResponseModel.fromJson(
    json['analysisResult'] as Map<String, dynamic>,
  ),
  originalImageUrl: json['originalImageUrl'] as String?,
  annotatedImageUrl: json['annotatedImageUrl'] as String?,
  comparisonImageUrl: json['comparisonImageUrl'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  isFavorite: json['isFavorite'] as bool? ?? false,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$PalmAnalysisHistoryModelToJson(
  PalmAnalysisHistoryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'metadata': instance.metadata,
  'thumbnailUrl': instance.thumbnailUrl,
  'isFavorite': instance.isFavorite,
  'tags': instance.tags,
  'analysisResult': instance.analysisResult,
  'originalImageUrl': instance.originalImageUrl,
  'annotatedImageUrl': instance.annotatedImageUrl,
  'comparisonImageUrl': instance.comparisonImageUrl,
};
