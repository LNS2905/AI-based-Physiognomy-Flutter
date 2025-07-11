import 'package:equatable/equatable.dart';

/// Model for Cloudinary analysis request
class CloudinaryAnalysisRequestModel extends Equatable {
  final String signedUrl;
  final String userId;
  final String timestamp;
  final String originalFolderPath;

  const CloudinaryAnalysisRequestModel({
    required this.signedUrl,
    required this.userId,
    required this.timestamp,
    required this.originalFolderPath,
  });

  factory CloudinaryAnalysisRequestModel.fromJson(Map<String, dynamic> json) {
    return CloudinaryAnalysisRequestModel(
      signedUrl: json['signed_url'] as String,
      userId: json['user_id'] as String,
      timestamp: json['timestamp'] as String,
      originalFolderPath: json['original_folder_path'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'signed_url': signedUrl,
      'user_id': userId,
      'timestamp': timestamp,
      'original_folder_path': originalFolderPath,
    };
  }

  @override
  List<Object?> get props => [signedUrl, userId, timestamp, originalFolderPath];

  CloudinaryAnalysisRequestModel copyWith({
    String? signedUrl,
    String? userId,
    String? timestamp,
    String? originalFolderPath,
  }) {
    return CloudinaryAnalysisRequestModel(
      signedUrl: signedUrl ?? this.signedUrl,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      originalFolderPath: originalFolderPath ?? this.originalFolderPath,
    );
  }
}
