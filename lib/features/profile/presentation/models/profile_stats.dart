/// Profile statistics model
class ProfileStats {
  final int totalAnalyses;
  final int faceAnalyses;
  final int palmAnalyses;
  final double accuracyScore;
  final DateTime? lastAnalysisDate;
  final DateTime? memberSince;

  const ProfileStats({
    required this.totalAnalyses,
    required this.faceAnalyses,
    required this.palmAnalyses,
    required this.accuracyScore,
    this.lastAnalysisDate,
    this.memberSince,
  });

  /// Create ProfileStats from JSON
  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalAnalyses: json['totalAnalyses'] as int? ?? 0,
      faceAnalyses: json['faceAnalyses'] as int? ?? 0,
      palmAnalyses: json['palmAnalyses'] as int? ?? 0,
      accuracyScore: (json['accuracyScore'] as num?)?.toDouble() ?? 0.0,
      lastAnalysisDate: json['lastAnalysisDate'] != null
          ? DateTime.parse(json['lastAnalysisDate'] as String)
          : null,
      memberSince: json['memberSince'] != null
          ? DateTime.parse(json['memberSince'] as String)
          : null,
    );
  }

  /// Convert ProfileStats to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalAnalyses': totalAnalyses,
      'faceAnalyses': faceAnalyses,
      'palmAnalyses': palmAnalyses,
      'accuracyScore': accuracyScore,
      'lastAnalysisDate': lastAnalysisDate?.toIso8601String(),
      'memberSince': memberSince?.toIso8601String(),
    };
  }

  /// Create a copy with updated values
  ProfileStats copyWith({
    int? totalAnalyses,
    int? faceAnalyses,
    int? palmAnalyses,
    double? accuracyScore,
    DateTime? lastAnalysisDate,
    DateTime? memberSince,
  }) {
    return ProfileStats(
      totalAnalyses: totalAnalyses ?? this.totalAnalyses,
      faceAnalyses: faceAnalyses ?? this.faceAnalyses,
      palmAnalyses: palmAnalyses ?? this.palmAnalyses,
      accuracyScore: accuracyScore ?? this.accuracyScore,
      lastAnalysisDate: lastAnalysisDate ?? this.lastAnalysisDate,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
