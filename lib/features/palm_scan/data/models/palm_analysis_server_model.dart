import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'palm_analysis_server_model.g.dart';

/// Model for palm analysis data from server API /palm-analysis/user/{userId}
/// Based on the actual API response structure
@JsonSerializable()
class PalmAnalysisServerModel extends Equatable {
  final int id;
  final int userId;
  final String annotatedImage;
  final int palmLinesDetected;
  final int detectedHeartLine;
  final int detectedHeadLine;
  final int detectedLifeLine;
  final int detectedFateLine;
  final String targetLines;
  final double imageHeight;
  final double imageWidth;
  final double imageChannels;
  final String summaryText;
  final String createdAt;
  final String updatedAt;
  final List<InterpretationServerModel> interpretations;
  final List<LifeAspectServerModel> lifeAspects;

  const PalmAnalysisServerModel({
    required this.id,
    required this.userId,
    required this.annotatedImage,
    required this.palmLinesDetected,
    required this.detectedHeartLine,
    required this.detectedHeadLine,
    required this.detectedLifeLine,
    required this.detectedFateLine,
    required this.targetLines,
    required this.imageHeight,
    required this.imageWidth,
    required this.imageChannels,
    required this.summaryText,
    required this.createdAt,
    required this.updatedAt,
    required this.interpretations,
    required this.lifeAspects,
  });

  factory PalmAnalysisServerModel.fromJson(Map<String, dynamic> json) =>
      _$PalmAnalysisServerModelFromJson(json);

  Map<String, dynamic> toJson() => _$PalmAnalysisServerModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        annotatedImage,
        palmLinesDetected,
        detectedHeartLine,
        detectedHeadLine,
        detectedLifeLine,
        detectedFateLine,
        targetLines,
        imageHeight,
        imageWidth,
        imageChannels,
        summaryText,
        createdAt,
        updatedAt,
        interpretations,
        lifeAspects,
      ];
}

/// Model for interpretation data from server
@JsonSerializable()
class InterpretationServerModel extends Equatable {
  final int id;
  final int analysisId;
  final String lineType;
  final String pattern;
  final String meaning;
  final int lengthPx;
  final double confidence;
  final String createdAt;

  const InterpretationServerModel({
    required this.id,
    required this.analysisId,
    required this.lineType,
    required this.pattern,
    required this.meaning,
    required this.lengthPx,
    required this.confidence,
    required this.createdAt,
  });

  factory InterpretationServerModel.fromJson(Map<String, dynamic> json) =>
      _$InterpretationServerModelFromJson(json);

  Map<String, dynamic> toJson() => _$InterpretationServerModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        analysisId,
        lineType,
        pattern,
        meaning,
        lengthPx,
        confidence,
        createdAt,
      ];
}

/// Model for life aspect data from server
@JsonSerializable()
class LifeAspectServerModel extends Equatable {
  final int id;
  final int analysisId;
  final String aspect;
  final String content;

  const LifeAspectServerModel({
    required this.id,
    required this.analysisId,
    required this.aspect,
    required this.content,
  });

  factory LifeAspectServerModel.fromJson(Map<String, dynamic> json) =>
      _$LifeAspectServerModelFromJson(json);

  Map<String, dynamic> toJson() => _$LifeAspectServerModelToJson(this);

  @override
  List<Object?> get props => [id, analysisId, aspect, content];
}
