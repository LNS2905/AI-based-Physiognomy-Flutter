import 'package:equatable/equatable.dart';

/// Model for face scan response
class FaceScanResponseModel extends Equatable {
  final String id;
  final String status;
  final FaceAnalysisModel? analysis;
  final String? message;
  final DateTime createdAt;
  final DateTime? completedAt;

  const FaceScanResponseModel({
    required this.id,
    required this.status,
    this.analysis,
    this.message,
    required this.createdAt,
    this.completedAt,
  });

  factory FaceScanResponseModel.fromJson(Map<String, dynamic> json) {
    return FaceScanResponseModel(
      id: json['id'] as String,
      status: json['status'] as String,
      analysis: json['analysis'] != null
          ? FaceAnalysisModel.fromJson(json['analysis'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'analysis': analysis?.toJson(),
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, status, analysis, message, createdAt, completedAt];

  FaceScanResponseModel copyWith({
    String? id,
    String? status,
    FaceAnalysisModel? analysis,
    String? message,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return FaceScanResponseModel(
      id: id ?? this.id,
      status: status ?? this.status,
      analysis: analysis ?? this.analysis,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Model for face analysis results
class FaceAnalysisModel extends Equatable {
  final FacialFeaturesModel features;
  final PersonalityTraitsModel personality;
  final double confidence;
  final List<String> detectedFeatures;

  const FaceAnalysisModel({
    required this.features,
    required this.personality,
    required this.confidence,
    required this.detectedFeatures,
  });

  factory FaceAnalysisModel.fromJson(Map<String, dynamic> json) {
    return FaceAnalysisModel(
      features: FacialFeaturesModel.fromJson(json['features'] as Map<String, dynamic>),
      personality: PersonalityTraitsModel.fromJson(json['personality'] as Map<String, dynamic>),
      confidence: (json['confidence'] as num).toDouble(),
      detectedFeatures: (json['detectedFeatures'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'features': features.toJson(),
      'personality': personality.toJson(),
      'confidence': confidence,
      'detectedFeatures': detectedFeatures,
    };
  }

  @override
  List<Object?> get props => [features, personality, confidence, detectedFeatures];
}

/// Model for facial features
class FacialFeaturesModel extends Equatable {
  final EyeAnalysisModel eyes;
  final NoseAnalysisModel nose;
  final MouthAnalysisModel mouth;
  final JawlineAnalysisModel jawline;

  const FacialFeaturesModel({
    required this.eyes,
    required this.nose,
    required this.mouth,
    required this.jawline,
  });

  factory FacialFeaturesModel.fromJson(Map<String, dynamic> json) {
    return FacialFeaturesModel(
      eyes: EyeAnalysisModel.fromJson(json['eyes'] as Map<String, dynamic>),
      nose: NoseAnalysisModel.fromJson(json['nose'] as Map<String, dynamic>),
      mouth: MouthAnalysisModel.fromJson(json['mouth'] as Map<String, dynamic>),
      jawline: JawlineAnalysisModel.fromJson(json['jawline'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eyes': eyes.toJson(),
      'nose': nose.toJson(),
      'mouth': mouth.toJson(),
      'jawline': jawline.toJson(),
    };
  }

  @override
  List<Object?> get props => [eyes, nose, mouth, jawline];
}

/// Model for eye analysis
class EyeAnalysisModel extends Equatable {
  final String shape;
  final String size;
  final double distance;
  final List<String> characteristics;

  const EyeAnalysisModel({
    required this.shape,
    required this.size,
    required this.distance,
    required this.characteristics,
  });

  factory EyeAnalysisModel.fromJson(Map<String, dynamic> json) {
    return EyeAnalysisModel(
      shape: json['shape'] as String,
      size: json['size'] as String,
      distance: (json['distance'] as num).toDouble(),
      characteristics: (json['characteristics'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shape': shape,
      'size': size,
      'distance': distance,
      'characteristics': characteristics,
    };
  }

  @override
  List<Object?> get props => [shape, size, distance, characteristics];
}

/// Model for nose analysis
class NoseAnalysisModel extends Equatable {
  final String shape;
  final String size;
  final String bridge;
  final List<String> characteristics;

  const NoseAnalysisModel({
    required this.shape,
    required this.size,
    required this.bridge,
    required this.characteristics,
  });

  factory NoseAnalysisModel.fromJson(Map<String, dynamic> json) {
    return NoseAnalysisModel(
      shape: json['shape'] as String,
      size: json['size'] as String,
      bridge: json['bridge'] as String,
      characteristics: (json['characteristics'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shape': shape,
      'size': size,
      'bridge': bridge,
      'characteristics': characteristics,
    };
  }

  @override
  List<Object?> get props => [shape, size, bridge, characteristics];
}

/// Model for mouth analysis
class MouthAnalysisModel extends Equatable {
  final String shape;
  final String size;
  final String lipThickness;
  final List<String> characteristics;

  const MouthAnalysisModel({
    required this.shape,
    required this.size,
    required this.lipThickness,
    required this.characteristics,
  });

  factory MouthAnalysisModel.fromJson(Map<String, dynamic> json) {
    return MouthAnalysisModel(
      shape: json['shape'] as String,
      size: json['size'] as String,
      lipThickness: json['lipThickness'] as String,
      characteristics: (json['characteristics'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shape': shape,
      'size': size,
      'lipThickness': lipThickness,
      'characteristics': characteristics,
    };
  }

  @override
  List<Object?> get props => [shape, size, lipThickness, characteristics];
}

/// Model for jawline analysis
class JawlineAnalysisModel extends Equatable {
  final String shape;
  final String definition;
  final String width;
  final List<String> characteristics;

  const JawlineAnalysisModel({
    required this.shape,
    required this.definition,
    required this.width,
    required this.characteristics,
  });

  factory JawlineAnalysisModel.fromJson(Map<String, dynamic> json) {
    return JawlineAnalysisModel(
      shape: json['shape'] as String,
      definition: json['definition'] as String,
      width: json['width'] as String,
      characteristics: (json['characteristics'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shape': shape,
      'definition': definition,
      'width': width,
      'characteristics': characteristics,
    };
  }

  @override
  List<Object?> get props => [shape, definition, width, characteristics];
}

/// Model for personality traits
class PersonalityTraitsModel extends Equatable {
  final Map<String, double> traits;
  final String dominantTrait;
  final String description;

  const PersonalityTraitsModel({
    required this.traits,
    required this.dominantTrait,
    required this.description,
  });

  factory PersonalityTraitsModel.fromJson(Map<String, dynamic> json) {
    final traitsMap = json['traits'] as Map<String, dynamic>;
    final traits = traitsMap.map((key, value) => MapEntry(key, (value as num).toDouble()));

    return PersonalityTraitsModel(
      traits: traits,
      dominantTrait: json['dominantTrait'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'traits': traits,
      'dominantTrait': dominantTrait,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [traits, dominantTrait, description];
}
