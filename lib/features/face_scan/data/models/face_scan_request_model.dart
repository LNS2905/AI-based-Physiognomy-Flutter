import 'package:equatable/equatable.dart';

/// Model for face scan request
class FaceScanRequestModel extends Equatable {
  final String? imageBase64;
  final String? imagePath;
  final Map<String, dynamic>? metadata;
  final List<String>? analysisTypes;

  const FaceScanRequestModel({
    this.imageBase64,
    this.imagePath,
    this.metadata,
    this.analysisTypes,
  });

  factory FaceScanRequestModel.fromJson(Map<String, dynamic> json) {
    return FaceScanRequestModel(
      imageBase64: json['imageBase64'] as String?,
      imagePath: json['imagePath'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      analysisTypes: (json['analysisTypes'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageBase64': imageBase64,
      'imagePath': imagePath,
      'metadata': metadata,
      'analysisTypes': analysisTypes,
    };
  }

  @override
  List<Object?> get props => [imageBase64, imagePath, metadata, analysisTypes];

  FaceScanRequestModel copyWith({
    String? imageBase64,
    String? imagePath,
    Map<String, dynamic>? metadata,
    List<String>? analysisTypes,
  }) {
    return FaceScanRequestModel(
      imageBase64: imageBase64 ?? this.imageBase64,
      imagePath: imagePath ?? this.imagePath,
      metadata: metadata ?? this.metadata,
      analysisTypes: analysisTypes ?? this.analysisTypes,
    );
  }
}
