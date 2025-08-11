import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'palm_analysis_dto.g.dart';

/// DTO for saving palm analysis to backend API
/// Based on PalmAnalysisDto schema from swagger.json
@JsonSerializable()
class PalmAnalysisDto extends Equatable {
  final double userId;
  final String annotatedImage;
  final String targetLines;
  final double imageHeight;
  final double imageWidth;
  final double imageChannels;
  final String summaryText;
  final List<InterpretationDto> interpretations;
  final List<LifeAspectDto> lifeAspects;
  
  // Optional fields
  final double? palmLinesDetected;
  final double? detectedHeartLine;
  final double? detectedHeadLine;
  final double? detectedLifeLine;
  final double? detectedFateLine;

  const PalmAnalysisDto({
    required this.userId,
    required this.annotatedImage,
    required this.targetLines,
    required this.imageHeight,
    required this.imageWidth,
    required this.imageChannels,
    required this.summaryText,
    required this.interpretations,
    required this.lifeAspects,
    this.palmLinesDetected,
    this.detectedHeartLine,
    this.detectedHeadLine,
    this.detectedLifeLine,
    this.detectedFateLine,
  });

  /// Create DTO from PalmAnalysisResponseModel
  factory PalmAnalysisDto.fromAnalysisResponse({
    required double userId,
    required String annotatedImage,
    required String summaryText,
    required List<InterpretationDto> interpretations,
    required List<LifeAspectDto> lifeAspects,
    double? imageHeight,
    double? imageWidth,
    double? imageChannels,
    String? targetLines,
    double? palmLinesDetected,
    double? detectedHeartLine,
    double? detectedHeadLine,
    double? detectedLifeLine,
    double? detectedFateLine,
  }) {
    return PalmAnalysisDto(
      userId: userId,
      annotatedImage: annotatedImage,
      targetLines: targetLines ?? 'heart,head,life,fate',
      imageHeight: imageHeight ?? 0.0,
      imageWidth: imageWidth ?? 0.0,
      imageChannels: imageChannels ?? 3.0,
      summaryText: summaryText,
      interpretations: interpretations,
      lifeAspects: lifeAspects,
      palmLinesDetected: palmLinesDetected,
      detectedHeartLine: detectedHeartLine,
      detectedHeadLine: detectedHeadLine,
      detectedLifeLine: detectedLifeLine,
      detectedFateLine: detectedFateLine,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        annotatedImage,
        targetLines,
        imageHeight,
        imageWidth,
        imageChannels,
        summaryText,
        interpretations,
        lifeAspects,
        palmLinesDetected,
        detectedHeartLine,
        detectedHeadLine,
        detectedLifeLine,
        detectedFateLine,
      ];

  /// JSON serialization
  factory PalmAnalysisDto.fromJson(Map<String, dynamic> json) =>
      _$PalmAnalysisDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PalmAnalysisDtoToJson(this);
}

/// Interpretation DTO for palm analysis
@JsonSerializable()
class InterpretationDto extends Equatable {
  final String category;
  final String title;
  final String description;
  final double confidence;

  const InterpretationDto({
    required this.category,
    required this.title,
    required this.description,
    required this.confidence,
  });

  @override
  List<Object?> get props => [category, title, description, confidence];

  factory InterpretationDto.fromJson(Map<String, dynamic> json) =>
      _$InterpretationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InterpretationDtoToJson(this);
}

/// Life aspect DTO for palm analysis
@JsonSerializable()
class LifeAspectDto extends Equatable {
  final String aspect;
  final String prediction;
  final double score;
  final String details;

  const LifeAspectDto({
    required this.aspect,
    required this.prediction,
    required this.score,
    required this.details,
  });

  @override
  List<Object?> get props => [aspect, prediction, score, details];

  factory LifeAspectDto.fromJson(Map<String, dynamic> json) =>
      _$LifeAspectDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LifeAspectDtoToJson(this);
}
