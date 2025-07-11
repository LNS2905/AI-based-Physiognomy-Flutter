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

  const CloudinaryAnalysisDataModel({
    this.faceShape,
    this.features,
    this.result,
  });

  factory CloudinaryAnalysisDataModel.fromJson(Map<String, dynamic> json) {
    return CloudinaryAnalysisDataModel(
      faceShape: json['face_shape'] as String?,
      features: json['features'] as Map<String, dynamic>?,
      result: json['result'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'face_shape': faceShape,
      'features': features,
      'result': result,
    };
  }

  @override
  List<Object?> get props => [faceShape, features, result];
}
