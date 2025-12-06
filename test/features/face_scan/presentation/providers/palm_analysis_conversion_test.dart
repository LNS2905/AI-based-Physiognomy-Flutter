import 'package:flutter_test/flutter_test.dart';
import 'package:ai_physiognomy_app/features/palm_scan/data/models/palm_analysis_response_model.dart';

void main() {
  group('Palm Analysis Conversion Tests', () {
    test('Should extract Vietnamese summary_text from palm_interpretation', () {
      // Create a mock response with Vietnamese palm_interpretation
      final mockResponse = PalmAnalysisResponseModel(
        status: 'success',
        message: 'Analysis complete',
        userId: 'test_user',
        processedAt: DateTime.now().toIso8601String(),
        handsDetected: 1,
        processingTime: 1.5,
        analysisType: 'palm_analysis',
        annotatedImageUrl: 'https://example.com/image.jpg',
        analysis: PalmAnalysisDataModel(
          handsDetected: 1,
          handsData: [],
          measurements: {},
          palmLines: {},
          fingerAnalysis: {},
          palmDetection: PalmDetectionModel(
            handsDetected: 1,
            handsData: [
              HandDataModel(
                handId: 0,
                handSide: 'right',
                keypoints: {},
                additionalData: {
                  'palm_interpretation': {
                    'summary_text': 'Đây là phân tích vân tay bằng tiếng Việt từ API',
                    'detailed_analysis': {
                      'life_line': {
                        'pattern': 'Đường cong rõ ràng',
                        'meaning': 'Cho thấy sức sống mạnh mẽ và năng lượng dồi dào'
                      },
                      'head_line': {
                        'pattern': 'Đường thẳng',
                        'meaning': 'Thể hiện tư duy logic và trí tuệ phân tích'
                      },
                      'heart_line': {
                        'pattern': 'Đường cong nhẹ',
                        'meaning': 'Biểu hiện cảm xúc ổn định và khả năng yêu thương'
                      }
                    },
                    'life_aspects': {
                      'health': ['Sức khỏe tốt', 'Năng lượng dồi dào'],
                      'career': ['Triển vọng nghề nghiệp tốt'],
                      'relationships': ['Mối quan hệ ổn định'],
                      'personality': ['Tính cách cân bằng']
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );

      // Verify the structure is correct
      expect(mockResponse.analysis, isNotNull);
      expect(mockResponse.analysis!.palmDetection, isNotNull);
      expect(mockResponse.analysis!.palmDetection!.handsData, isNotEmpty);
      
      final firstHand = mockResponse.analysis!.palmDetection!.handsData![0];
      expect(firstHand, isA<HandDataModel>());
      expect(firstHand.additionalData, isNotNull);
      expect(firstHand.additionalData!['palm_interpretation'], isNotNull);
      
      final palmInterp = firstHand.additionalData!['palm_interpretation'] as Map<String, dynamic>;
      expect(palmInterp['summary_text'], equals('Đây là phân tích vân tay bằng tiếng Việt từ API'));
      expect(palmInterp['detailed_analysis'], isNotNull);
      expect(palmInterp['life_aspects'], isNotNull);
    });

    test('Should handle missing palm_interpretation gracefully', () {
      // Create a mock response without palm_interpretation
      final mockResponse = PalmAnalysisResponseModel(
        status: 'success',
        message: 'Analysis complete',
        userId: 'test_user',
        processedAt: DateTime.now().toIso8601String(),
        handsDetected: 1,
        processingTime: 1.5,
        analysisType: 'palm_analysis',
        annotatedImageUrl: 'https://example.com/image.jpg',
        analysis: PalmAnalysisDataModel(
          handsDetected: 1,
          handsData: [],
          measurements: {},
          palmLines: {},
          fingerAnalysis: {},
          palmDetection: PalmDetectionModel(
            handsDetected: 1,
            handsData: [
              HandDataModel(
                handId: 0,
                handSide: 'right',
                keypoints: {},
                additionalData: {}, // No palm_interpretation
              ),
            ],
          ),
        ),
      );

      // Verify the structure
      expect(mockResponse.analysis, isNotNull);
      expect(mockResponse.analysis!.palmDetection, isNotNull);
      expect(mockResponse.analysis!.palmDetection!.handsData, isNotEmpty);
      
      final firstHand = mockResponse.analysis!.palmDetection!.handsData![0];
      expect(firstHand.additionalData, isNotNull);
      expect(firstHand.additionalData!['palm_interpretation'], isNull);
    });
  });
}
