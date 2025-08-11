// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'palm_analysis_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PalmAnalysisDto _$PalmAnalysisDtoFromJson(Map<String, dynamic> json) =>
    PalmAnalysisDto(
      userId: (json['userId'] as num).toDouble(),
      annotatedImage: json['annotatedImage'] as String,
      targetLines: json['targetLines'] as String,
      imageHeight: (json['imageHeight'] as num).toDouble(),
      imageWidth: (json['imageWidth'] as num).toDouble(),
      imageChannels: (json['imageChannels'] as num).toDouble(),
      summaryText: json['summaryText'] as String,
      interpretations: (json['interpretations'] as List<dynamic>)
          .map((e) => InterpretationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      lifeAspects: (json['lifeAspects'] as List<dynamic>)
          .map((e) => LifeAspectDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      palmLinesDetected: (json['palmLinesDetected'] as num?)?.toDouble(),
      detectedHeartLine: (json['detectedHeartLine'] as num?)?.toDouble(),
      detectedHeadLine: (json['detectedHeadLine'] as num?)?.toDouble(),
      detectedLifeLine: (json['detectedLifeLine'] as num?)?.toDouble(),
      detectedFateLine: (json['detectedFateLine'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PalmAnalysisDtoToJson(PalmAnalysisDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'annotatedImage': instance.annotatedImage,
      'targetLines': instance.targetLines,
      'imageHeight': instance.imageHeight,
      'imageWidth': instance.imageWidth,
      'imageChannels': instance.imageChannels,
      'summaryText': instance.summaryText,
      'interpretations': instance.interpretations,
      'lifeAspects': instance.lifeAspects,
      'palmLinesDetected': instance.palmLinesDetected,
      'detectedHeartLine': instance.detectedHeartLine,
      'detectedHeadLine': instance.detectedHeadLine,
      'detectedLifeLine': instance.detectedLifeLine,
      'detectedFateLine': instance.detectedFateLine,
    };

InterpretationDto _$InterpretationDtoFromJson(Map<String, dynamic> json) =>
    InterpretationDto(
      lineType: json['lineType'] as String,
      pattern: json['pattern'] as String,
      meaning: json['meaning'] as String,
      lengthPx: (json['lengthPx'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$InterpretationDtoToJson(InterpretationDto instance) =>
    <String, dynamic>{
      'lineType': instance.lineType,
      'pattern': instance.pattern,
      'meaning': instance.meaning,
      'lengthPx': instance.lengthPx,
      'confidence': instance.confidence,
    };

LifeAspectDto _$LifeAspectDtoFromJson(Map<String, dynamic> json) =>
    LifeAspectDto(
      aspect: json['aspect'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$LifeAspectDtoToJson(LifeAspectDto instance) =>
    <String, dynamic>{'aspect': instance.aspect, 'content': instance.content};
