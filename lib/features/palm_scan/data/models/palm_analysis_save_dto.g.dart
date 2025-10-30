// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'palm_analysis_save_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PalmAnalysisSaveDto _$PalmAnalysisSaveDtoFromJson(Map<String, dynamic> json) =>
    PalmAnalysisSaveDto(
      userId: (json['userId'] as num).toInt(),
      annotatedImage: json['annotatedImage'] as String,
      palmLinesDetected: (json['palmLinesDetected'] as num).toInt(),
      detectedHeartLine: (json['detectedHeartLine'] as num).toInt(),
      detectedHeadLine: (json['detectedHeadLine'] as num).toInt(),
      detectedLifeLine: (json['detectedLifeLine'] as num).toInt(),
      detectedFateLine: (json['detectedFateLine'] as num).toInt(),
      targetLines: json['targetLines'] as String,
      imageHeight: (json['imageHeight'] as num).toInt(),
      imageWidth: (json['imageWidth'] as num).toInt(),
      imageChannels: (json['imageChannels'] as num).toInt(),
      summaryText: json['summaryText'] as String,
      interpretations: (json['interpretations'] as List<dynamic>)
          .map((e) => InterpretationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      lifeAspects: (json['lifeAspects'] as List<dynamic>)
          .map((e) => LifeAspectDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PalmAnalysisSaveDtoToJson(
  PalmAnalysisSaveDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'annotatedImage': instance.annotatedImage,
  'palmLinesDetected': instance.palmLinesDetected,
  'detectedHeartLine': instance.detectedHeartLine,
  'detectedHeadLine': instance.detectedHeadLine,
  'detectedLifeLine': instance.detectedLifeLine,
  'detectedFateLine': instance.detectedFateLine,
  'targetLines': instance.targetLines,
  'imageHeight': instance.imageHeight,
  'imageWidth': instance.imageWidth,
  'imageChannels': instance.imageChannels,
  'summaryText': instance.summaryText,
  'interpretations': instance.interpretations,
  'lifeAspects': instance.lifeAspects,
};

InterpretationDto _$InterpretationDtoFromJson(Map<String, dynamic> json) =>
    InterpretationDto(
      lineType: json['lineType'] as String,
      pattern: json['pattern'] as String,
      meaning: json['meaning'] as String,
      lengthPx: (json['lengthPx'] as num).toInt(),
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

PalmAnalysisApiResponse _$PalmAnalysisApiResponseFromJson(
  Map<String, dynamic> json,
) => PalmAnalysisApiResponse(
  success: json['success'] as bool,
  data: PalmAnalysisApiData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PalmAnalysisApiResponseToJson(
  PalmAnalysisApiResponse instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

PalmAnalysisApiData _$PalmAnalysisApiDataFromJson(Map<String, dynamic> json) =>
    PalmAnalysisApiData(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      annotatedImage: json['annotatedImage'] as String,
      palmLinesDetected: (json['palmLinesDetected'] as num).toInt(),
      detectedHeartLine: (json['detectedHeartLine'] as num).toInt(),
      detectedHeadLine: (json['detectedHeadLine'] as num).toInt(),
      detectedLifeLine: (json['detectedLifeLine'] as num).toInt(),
      detectedFateLine: (json['detectedFateLine'] as num).toInt(),
      targetLines: json['targetLines'] as String,
      imageHeight: (json['imageHeight'] as num).toInt(),
      imageWidth: (json['imageWidth'] as num).toInt(),
      imageChannels: (json['imageChannels'] as num).toInt(),
      summaryText: json['summaryText'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      interpretations: (json['interpretations'] as List<dynamic>)
          .map(
            (e) => InterpretationApiModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$PalmAnalysisApiDataToJson(
  PalmAnalysisApiData instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'annotatedImage': instance.annotatedImage,
  'palmLinesDetected': instance.palmLinesDetected,
  'detectedHeartLine': instance.detectedHeartLine,
  'detectedHeadLine': instance.detectedHeadLine,
  'detectedLifeLine': instance.detectedLifeLine,
  'detectedFateLine': instance.detectedFateLine,
  'targetLines': instance.targetLines,
  'imageHeight': instance.imageHeight,
  'imageWidth': instance.imageWidth,
  'imageChannels': instance.imageChannels,
  'summaryText': instance.summaryText,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'interpretations': instance.interpretations,
};

InterpretationApiModel _$InterpretationApiModelFromJson(
  Map<String, dynamic> json,
) => InterpretationApiModel(
  id: (json['id'] as num).toInt(),
  analysisId: (json['analysisId'] as num).toInt(),
  lineType: json['lineType'] as String,
  pattern: json['pattern'] as String,
  meaning: json['meaning'] as String,
  lengthPx: (json['lengthPx'] as num).toInt(),
  confidence: (json['confidence'] as num).toDouble(),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$InterpretationApiModelToJson(
  InterpretationApiModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'analysisId': instance.analysisId,
  'lineType': instance.lineType,
  'pattern': instance.pattern,
  'meaning': instance.meaning,
  'lengthPx': instance.lengthPx,
  'confidence': instance.confidence,
  'createdAt': instance.createdAt,
};
