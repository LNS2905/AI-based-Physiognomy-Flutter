// Facial Analysis Models
import 'package:json_annotation/json_annotation.dart';

part 'facial_analysis_models.g.dart';

/// Facial Analysis Metric
@JsonSerializable()
class FacialMetric {
  final String orientation;
  final double percentage;
  final double pixels;
  final String label;

  const FacialMetric({
    required this.orientation,
    required this.percentage,
    required this.pixels,
    required this.label,
  });

  factory FacialMetric.fromJson(Map<String, dynamic> json) =>
      _$FacialMetricFromJson(json);

  Map<String, dynamic> toJson() => _$FacialMetricToJson(this);
}

/// Facial Analysis DTO
@JsonSerializable()
class FacialAnalysisDto {
  final String userId;
  final String resultText;
  final String faceShape;
  final double harmonyScore;
  final Map<String, double> probabilities;
  final Map<String, double> harmonyDetails;
  final List<FacialMetric> metrics;
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

  factory FacialAnalysisDto.fromJson(Map<String, dynamic> json) =>
      _$FacialAnalysisDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FacialAnalysisDtoToJson(this);
}

/// Facial Analysis Model (with ID for stored analyses)
@JsonSerializable()
class FacialAnalysis {
  final int id;
  final int userId; // API returns int, not string
  final String resultText;
  final String faceShape;
  final double harmonyScore;
  final Map<String, double> probabilities;
  final Map<String, double> harmonyDetails;
  final List<FacialMetric> metrics;
  final String annotatedImage;
  final String processedAt;
  @JsonKey(name: 'createAt') // API uses 'createAt' not 'createdAt'
  final DateTime? createdAt;
  @JsonKey(name: 'updateAt') // API uses 'updateAt' not 'updatedAt'
  final DateTime? updatedAt;

  const FacialAnalysis({
    required this.id,
    required this.userId,
    required this.resultText,
    required this.faceShape,
    required this.harmonyScore,
    required this.probabilities,
    required this.harmonyDetails,
    required this.metrics,
    required this.annotatedImage,
    required this.processedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory FacialAnalysis.fromJson(Map<String, dynamic> json) =>
      _$FacialAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$FacialAnalysisToJson(this);

  /// Convert to DTO for API requests
  FacialAnalysisDto toDto() {
    return FacialAnalysisDto(
      userId: userId.toString(), // Convert int to string for API
      resultText: resultText,
      faceShape: faceShape,
      harmonyScore: harmonyScore,
      probabilities: probabilities,
      harmonyDetails: harmonyDetails,
      metrics: metrics,
      annotatedImage: annotatedImage,
      processedAt: processedAt,
    );
  }
}

/// Create Facial Analysis Request (for uploading new analysis)
@JsonSerializable()
class CreateFacialAnalysisRequest {
  final String imageBase64;
  final Map<String, dynamic>? metadata;

  const CreateFacialAnalysisRequest({
    required this.imageBase64,
    this.metadata,
  });

  factory CreateFacialAnalysisRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateFacialAnalysisRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateFacialAnalysisRequestToJson(this);
}

/// Update Facial Analysis Request
@JsonSerializable()
class UpdateFacialAnalysisRequest {
  final String? resultText;
  final String? faceShape;
  final double? harmonyScore;
  final Map<String, double>? probabilities;
  final Map<String, double>? harmonyDetails;
  final List<FacialMetric>? metrics;
  final String? annotatedImage;

  const UpdateFacialAnalysisRequest({
    this.resultText,
    this.faceShape,
    this.harmonyScore,
    this.probabilities,
    this.harmonyDetails,
    this.metrics,
    this.annotatedImage,
  });

  factory UpdateFacialAnalysisRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateFacialAnalysisRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateFacialAnalysisRequestToJson(this);
}

/// Facial Analysis Summary (for list views)
@JsonSerializable()
class FacialAnalysisSummary {
  final int id;
  final String faceShape;
  final double harmonyScore;
  final String processedAt;
  final DateTime? createdAt;

  const FacialAnalysisSummary({
    required this.id,
    required this.faceShape,
    required this.harmonyScore,
    required this.processedAt,
    this.createdAt,
  });

  factory FacialAnalysisSummary.fromJson(Map<String, dynamic> json) =>
      _$FacialAnalysisSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$FacialAnalysisSummaryToJson(this);
}

/// Face Shape enum for better type safety
enum FaceShape {
  @JsonValue('oval')
  oval,
  @JsonValue('round')
  round,
  @JsonValue('square')
  square,
  @JsonValue('heart')
  heart,
  @JsonValue('diamond')
  diamond,
  @JsonValue('oblong')
  oblong,
  @JsonValue('unknown')
  unknown,
}

extension FaceShapeExtension on FaceShape {
  String get displayName {
    switch (this) {
      case FaceShape.oval:
        return 'Oval';
      case FaceShape.round:
        return 'Round';
      case FaceShape.square:
        return 'Square';
      case FaceShape.heart:
        return 'Heart';
      case FaceShape.diamond:
        return 'Diamond';
      case FaceShape.oblong:
        return 'Oblong';
      case FaceShape.unknown:
        return 'Unknown';
    }
  }

  String get description {
    switch (this) {
      case FaceShape.oval:
        return 'Balanced proportions with gentle curves';
      case FaceShape.round:
        return 'Soft, curved lines with equal width and length';
      case FaceShape.square:
        return 'Strong jawline with angular features';
      case FaceShape.heart:
        return 'Wide forehead tapering to a narrow chin';
      case FaceShape.diamond:
        return 'Wide cheekbones with narrow forehead and chin';
      case FaceShape.oblong:
        return 'Longer than it is wide with straight sides';
      case FaceShape.unknown:
        return 'Unable to determine face shape';
    }
  }
}
