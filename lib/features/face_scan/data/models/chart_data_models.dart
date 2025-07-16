import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Model for face shape probability data used in charts
class FaceShapeProbabilityData extends Equatable {
  final String shapeName;
  final double probability;
  final Color color;

  const FaceShapeProbabilityData({
    required this.shapeName,
    required this.probability,
    required this.color,
  });

  @override
  List<Object?> get props => [shapeName, probability, color];
}

/// Model for harmony score data used in charts
class HarmonyScoreData extends Equatable {
  final String scoreName;
  final double score;
  final Color color;
  final String description;

  const HarmonyScoreData({
    required this.scoreName,
    required this.score,
    required this.color,
    required this.description,
  });

  @override
  List<Object?> get props => [scoreName, score, color, description];
}

/// Model for proportionality metric data used in radar charts
class ProportionalityMetricData extends Equatable {
  final String label;
  final double percentage;
  final double pixels;
  final String orientation;

  const ProportionalityMetricData({
    required this.label,
    required this.percentage,
    required this.pixels,
    required this.orientation,
  });

  @override
  List<Object?> get props => [label, percentage, pixels, orientation];
}

/// Chart data processor for converting API response to chart-ready data
class ChartDataProcessor {
  /// Convert face shape probabilities to chart data
  static List<FaceShapeProbabilityData> processFaceShapeProbabilities(
    Map<String, double>? probabilities,
  ) {
    if (probabilities == null) return [];

    final colors = [
      const Color(0xFFE91E63), // Pink for Heart
      const Color(0xFF4CAF50), // Green for Oval
      const Color(0xFFFF9800), // Orange for Round
      const Color(0xFF2196F3), // Blue for Oblong
      const Color(0xFF9C27B0), // Purple for Square
    ];

    final sortedEntries = probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final shapeEntry = entry.value;
      
      return FaceShapeProbabilityData(
        shapeName: shapeEntry.key,
        probability: shapeEntry.value,
        color: colors[index % colors.length],
      );
    }).toList();
  }

  /// Convert harmony scores to chart data
  static List<HarmonyScoreData> processHarmonyScores(
    Map<String, double>? harmonyScores,
  ) {
    if (harmonyScores == null) return [];

    return harmonyScores.entries.map((entry) {
      final score = entry.value;
      Color color;
      String description;

      if (score >= 80) {
        color = const Color(0xFF4CAF50); // Green
        description = 'Xuất sắc';
      } else if (score >= 60) {
        color = const Color(0xFF8BC34A); // Light Green
        description = 'Tốt';
      } else if (score >= 40) {
        color = const Color(0xFFFF9800); // Orange
        description = 'Trung bình';
      } else if (score >= 20) {
        color = const Color(0xFFFF5722); // Deep Orange
        description = 'Dưới trung bình';
      } else {
        color = const Color(0xFFF44336); // Red
        description = 'Kém';
      }

      return HarmonyScoreData(
        scoreName: entry.key,
        score: score,
        color: color,
        description: description,
      );
    }).toList();
  }

  /// Convert proportionality metrics to chart data
  static List<ProportionalityMetricData> processProportionalityMetrics(
    List<dynamic>? metrics,
  ) {
    if (metrics == null) return [];

    return metrics.map((metric) {
      final metricMap = metric as Map<String, dynamic>;
      return ProportionalityMetricData(
        label: metricMap['label'] as String? ?? '',
        percentage: (metricMap['percentage'] as num?)?.toDouble() ?? 0.0,
        pixels: (metricMap['pixels'] as num?)?.toDouble() ?? 0.0,
        orientation: metricMap['orientation'] as String? ?? '',
      );
    }).toList();
  }

  /// Get color for score value
  static Color getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF4CAF50); // Green
    if (score >= 60) return const Color(0xFF8BC34A); // Light Green
    if (score >= 40) return const Color(0xFFFF9800); // Orange
    if (score >= 20) return const Color(0xFFFF5722); // Deep Orange
    return const Color(0xFFF44336); // Red
  }

  /// Get description for score value
  static String getScoreDescription(double score) {
    if (score >= 80) return 'Xuất sắc';
    if (score >= 60) return 'Tốt';
    if (score >= 40) return 'Trung bình';
    if (score >= 20) return 'Dưới trung bình';
    return 'Kém';
  }
}
