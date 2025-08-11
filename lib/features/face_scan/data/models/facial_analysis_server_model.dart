import 'package:json_annotation/json_annotation.dart';

part 'facial_analysis_server_model.g.dart';

/// Model for facial analysis data from server
@JsonSerializable()
class FacialAnalysisServerModel {
  final int id;
  final String userId;
  final String resultText;
  final String faceShape;
  final double harmonyScore;
  final Map<String, double> probabilities;
  final Map<String, double> harmonyDetails;
  final List<FacialMetricServerModel> metrics;
  final String annotatedImage;
  final String processedAt;
  final String? createdAt;  // Optional vì API trả về createAt
  final String? updatedAt;  // Optional vì API trả về updateAt

  FacialAnalysisServerModel({
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

  factory FacialAnalysisServerModel.fromJson(Map<String, dynamic> json) {
    // Handle field name differences from API
    final modifiedJson = Map<String, dynamic>.from(json);
    
    // API returns 'createAt' and 'updateAt', but we expect 'createdAt' and 'updatedAt'
    if (json.containsKey('createAt')) {
      modifiedJson['createdAt'] = json['createAt'];
    }
    if (json.containsKey('updateAt')) {
      modifiedJson['updatedAt'] = json['updateAt'];
    }
    
    // Handle userId as either int or string
    if (json['userId'] is int) {
      modifiedJson['userId'] = json['userId'].toString();
    }
    
    return _$FacialAnalysisServerModelFromJson(modifiedJson);
  }

  Map<String, dynamic> toJson() => _$FacialAnalysisServerModelToJson(this);
}

/// Model for facial metric from server
@JsonSerializable()
class FacialMetricServerModel {
  final String orientation;
  final double percentage;
  final double pixels;
  final String label;

  FacialMetricServerModel({
    required this.orientation,
    required this.percentage,
    required this.pixels,
    required this.label,
  });

  factory FacialMetricServerModel.fromJson(Map<String, dynamic> json) =>
      _$FacialMetricServerModelFromJson(json);

  Map<String, dynamic> toJson() => _$FacialMetricServerModelToJson(this);
}