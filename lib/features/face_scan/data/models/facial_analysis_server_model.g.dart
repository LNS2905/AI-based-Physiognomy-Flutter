// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facial_analysis_server_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacialAnalysisServerModel _$FacialAnalysisServerModelFromJson(
  Map<String, dynamic> json,
) => FacialAnalysisServerModel(
  id: (json['id'] as num).toInt(),
  userId: json['userId'] as String,
  resultText: json['resultText'] as String,
  faceShape: json['faceShape'] as String,
  harmonyScore: (json['harmonyScore'] as num).toDouble(),
  probabilities: (json['probabilities'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  harmonyDetails: (json['harmonyDetails'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  metrics: (json['metrics'] as List<dynamic>)
      .map((e) => FacialMetricServerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  annotatedImage: json['annotatedImage'] as String,
  processedAt: json['processedAt'] as String,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$FacialAnalysisServerModelToJson(
  FacialAnalysisServerModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'resultText': instance.resultText,
  'faceShape': instance.faceShape,
  'harmonyScore': instance.harmonyScore,
  'probabilities': instance.probabilities,
  'harmonyDetails': instance.harmonyDetails,
  'metrics': instance.metrics,
  'annotatedImage': instance.annotatedImage,
  'processedAt': instance.processedAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

FacialMetricServerModel _$FacialMetricServerModelFromJson(
  Map<String, dynamic> json,
) => FacialMetricServerModel(
  orientation: json['orientation'] as String,
  percentage: (json['percentage'] as num).toDouble(),
  pixels: (json['pixels'] as num).toDouble(),
  label: json['label'] as String,
);

Map<String, dynamic> _$FacialMetricServerModelToJson(
  FacialMetricServerModel instance,
) => <String, dynamic>{
  'orientation': instance.orientation,
  'percentage': instance.percentage,
  'pixels': instance.pixels,
  'label': instance.label,
};
