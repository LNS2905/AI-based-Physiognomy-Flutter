// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facial_analysis_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
          .map((e) => FacialMetricDto.fromJson(e as Map<String, dynamic>))
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

FacialMetricDto _$FacialMetricDtoFromJson(Map<String, dynamic> json) =>
    FacialMetricDto(
      orientation: json['orientation'] as String,
      percentage: (json['percentage'] as num).toDouble(),
      pixels: (json['pixels'] as num).toDouble(),
      label: json['label'] as String,
    );

Map<String, dynamic> _$FacialMetricDtoToJson(FacialMetricDto instance) =>
    <String, dynamic>{
      'orientation': instance.orientation,
      'percentage': instance.percentage,
      'pixels': instance.pixels,
      'label': instance.label,
    };
