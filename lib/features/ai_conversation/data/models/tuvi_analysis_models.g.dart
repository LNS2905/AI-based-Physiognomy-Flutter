// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuvi_analysis_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartJsonInput _$ChartJsonInputFromJson(Map<String, dynamic> json) =>
    ChartJsonInput(
      chartData: json['chart_data'] as Map<String, dynamic>,
      question: json['question'] as String,
    );

Map<String, dynamic> _$ChartJsonInputToJson(ChartJsonInput instance) =>
    <String, dynamic>{
      'chart_data': instance.chartData,
      'question': instance.question,
    };

AnalysisResult _$AnalysisResultFromJson(Map<String, dynamic> json) =>
    AnalysisResult(
      filename: json['filename'] as String?,
      name: json['name'] as String?,
      analysis: json['analysis'] as String,
      extractedText: json['extracted_text'] as String?,
      timestamp: json['timestamp'] as String,
      status: json['status'] as String,
      method: json['method'] as String?,
      processingTime: json['processing_time'] as String?,
    );

Map<String, dynamic> _$AnalysisResultToJson(AnalysisResult instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'name': instance.name,
      'analysis': instance.analysis,
      'extracted_text': instance.extractedText,
      'timestamp': instance.timestamp,
      'status': instance.status,
      'method': instance.method,
      'processing_time': instance.processingTime,
    };
