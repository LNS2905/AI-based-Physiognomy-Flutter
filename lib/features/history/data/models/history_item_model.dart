import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../face_scan/data/models/cloudinary_analysis_response_model.dart';
import '../../../palm_scan/data/models/palm_analysis_response_model.dart';

part 'history_item_model.g.dart';

/// Enum for history item types
enum HistoryItemType {
  @JsonValue('face_analysis')
  faceAnalysis,
  @JsonValue('palm_analysis')
  palmAnalysis,
  @JsonValue('chat_conversation')
  chatConversation,
}

/// Base history item model
@JsonSerializable()
class HistoryItemModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final HistoryItemType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;
  final String? thumbnailUrl;
  final bool isFavorite;
  final List<String> tags;

  const HistoryItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
    this.thumbnailUrl,
    this.isFavorite = false,
    this.tags = const [],
  });

  /// Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    }
  }

  /// Get type display name
  String get typeDisplayName {
    switch (type) {
      case HistoryItemType.faceAnalysis:
        return 'Phân tích khuôn mặt';
      case HistoryItemType.palmAnalysis:
        return 'Phân tích vân tay';
      case HistoryItemType.chatConversation:
        return 'Trò chuyện AI';
    }
  }

  /// Get type icon
  String get typeIcon {
    switch (type) {
      case HistoryItemType.faceAnalysis:
        return '👤';
      case HistoryItemType.palmAnalysis:
        return '✋';
      case HistoryItemType.chatConversation:
        return '💬';
    }
  }

  /// Copy with method
  HistoryItemModel copyWith({
    String? id,
    String? title,
    String? description,
    HistoryItemType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    String? thumbnailUrl,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return HistoryItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        createdAt,
        updatedAt,
        metadata,
        thumbnailUrl,
        isFavorite,
        tags,
      ];

  /// JSON serialization
  factory HistoryItemModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryItemModelToJson(this);
}

/// Face analysis history item
@JsonSerializable()
class FaceAnalysisHistoryModel extends HistoryItemModel {
  final CloudinaryAnalysisResponseModel analysisResult;
  final String? originalImageUrl;
  final String? annotatedImageUrl;
  final String? reportUrl;

  const FaceAnalysisHistoryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    required super.updatedAt,
    required this.analysisResult,
    this.originalImageUrl,
    this.annotatedImageUrl,
    this.reportUrl,
    super.metadata,
    super.thumbnailUrl,
    super.isFavorite,
    super.tags,
  }) : super(type: HistoryItemType.faceAnalysis);

  /// Create from analysis result
  factory FaceAnalysisHistoryModel.fromAnalysis({
    required String id,
    required CloudinaryAnalysisResponseModel analysisResult,
    String? originalImageUrl,
    String? annotatedImageUrl,
    String? reportUrl,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final primaryShape = analysisResult.analysis?.analysisResult?.face?.shape?.primary ?? 'Unknown';
    
    return FaceAnalysisHistoryModel(
      id: id,
      title: 'Phân tích khuôn mặt - $primaryShape',
      description: 'Kết quả phân tích cho thấy khuôn mặt có dạng $primaryShape với các đặc điểm tương ứng.',
      createdAt: now,
      updatedAt: now,
      analysisResult: analysisResult,
      originalImageUrl: originalImageUrl,
      annotatedImageUrl: annotatedImageUrl ?? analysisResult.annotatedImageUrl,
      reportUrl: reportUrl,
      metadata: metadata,
      thumbnailUrl: annotatedImageUrl ?? analysisResult.annotatedImageUrl,
      tags: ['face', 'analysis', primaryShape.toLowerCase()],
    );
  }

  @override
  FaceAnalysisHistoryModel copyWith({
    String? id,
    String? title,
    String? description,
    HistoryItemType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    CloudinaryAnalysisResponseModel? analysisResult,
    String? originalImageUrl,
    String? annotatedImageUrl,
    String? reportUrl,
    Map<String, dynamic>? metadata,
    String? thumbnailUrl,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return FaceAnalysisHistoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      analysisResult: analysisResult ?? this.analysisResult,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      annotatedImageUrl: annotatedImageUrl ?? this.annotatedImageUrl,
      reportUrl: reportUrl ?? this.reportUrl,
      metadata: metadata ?? this.metadata,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        analysisResult,
        originalImageUrl,
        annotatedImageUrl,
        reportUrl,
      ];

  /// JSON serialization
  factory FaceAnalysisHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$FaceAnalysisHistoryModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FaceAnalysisHistoryModelToJson(this);
}

/// Palm analysis history item
@JsonSerializable()
class PalmAnalysisHistoryModel extends HistoryItemModel {
  final PalmAnalysisResponseModel analysisResult;
  final String? originalImageUrl;
  final String? annotatedImageUrl;
  final String? comparisonImageUrl;

  const PalmAnalysisHistoryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    required super.updatedAt,
    required this.analysisResult,
    this.originalImageUrl,
    this.annotatedImageUrl,
    this.comparisonImageUrl,
    super.metadata,
    super.thumbnailUrl,
    super.isFavorite,
    super.tags,
  }) : super(type: HistoryItemType.palmAnalysis);

  /// Create from analysis result
  factory PalmAnalysisHistoryModel.fromAnalysis({
    required String id,
    required PalmAnalysisResponseModel analysisResult,
    String? originalImageUrl,
    String? annotatedImageUrl,
    String? comparisonImageUrl,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final totalLines = analysisResult.analysis?.palmLines.length ?? 0;
    
    // Create more accurate title and description
    final lineText = totalLines > 0 ? '$totalLines đường chỉ tay' : 'phân tích vân tay';
    
    return PalmAnalysisHistoryModel(
      id: id,
      title: 'Phân tích vân tay - $lineText',
      description: totalLines > 0 
          ? 'Kết quả phân tích phát hiện $totalLines đường chỉ tay với độ chính xác cao.'
          : 'Kết quả phân tích vân tay đã hoàn thành.',
      createdAt: now,
      updatedAt: now,
      analysisResult: analysisResult,
      originalImageUrl: originalImageUrl,
      annotatedImageUrl: annotatedImageUrl ?? analysisResult.annotatedImageUrl,
      comparisonImageUrl: comparisonImageUrl ?? analysisResult.comparisonImageUrl,
      metadata: metadata,
      thumbnailUrl: annotatedImageUrl ?? analysisResult.annotatedImageUrl,
      tags: ['palm', 'analysis', '${totalLines}_lines'],
    );
  }

  @override
  PalmAnalysisHistoryModel copyWith({
    String? id,
    String? title,
    String? description,
    HistoryItemType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    PalmAnalysisResponseModel? analysisResult,
    String? originalImageUrl,
    String? annotatedImageUrl,
    String? comparisonImageUrl,
    Map<String, dynamic>? metadata,
    String? thumbnailUrl,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return PalmAnalysisHistoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      analysisResult: analysisResult ?? this.analysisResult,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      annotatedImageUrl: annotatedImageUrl ?? this.annotatedImageUrl,
      comparisonImageUrl: comparisonImageUrl ?? this.comparisonImageUrl,
      metadata: metadata ?? this.metadata,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        analysisResult,
        originalImageUrl,
        annotatedImageUrl,
        comparisonImageUrl,
      ];

  /// JSON serialization
  factory PalmAnalysisHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$PalmAnalysisHistoryModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PalmAnalysisHistoryModelToJson(this);
}
