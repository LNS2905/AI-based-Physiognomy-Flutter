import 'package:equatable/equatable.dart';

/// Model for Cloudinary analysis response
class CloudinaryAnalysisResponseModel extends Equatable {
  final String status;
  final String message;
  final String userId;
  final String processedAt;
  final double totalHarmonyScore;
  final String? annotatedImageUrl;
  final String? reportImageUrl;
  final CloudinaryAnalysisDataModel? analysis;

  const CloudinaryAnalysisResponseModel({
    required this.status,
    required this.message,
    required this.userId,
    required this.processedAt,
    required this.totalHarmonyScore,
    this.annotatedImageUrl,
    this.reportImageUrl,
    this.analysis,
  });

  factory CloudinaryAnalysisResponseModel.fromJson(Map<String, dynamic> json) {
    return CloudinaryAnalysisResponseModel(
      status: json['status'] as String,
      message: json['message'] as String,
      userId: json['user_id'] as String,
      processedAt: json['processed_at'] as String,
      totalHarmonyScore: (json['total_harmony_score'] as num).toDouble(),
      annotatedImageUrl: json['annotated_image_url'] as String?,
      reportImageUrl: json['report_image_url'] as String?,
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
      'total_harmony_score': totalHarmonyScore,
      'annotated_image_url': annotatedImageUrl,
      'report_image_url': reportImageUrl,
      'analysis': analysis?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        status,
        message,
        userId,
        processedAt,
        totalHarmonyScore,
        annotatedImageUrl,
        reportImageUrl,
        analysis,
      ];
}

/// Model for analysis data within Cloudinary response
class CloudinaryAnalysisDataModel extends Equatable {
  final String? faceShape;
  final Map<String, dynamic>? features;
  final String? result;
  final CloudinaryAnalysisResultModel? analysisResult;

  const CloudinaryAnalysisDataModel({
    this.faceShape,
    this.features,
    this.result,
    this.analysisResult,
  });

  factory CloudinaryAnalysisDataModel.fromJson(Map<String, dynamic> json) {
    return CloudinaryAnalysisDataModel(
      faceShape: json['face_shape'] as String?,
      features: json['features'] as Map<String, dynamic>?,
      result: json['result'] as String?,
      analysisResult: json['analysisResult'] != null
          ? CloudinaryAnalysisResultModel.fromJson(json['analysisResult'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'face_shape': faceShape,
      'features': features,
      'result': result,
      'analysisResult': analysisResult?.toJson(),
    };
  }

  @override
  List<Object?> get props => [faceShape, features, result, analysisResult];
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
  final double? confidence;
  final CloudinaryFaceShapeModel? shape;
  final Map<String, dynamic>? boundingBoxOriginal;
  final List<dynamic>? features;
  final Map<String, dynamic>? proportionality;

  const CloudinaryFaceModel({
    this.confidence,
    this.shape,
    this.boundingBoxOriginal,
    this.features,
    this.proportionality,
  });

  factory CloudinaryFaceModel.fromJson(Map<String, dynamic> json) {
    return CloudinaryFaceModel(
      confidence: (json['confidence'] as num?)?.toDouble(),
      shape: json['shape'] != null
          ? CloudinaryFaceShapeModel.fromJson(json['shape'] as Map<String, dynamic>)
          : null,
      boundingBoxOriginal: json['boundingBoxOriginal'] as Map<String, dynamic>?,
      features: json['features'] as List<dynamic>?,
      proportionality: json['proportionality'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confidence': confidence,
      'shape': shape?.toJson(),
      'boundingBoxOriginal': boundingBoxOriginal,
      'features': features,
      'proportionality': proportionality,
    };
  }

  @override
  List<Object?> get props => [confidence, shape, boundingBoxOriginal, features, proportionality];
}

/// Model for face shape data
class CloudinaryFaceShapeModel extends Equatable {
  final String? primary;
  final Map<String, dynamic>? probabilities;

  const CloudinaryFaceShapeModel({
    this.primary,
    this.probabilities,
  });

  factory CloudinaryFaceShapeModel.fromJson(Map<String, dynamic> json) {
    return CloudinaryFaceShapeModel(
      primary: json['primary'] as String?,
      probabilities: json['probabilities'] as Map<String, dynamic>?,
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
