import '../../../../core/utils/logger.dart';
import '../models/palm_analysis_response_model.dart';
import '../models/palm_analysis_server_model.dart';

/// Service to create real interpretations and life aspects from palm analysis API data
/// This service processes the technical data from palm analysis API and creates
/// meaningful interpretations and life aspects based on the detected palm lines
class PalmAnalysisInterpretationService {

  /// Create interpretations from real palm analysis API response
  static List<InterpretationServerModel> createInterpretationsFromAnalysis(
    PalmAnalysisResponseModel analysisResult
  ) {
    final interpretations = <InterpretationServerModel>[];

    AppLogger.info('Creating interpretations from REAL palm analysis API data');

    // Extract real interpretation data from API response
    final analysisData = analysisResult.analysis;
    if (analysisData == null) {
      AppLogger.warning('No analysis data found in palm analysis response');
      return interpretations;
    }

    // Try to get interpretation data from palm_detection.palm_lines_data
    if (analysisData.palmDetection?.handsData != null &&
        analysisData.palmDetection!.handsData!.isNotEmpty) {

      for (var handData in analysisData.palmDetection!.handsData!) {
        final handJson = handData.toJson();

        // Extract palm_interpretation from the API response
        if (handJson.containsKey('palm_interpretation')) {
          final palmInterpretation = handJson['palm_interpretation'] as Map<String, dynamic>?;

          if (palmInterpretation != null && palmInterpretation.containsKey('detailed_analysis')) {
            final detailedAnalysis = palmInterpretation['detailed_analysis'] as Map<String, dynamic>;

            AppLogger.info('Found real interpretation data from API: ${detailedAnalysis.keys}');

            // Process each line type from real API data
            detailedAnalysis.forEach((lineType, lineData) {
              if (lineData is Map<String, dynamic>) {
                final pattern = lineData['pattern'] as String? ?? '';
                final meaning = lineData['meaning'] as String? ?? '';
                final lengthPx = (lineData['length_px'] as num?)?.toInt() ?? 0;
                final confidence = (lineData['confidence'] as num?)?.toDouble() ?? 0.0;

                interpretations.add(InterpretationServerModel(
                  id: 0, // Will be set by server
                  analysisId: 0, // Will be set by server
                  lineType: _normalizeLineType(lineType),
                  pattern: pattern,
                  meaning: meaning,
                  lengthPx: lengthPx,
                  confidence: confidence,
                  createdAt: DateTime.now().toIso8601String(),
                ));

                AppLogger.info('Added real interpretation for $lineType: $pattern');
              }
            });
          }
        }
      }
    }

    AppLogger.info('Created ${interpretations.length} interpretations from REAL API data');
    return interpretations;
  }
  /// Create life aspects from real palm analysis API response
  static List<LifeAspectServerModel> createLifeAspectsFromAnalysis(
    PalmAnalysisResponseModel analysisResult
  ) {
    final lifeAspects = <LifeAspectServerModel>[];

    AppLogger.info('Creating life aspects from REAL palm analysis API data');

    // Extract real life aspects data from API response
    final analysisData = analysisResult.analysis;
    if (analysisData == null) {
      AppLogger.warning('No analysis data found in palm analysis response');
      return lifeAspects;
    }

    // Try to get life aspects data from palm_detection.palm_lines_data
    if (analysisData.palmDetection?.handsData != null &&
        analysisData.palmDetection!.handsData!.isNotEmpty) {

      for (var handData in analysisData.palmDetection!.handsData!) {
        final handJson = handData.toJson();

        // Extract palm_interpretation from the API response
        if (handJson.containsKey('palm_interpretation')) {
          final palmInterpretation = handJson['palm_interpretation'] as Map<String, dynamic>?;

          if (palmInterpretation != null && palmInterpretation.containsKey('life_aspects')) {
            final lifeAspectsData = palmInterpretation['life_aspects'] as Map<String, dynamic>;

            AppLogger.info('Found real life aspects data from API: ${lifeAspectsData.keys}');

            // Process each aspect from real API data
            lifeAspectsData.forEach((aspectType, aspectContent) {
              if (aspectContent is List) {
                // Join multiple content items into one string
                final content = (aspectContent as List<dynamic>)
                    .map((item) => item.toString())
                    .join(' ');

                lifeAspects.add(LifeAspectServerModel(
                  id: 0, // Will be set by server
                  analysisId: 0, // Will be set by server
                  aspect: aspectType,
                  content: content,
                ));

                AppLogger.info('Added real life aspect for $aspectType: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');
              }
            });
          }
        }
      }
    }

    AppLogger.info('Created ${lifeAspects.length} life aspects from REAL API data');
    return lifeAspects;
  }

  /// Create summary text from real palm analysis API response
  static String createSummaryFromAnalysis(PalmAnalysisResponseModel analysisResult) {
    AppLogger.info('Creating summary from REAL palm analysis API data');

    // Extract real summary text from API response
    final analysisData = analysisResult.analysis;
    if (analysisData == null) {
      AppLogger.warning('No analysis data found in palm analysis response');
      return 'Phân tích vân tay hoàn thành nhưng không có dữ liệu chi tiết.';
    }

    // Try to get summary text from palm_detection.palm_lines_data
    if (analysisData.palmDetection?.handsData != null &&
        analysisData.palmDetection!.handsData!.isNotEmpty) {

      for (var handData in analysisData.palmDetection!.handsData!) {
        final handJson = handData.toJson();

        // Extract palm_interpretation from the API response
        if (handJson.containsKey('palm_interpretation')) {
          final palmInterpretation = handJson['palm_interpretation'] as Map<String, dynamic>?;

          if (palmInterpretation != null && palmInterpretation.containsKey('summary_text')) {
            final summaryText = palmInterpretation['summary_text'] as String?;

            if (summaryText != null && summaryText.isNotEmpty) {
              AppLogger.info('Found real summary text from API: ${summaryText.substring(0, summaryText.length > 100 ? 100 : summaryText.length)}...');
              return summaryText;
            }
          }
        }
      }
    }

    // Fallback if no real summary found
    AppLogger.warning('No real summary text found in API response, using fallback');
    return 'Phân tích vân tay hoàn thành thành công với ${analysisResult.handsDetected} bàn tay được phát hiện.';
  }

  // Private helper methods
  static String _normalizeLineType(String lineType) {
    // Normalize line type names from API to match backend expectations
    switch (lineType.toLowerCase()) {
      case 'life_line':
        return 'life';
      case 'heart_line':
        return 'heart';
      case 'head_line':
        return 'head';
      case 'fate_line':
        return 'fate';
      default:
        return lineType.toLowerCase();
    }
  }
}
