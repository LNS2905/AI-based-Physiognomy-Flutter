import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'facial_analysis_dto.g.dart';

/// DTO for saving facial analysis to backend API
/// Based on FacialAnalysisDto schema from swagger.json
@JsonSerializable()
class FacialAnalysisDto extends Equatable {
  final String userId;
  final String resultText;
  final String faceShape;
  final double harmonyScore;
  final Map<String, double> probabilities;
  final Map<String, double> harmonyDetails;
  final List<FacialMetricDto> metrics;
  final String annotatedImage;
  final String processedAt;

  const FacialAnalysisDto({
    required this.userId,
    required this.resultText,
    required this.faceShape,
    required this.harmonyScore,
    required this.probabilities,
    required this.harmonyDetails,
    required this.metrics,
    required this.annotatedImage,
    required this.processedAt,
  });

  /// Create DTO from CloudinaryAnalysisResponseModel
  factory FacialAnalysisDto.fromAnalysisResponse({
    required String userId,
    required String resultText,
    required String faceShape,
    required double harmonyScore,
    required Map<String, double> probabilities,
    required Map<String, double> harmonyDetails,
    required List<FacialMetricDto> metrics,
    required String annotatedImage,
    String? processedAt,
  }) {
    return FacialAnalysisDto(
      userId: userId,
      resultText: resultText,
      faceShape: faceShape,
      harmonyScore: harmonyScore,
      probabilities: probabilities,
      harmonyDetails: harmonyDetails,
      metrics: metrics,
      annotatedImage: annotatedImage,
      processedAt: processedAt ?? DateTime.now().toIso8601String(),
    );
  }

  @override
  List<Object?> get props => [
        userId,
        resultText,
        faceShape,
        harmonyScore,
        probabilities,
        harmonyDetails,
        metrics,
        annotatedImage,
        processedAt,
      ];

  /// JSON serialization
  factory FacialAnalysisDto.fromJson(Map<String, dynamic> json) =>
      _$FacialAnalysisDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FacialAnalysisDtoToJson(this);
}

/// Facial metric DTO for facial analysis
@JsonSerializable()
class FacialMetricDto extends Equatable {
  final String orientation;
  final double percentage;
  final double pixels;
  final String label;

  const FacialMetricDto({
    required this.orientation,
    required this.percentage,
    required this.pixels,
    required this.label,
  });

  @override
  List<Object?> get props => [orientation, percentage, pixels, label];

  factory FacialMetricDto.fromJson(Map<String, dynamic> json) =>
      _$FacialMetricDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FacialMetricDtoToJson(this);
}
