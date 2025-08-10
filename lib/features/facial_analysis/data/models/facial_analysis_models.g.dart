// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facial_analysis_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacialMetric _$FacialMetricFromJson(Map<String, dynamic> json) => FacialMetric(
  orientation: json['orientation'] as String,
  percentage: (json['percentage'] as num).toDouble(),
  pixels: (json['pixels'] as num).toDouble(),
  label: json['label'] as String,
);

Map<String, dynamic> _$FacialMetricToJson(FacialMetric instance) =>
    <String, dynamic>{
      'orientation': instance.orientation,
      'percentage': instance.percentage,
      'pixels': instance.pixels,
      'label': instance.label,
    };

FacialAnalysisDto _$FacialAnalysisDtoFromJson(Map<String, dynamic> json) =>
    FacialAnalysisDto(
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
          .map((e) => FacialMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
      annotatedImage: json['annotatedImage'] as String,
      processedAt: json['processedAt'] as String,
    );

Map<String, dynamic> _$FacialAnalysisDtoToJson(FacialAnalysisDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'resultText': instance.resultText,
      'faceShape': instance.faceShape,
      'harmonyScore': instance.harmonyScore,
      'probabilities': instance.probabilities,
      'harmonyDetails': instance.harmonyDetails,
      'metrics': instance.metrics,
      'annotatedImage': instance.annotatedImage,
      'processedAt': instance.processedAt,
    };

FacialAnalysis _$FacialAnalysisFromJson(Map<String, dynamic> json) =>
    FacialAnalysis(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
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
          .map((e) => FacialMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
      annotatedImage: json['annotatedImage'] as String,
      processedAt: json['processedAt'] as String,
      createdAt: json['createAt'] == null
          ? null
          : DateTime.parse(json['createAt'] as String),
      updatedAt: json['updateAt'] == null
          ? null
          : DateTime.parse(json['updateAt'] as String),
    );

Map<String, dynamic> _$FacialAnalysisToJson(FacialAnalysis instance) =>
    <String, dynamic>{
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
      'createAt': instance.createdAt?.toIso8601String(),
      'updateAt': instance.updatedAt?.toIso8601String(),
    };

CreateFacialAnalysisRequest _$CreateFacialAnalysisRequestFromJson(
  Map<String, dynamic> json,
) => CreateFacialAnalysisRequest(
  imageBase64: json['imageBase64'] as String,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CreateFacialAnalysisRequestToJson(
  CreateFacialAnalysisRequest instance,
) => <String, dynamic>{
  'imageBase64': instance.imageBase64,
  'metadata': instance.metadata,
};

UpdateFacialAnalysisRequest _$UpdateFacialAnalysisRequestFromJson(
  Map<String, dynamic> json,
) => UpdateFacialAnalysisRequest(
  resultText: json['resultText'] as String?,
  faceShape: json['faceShape'] as String?,
  harmonyScore: (json['harmonyScore'] as num?)?.toDouble(),
  probabilities: (json['probabilities'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  harmonyDetails: (json['harmonyDetails'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  metrics: (json['metrics'] as List<dynamic>?)
      ?.map((e) => FacialMetric.fromJson(e as Map<String, dynamic>))
      .toList(),
  annotatedImage: json['annotatedImage'] as String?,
);

Map<String, dynamic> _$UpdateFacialAnalysisRequestToJson(
  UpdateFacialAnalysisRequest instance,
) => <String, dynamic>{
  'resultText': instance.resultText,
  'faceShape': instance.faceShape,
  'harmonyScore': instance.harmonyScore,
  'probabilities': instance.probabilities,
  'harmonyDetails': instance.harmonyDetails,
  'metrics': instance.metrics,
  'annotatedImage': instance.annotatedImage,
};

FacialAnalysisSummary _$FacialAnalysisSummaryFromJson(
  Map<String, dynamic> json,
) => FacialAnalysisSummary(
  id: (json['id'] as num).toInt(),
  faceShape: json['faceShape'] as String,
  harmonyScore: (json['harmonyScore'] as num).toDouble(),
  processedAt: json['processedAt'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$FacialAnalysisSummaryToJson(
  FacialAnalysisSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'faceShape': instance.faceShape,
  'harmonyScore': instance.harmonyScore,
  'processedAt': instance.processedAt,
  'createdAt': instance.createdAt?.toIso8601String(),
};
