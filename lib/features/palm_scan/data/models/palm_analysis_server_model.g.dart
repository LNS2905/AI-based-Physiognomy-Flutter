// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'palm_analysis_server_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PalmAnalysisServerModel _$PalmAnalysisServerModelFromJson(
  Map<String, dynamic> json,
) => PalmAnalysisServerModel(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  annotatedImage: json['annotatedImage'] as String,
  palmLinesDetected: (json['palmLinesDetected'] as num).toInt(),
  detectedHeartLine: (json['detectedHeartLine'] as num).toInt(),
  detectedHeadLine: (json['detectedHeadLine'] as num).toInt(),
  detectedLifeLine: (json['detectedLifeLine'] as num).toInt(),
  detectedFateLine: (json['detectedFateLine'] as num).toInt(),
  targetLines: json['targetLines'] as String,
  imageHeight: (json['imageHeight'] as num).toDouble(),
  imageWidth: (json['imageWidth'] as num).toDouble(),
  imageChannels: (json['imageChannels'] as num).toDouble(),
  summaryText: json['summaryText'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  interpretations: (json['interpretations'] as List<dynamic>)
      .map((e) => InterpretationServerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  lifeAspects: (json['lifeAspects'] as List<dynamic>)
      .map((e) => LifeAspectServerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PalmAnalysisServerModelToJson(
  PalmAnalysisServerModel instance,
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
  'lifeAspects': instance.lifeAspects,
};

InterpretationServerModel _$InterpretationServerModelFromJson(
  Map<String, dynamic> json,
) => InterpretationServerModel(
  id: (json['id'] as num).toInt(),
  analysisId: (json['analysisId'] as num).toInt(),
  lineType: json['lineType'] as String,
  pattern: json['pattern'] as String,
  meaning: json['meaning'] as String,
  lengthPx: (json['lengthPx'] as num).toInt(),
  confidence: (json['confidence'] as num).toDouble(),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$InterpretationServerModelToJson(
  InterpretationServerModel instance,
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

LifeAspectServerModel _$LifeAspectServerModelFromJson(
  Map<String, dynamic> json,
) => LifeAspectServerModel(
  id: (json['id'] as num).toInt(),
  analysisId: (json['analysisId'] as num).toInt(),
  aspect: json['aspect'] as String,
  content: json['content'] as String,
);

Map<String, dynamic> _$LifeAspectServerModelToJson(
  LifeAspectServerModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'analysisId': instance.analysisId,
  'aspect': instance.aspect,
  'content': instance.content,
};
