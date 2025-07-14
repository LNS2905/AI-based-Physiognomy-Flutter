import 'package:equatable/equatable.dart';

/// Model for Palm analysis response from Cloudinary endpoint - Updated to match actual API
class PalmAnalysisResponseModel extends Equatable {
  final String status;
  final String message;
  final String userId;
  final String processedAt;
  final int handsDetected;
  final double processingTime;
  final String analysisType;
  final String? annotatedImageUrl;
  final String? comparisonImageUrl;
  final PalmAnalysisDataModel? analysis;
  final MeasurementsSummaryModel? measurementsSummary;

  const PalmAnalysisResponseModel({
    required this.status,
    required this.message,
    required this.userId,
    required this.processedAt,
    required this.handsDetected,
    required this.processingTime,
    required this.analysisType,
    this.annotatedImageUrl,
    this.comparisonImageUrl,
    this.analysis,
    this.measurementsSummary,
  });

  factory PalmAnalysisResponseModel.fromJson(Map<String, dynamic> json) {
    return PalmAnalysisResponseModel(
      status: json['status'] as String? ?? 'success',
      message: json['message'] as String? ?? 'Palm analysis completed',
      userId: json['user_id'] as String? ?? 'anonymous',
      processedAt: json['processed_at'] as String? ?? DateTime.now().toIso8601String(),
      handsDetected: json['hands_detected'] as int? ?? 0,
      processingTime: (json['processing_time'] as num?)?.toDouble() ?? 0.0,
      analysisType: json['analysis_type'] as String? ?? 'palm_analysis',
      annotatedImageUrl: json['annotated_image_url'] as String?,
      comparisonImageUrl: json['comparison_image_url'] as String?,
      analysis: json['analysis'] != null
          ? PalmAnalysisDataModel.fromJson(json['analysis'] as Map<String, dynamic>)
          : null,
      measurementsSummary: json['measurements_summary'] != null
          ? MeasurementsSummaryModel.fromJson(json['measurements_summary'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'user_id': userId,
      'processed_at': processedAt,
      'hands_detected': handsDetected,
      'processing_time': processingTime,
      'analysis_type': analysisType,
      'annotated_image_url': annotatedImageUrl,
      'comparison_image_url': comparisonImageUrl,
      'analysis': analysis?.toJson(),
      'measurements_summary': measurementsSummary?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        status,
        message,
        userId,
        processedAt,
        handsDetected,
        processingTime,
        analysisType,
        annotatedImageUrl,
        comparisonImageUrl,
        analysis,
        measurementsSummary,
      ];
}

/// Model for palm analysis data - Updated to match actual API response
class PalmAnalysisDataModel extends Equatable {
  final PalmDetectionModel? palmDetection;
  final int handsDetected;
  final List<dynamic> handsData;
  final Map<String, dynamic> measurements;
  final Map<String, dynamic> palmLines;
  final Map<String, dynamic> fingerAnalysis;
  final MetadataModel? metadata;

  const PalmAnalysisDataModel({
    this.palmDetection,
    required this.handsDetected,
    required this.handsData,
    required this.measurements,
    required this.palmLines,
    required this.fingerAnalysis,
    this.metadata,
  });

  factory PalmAnalysisDataModel.fromJson(Map<String, dynamic> json) {
    return PalmAnalysisDataModel(
      palmDetection: json['palm_detection'] != null
          ? PalmDetectionModel.fromJson(json['palm_detection'] as Map<String, dynamic>)
          : null,
      handsDetected: json['hands_detected'] as int? ?? 0,
      handsData: json['hands_data'] as List<dynamic>? ?? [],
      measurements: json['measurements'] as Map<String, dynamic>? ?? {},
      palmLines: json['palm_lines'] as Map<String, dynamic>? ?? {},
      fingerAnalysis: json['finger_analysis'] as Map<String, dynamic>? ?? {},
      metadata: json['metadata'] != null
          ? MetadataModel.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'palm_detection': palmDetection?.toJson(),
      'hands_detected': handsDetected,
      'hands_data': handsData,
      'measurements': measurements,
      'palm_lines': palmLines,
      'finger_analysis': fingerAnalysis,
      'metadata': metadata?.toJson(),
    };
  }

  @override
  List<Object?> get props => [palmDetection, handsDetected, handsData, measurements, palmLines, fingerAnalysis, metadata];
}

/// Model for palm detection data
class PalmDetectionModel extends Equatable {
  final int handsDetected;
  final List<HandDataModel>? handsData;

  const PalmDetectionModel({
    required this.handsDetected,
    this.handsData,
  });

  factory PalmDetectionModel.fromJson(Map<String, dynamic> json) {
    return PalmDetectionModel(
      handsDetected: json['hands_detected'] as int? ?? 0,
      handsData: json['hands_data'] != null
          ? (json['hands_data'] as List<dynamic>)
              .map((item) => HandDataModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hands_detected': handsDetected,
      'hands_data': handsData?.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [handsDetected, handsData];
}

/// Model for individual hand data
class HandDataModel extends Equatable {
  final int? handId;
  final String? handSide;
  final Map<String, dynamic>? keypoints;
  final Map<String, dynamic>? additionalData;

  const HandDataModel({
    this.handId,
    this.handSide,
    this.keypoints,
    this.additionalData,
  });

  factory HandDataModel.fromJson(Map<String, dynamic> json) {
    return HandDataModel(
      handId: json['hand_id'] as int?,
      handSide: json['hand_side'] as String?,
      keypoints: json['keypoints'] as Map<String, dynamic>?,
      additionalData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hand_id': handId,
      'hand_side': handSide,
      'keypoints': keypoints,
      ...?additionalData,
    };
  }

  @override
  List<Object?> get props => [handId, handSide, keypoints, additionalData];
}

/// Model for measurements summary
class MeasurementsSummaryModel extends Equatable {
  final int totalHands;
  final int leftHands;
  final int rightHands;
  final double averageHandLength;
  final double averagePalmWidth;
  final List<String> palmTypes;
  final Map<String, dynamic> confidenceScores;

  const MeasurementsSummaryModel({
    required this.totalHands,
    required this.leftHands,
    required this.rightHands,
    required this.averageHandLength,
    required this.averagePalmWidth,
    required this.palmTypes,
    required this.confidenceScores,
  });

  factory MeasurementsSummaryModel.fromJson(Map<String, dynamic> json) {
    return MeasurementsSummaryModel(
      totalHands: json['total_hands'] as int? ?? 0,
      leftHands: json['left_hands'] as int? ?? 0,
      rightHands: json['right_hands'] as int? ?? 0,
      averageHandLength: (json['average_hand_length'] as num?)?.toDouble() ?? 0.0,
      averagePalmWidth: (json['average_palm_width'] as num?)?.toDouble() ?? 0.0,
      palmTypes: (json['palm_types'] as List<dynamic>?)?.cast<String>() ?? [],
      confidenceScores: json['confidence_scores'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_hands': totalHands,
      'left_hands': leftHands,
      'right_hands': rightHands,
      'average_hand_length': averageHandLength,
      'average_palm_width': averagePalmWidth,
      'palm_types': palmTypes,
      'confidence_scores': confidenceScores,
    };
  }

  @override
  List<Object?> get props => [totalHands, leftHands, rightHands, averageHandLength, averagePalmWidth, palmTypes, confidenceScores];
}

/// Model for metadata
class MetadataModel extends Equatable {
  final double processingTime;
  final ModelInfoModel? modelInfo;
  final String analysisTimestamp;

  const MetadataModel({
    required this.processingTime,
    this.modelInfo,
    required this.analysisTimestamp,
  });

  factory MetadataModel.fromJson(Map<String, dynamic> json) {
    return MetadataModel(
      processingTime: (json['processing_time'] as num?)?.toDouble() ?? 0.0,
      modelInfo: json['model_info'] != null
          ? ModelInfoModel.fromJson(json['model_info'] as Map<String, dynamic>)
          : null,
      analysisTimestamp: json['analysis_timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'processing_time': processingTime,
      'model_info': modelInfo?.toJson(),
      'analysis_timestamp': analysisTimestamp,
    };
  }

  @override
  List<Object?> get props => [processingTime, modelInfo, analysisTimestamp];
}

/// Model for model info
class ModelInfoModel extends Equatable {
  final String modelPath;
  final String modelType;
  final String version;

  const ModelInfoModel({
    required this.modelPath,
    required this.modelType,
    required this.version,
  });

  factory ModelInfoModel.fromJson(Map<String, dynamic> json) {
    return ModelInfoModel(
      modelPath: json['model_path'] as String? ?? '',
      modelType: json['model_type'] as String? ?? '',
      version: json['version'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_path': modelPath,
      'model_type': modelType,
      'version': version,
    };
  }

  @override
  List<Object?> get props => [modelPath, modelType, version];
}




