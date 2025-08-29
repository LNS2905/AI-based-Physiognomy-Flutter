import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'palm_analysis_save_dto.g.dart';

/// DTO for saving palm analysis to backend API
/// Based on actual API requirements from the raw response
@JsonSerializable()
class PalmAnalysisSaveDto extends Equatable {
  final int userId;
  final String annotatedImage;
  final int palmLinesDetected;
  final int detectedHeartLine;
  final int detectedHeadLine;
  final int detectedLifeLine;
  final int detectedFateLine;
  final String targetLines;
  final int imageHeight;
  final int imageWidth;
  final int imageChannels;
  final String summaryText;
  final List<InterpretationDto> interpretations;
  final List<LifeAspectDto> lifeAspects;

  const PalmAnalysisSaveDto({
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
    required this.interpretations,
    required this.lifeAspects,
  });

  @override
  List<Object?> get props => [
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
        interpretations,
        lifeAspects,
      ];

  /// JSON serialization
  factory PalmAnalysisSaveDto.fromJson(Map<String, dynamic> json) =>
      _$PalmAnalysisSaveDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PalmAnalysisSaveDtoToJson(this);
}

/// Interpretation DTO matching API response format
@JsonSerializable()
class InterpretationDto extends Equatable {
  final String lineType;
  final String pattern;
  final String meaning;
  final int lengthPx;
  final double confidence;

  const InterpretationDto({
    required this.lineType,
    required this.pattern,
    required this.meaning,
    required this.lengthPx,
    required this.confidence,
  });

  @override
  List<Object?> get props => [lineType, pattern, meaning, lengthPx, confidence];

  factory InterpretationDto.fromJson(Map<String, dynamic> json) =>
      _$InterpretationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InterpretationDtoToJson(this);
}

/// Life aspect DTO matching API response format
@JsonSerializable()
class LifeAspectDto extends Equatable {
  final String aspect;
  final String content;

  const LifeAspectDto({
    required this.aspect,
    required this.content,
  });

  @override
  List<Object?> get props => [aspect, content];

  factory LifeAspectDto.fromJson(Map<String, dynamic> json) =>
      _$LifeAspectDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LifeAspectDtoToJson(this);
}

/// Model for parsing the API response
@JsonSerializable()
class PalmAnalysisApiResponse extends Equatable {
  final bool success;
  final PalmAnalysisApiData data;

  const PalmAnalysisApiResponse({
    required this.success,
    required this.data,
  });

  @override
  List<Object?> get props => [success, data];

  factory PalmAnalysisApiResponse.fromJson(Map<String, dynamic> json) =>
      _$PalmAnalysisApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PalmAnalysisApiResponseToJson(this);
}

/// Data from API response
@JsonSerializable()
class PalmAnalysisApiData extends Equatable {
  final int id;
  final int userId;
  final String annotatedImage;
  final int palmLinesDetected;
  final int detectedHeartLine;
  final int detectedHeadLine;
  final int detectedLifeLine;
  final int detectedFateLine;
  final String targetLines;
  final int imageHeight;
  final int imageWidth;
  final int imageChannels;
  final String summaryText;
  final String createdAt;
  final String updatedAt;
  final List<InterpretationApiModel> interpretations;

  const PalmAnalysisApiData({
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
  });

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
      ];

  factory PalmAnalysisApiData.fromJson(Map<String, dynamic> json) =>
      _$PalmAnalysisApiDataFromJson(json);

  Map<String, dynamic> toJson() => _$PalmAnalysisApiDataToJson(this);
}

/// Interpretation model from API response
@JsonSerializable()
class InterpretationApiModel extends Equatable {
  final int id;
  final int analysisId;
  final String lineType;
  final String pattern;
  final String meaning;
  final int lengthPx;
  final double confidence;
  final String createdAt;

  const InterpretationApiModel({
    required this.id,
    required this.analysisId,
    required this.lineType,
    required this.pattern,
    required this.meaning,
    required this.lengthPx,
    required this.confidence,
    required this.createdAt,
  });

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

  factory InterpretationApiModel.fromJson(Map<String, dynamic> json) =>
      _$InterpretationApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$InterpretationApiModelToJson(this);
}
