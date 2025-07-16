import 'package:equatable/equatable.dart';

/// Model for Cloudinary analysis response
class CloudinaryAnalysisResponseModel extends Equatable {
  final String status;
  final String message;
  final String userId;
  final String processedAt;
  final String? annotatedImageUrl;
  final CloudinaryAnalysisDataModel? analysis;

  const CloudinaryAnalysisResponseModel({
    required this.status,
    required this.message,
    required this.userId,
    required this.processedAt,
    this.annotatedImageUrl,
    this.analysis,
  });

  factory CloudinaryAnalysisResponseModel.fromJson(Map<String, dynamic> json) {
    return CloudinaryAnalysisResponseModel(
      status: json['status'] as String,
      message: json['message'] as String,
      userId: json['user_id'] as String,
      processedAt: json['processed_at'] as String,
      annotatedImageUrl: json['annotated_image_url'] as String?,
      analysis: json['analysis'] != null
          ? CloudinaryAnalysisDataModel.fromJson(json['analysis'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'user_id': userId,
      'processed_at': processedAt,
      'annotated_image_url': annotatedImageUrl,
      'analysis': analysis?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        status,
        message,
        userId,
        processedAt,
        annotatedImageUrl,
        analysis,
      ];
}

/// Model for analysis data within Cloudinary response
class CloudinaryAnalysisDataModel extends Equatable {
  final CloudinaryMetadataModel? metadata;
  final CloudinaryAnalysisResultModel? analysisResult;
  final String? result;

  const CloudinaryAnalysisDataModel({
    this.metadata,
    this.analysisResult,
    this.result,
  });

  factory CloudinaryAnalysisDataModel.fromJson(Map<String, dynamic> json) {
    return CloudinaryAnalysisDataModel(
      metadata: json['metadata'] != null
          ? CloudinaryMetadataModel.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      analysisResult: json['analysisResult'] != null
          ? CloudinaryAnalysisResultModel.fromJson(json['analysisResult'] as Map<String, dynamic>)
          : null,
      result: json['result'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata?.toJson(),
      'analysisResult': analysisResult?.toJson(),
      'result': result,
    };
  }

  @override
  List<Object?> get props => [metadata, analysisResult, result];
}

/// Model for metadata within analysis
class CloudinaryMetadataModel extends Equatable {
  final String? reportTitle;
  final String? sourceFilename;
  final String? timestampUTC;

  const CloudinaryMetadataModel({
    this.reportTitle,
    this.sourceFilename,
    this.timestampUTC,
  });

  factory CloudinaryMetadataModel.fromJson(Map<String, dynamic> json) {
    return CloudinaryMetadataModel(
      reportTitle: json['reportTitle'] as String?,
      sourceFilename: json['sourceFilename'] as String?,
      timestampUTC: json['timestampUTC'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportTitle': reportTitle,
      'sourceFilename': sourceFilename,
      'timestampUTC': timestampUTC,
    };
  }

  @override
  List<Object?> get props => [reportTitle, sourceFilename, timestampUTC];
}

/// Model for analysisResult within Cloudinary response
class CloudinaryAnalysisResultModel extends Equatable {
  final CloudinaryFaceModel? face;

  const CloudinaryAnalysisResultModel({
    this.face,
  });

  factory CloudinaryAnalysisResultModel.fromJson(Map<String, dynamic> json) {
    return CloudinaryAnalysisResultModel(
      face: json['face'] != null
          ? CloudinaryFaceModel.fromJson(json['face'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'face': face?.toJson(),
    };
  }

  @override
  List<Object?> get props => [face];
}

/// Model for face data within analysisResult
class CloudinaryFaceModel extends Equatable {
  final CloudinaryFaceShapeModel? shape;
  final CloudinaryProportionalityModel? proportionality;

  const CloudinaryFaceModel({
    this.shape,
    this.proportionality,
  });

  factory CloudinaryFaceModel.fromJson(Map<String, dynamic> json) {
    return CloudinaryFaceModel(
      shape: json['shape'] != null
          ? CloudinaryFaceShapeModel.fromJson(json['shape'] as Map<String, dynamic>)
          : null,
      proportionality: json['proportionality'] != null
          ? CloudinaryProportionalityModel.fromJson(json['proportionality'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shape': shape?.toJson(),
      'proportionality': proportionality?.toJson(),
    };
  }

  @override
  List<Object?> get props => [shape, proportionality];
}

/// Model for face shape data
class CloudinaryFaceShapeModel extends Equatable {
  final String? primary;
  final Map<String, double>? probabilities;

  const CloudinaryFaceShapeModel({
    this.primary,
    this.probabilities,
  });

  factory CloudinaryFaceShapeModel.fromJson(Map<String, dynamic> json) {
    Map<String, double>? parsedProbabilities;
    if (json['probabilities'] != null) {
      final probData = json['probabilities'] as Map<String, dynamic>;
      parsedProbabilities = probData.map((key, value) => MapEntry(key, (value as num).toDouble()));
    }

    return CloudinaryFaceShapeModel(
      primary: json['primary'] as String?,
      probabilities: parsedProbabilities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'probabilities': probabilities,
    };
  }

  @override
  List<Object?> get props => [primary, probabilities];
}

/// Model for proportionality data
class CloudinaryProportionalityModel extends Equatable {
  final double? overallHarmonyScore;
  final Map<String, double>? harmonyScores;
  final List<CloudinaryMetricModel>? metrics;

  const CloudinaryProportionalityModel({
    this.overallHarmonyScore,
    this.harmonyScores,
    this.metrics,
  });

  factory CloudinaryProportionalityModel.fromJson(Map<String, dynamic> json) {
    Map<String, double>? parsedHarmonyScores;
    if (json['harmonyScores'] != null) {
      final harmonyData = json['harmonyScores'] as Map<String, dynamic>;
      parsedHarmonyScores = harmonyData.map((key, value) => MapEntry(key, (value as num).toDouble()));
    }

    List<CloudinaryMetricModel>? parsedMetrics;
    if (json['metrics'] != null) {
      final metricsData = json['metrics'] as List<dynamic>;
      parsedMetrics = metricsData.map((metric) => CloudinaryMetricModel.fromJson(metric as Map<String, dynamic>)).toList();
    }

    return CloudinaryProportionalityModel(
      overallHarmonyScore: (json['overallHarmonyScore'] as num?)?.toDouble(),
      harmonyScores: parsedHarmonyScores,
      metrics: parsedMetrics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallHarmonyScore': overallHarmonyScore,
      'harmonyScores': harmonyScores,
      'metrics': metrics?.map((metric) => metric.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [overallHarmonyScore, harmonyScores, metrics];
}

/// Model for individual metric data
class CloudinaryMetricModel extends Equatable {
  final String? label;
  final double? pixels;
  final double? percentage;
  final String? orientation;

  const CloudinaryMetricModel({
    this.label,
    this.pixels,
    this.percentage,
    this.orientation,
  });

  factory CloudinaryMetricModel.fromJson(Map<String, dynamic> json) {
    return CloudinaryMetricModel(
      label: json['label'] as String?,
      pixels: (json['pixels'] as num?)?.toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      orientation: json['orientation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'pixels': pixels,
      'percentage': percentage,
      'orientation': orientation,
    };
  }

  @override
  List<Object?> get props => [label, pixels, percentage, orientation];
}
