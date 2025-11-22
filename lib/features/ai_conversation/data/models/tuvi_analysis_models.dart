import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tuvi_analysis_models.g.dart';

/// Chart JSON Input for /tuvi/analyze-json endpoint
@JsonSerializable(explicitToJson: true)
class ChartJsonInput extends Equatable {
  @JsonKey(name: 'chart_data')
  final Map<String, dynamic> chartData;

  final String question;

  const ChartJsonInput({
    required this.chartData,
    required this.question,
  });

  /// JSON serialization
  factory ChartJsonInput.fromJson(Map<String, dynamic> json) =>
      _$ChartJsonInputFromJson(json);

  Map<String, dynamic> toJson() => _$ChartJsonInputToJson(this);

  @override
  List<Object?> get props => [chartData, question];
}

/// Analysis Result from /tuvi/analyze-json endpoint
@JsonSerializable()
class AnalysisResult extends Equatable {
  final String? filename;
  final String? name;
  final String analysis;
  @JsonKey(name: 'extracted_text')
  final String? extractedText;
  final String timestamp;
  final String status;
  final String? method;
  @JsonKey(name: 'processing_time')
  final String? processingTime;

  const AnalysisResult({
    this.filename,
    this.name,
    required this.analysis,
    this.extractedText,
    required this.timestamp,
    required this.status,
    this.method,
    this.processingTime,
  });

  /// JSON serialization
  factory AnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisResultToJson(this);

  @override
  List<Object?> get props => [
        filename,
        name,
        analysis,
        extractedText,
        timestamp,
        status,
        method,
        processingTime,
      ];
}
