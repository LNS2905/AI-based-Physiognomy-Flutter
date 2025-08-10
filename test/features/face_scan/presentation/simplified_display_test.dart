import 'package:flutter_test/flutter_test.dart';
import 'package:ai_physiognomy_app/features/face_scan/data/models/cloudinary_analysis_response_model.dart';

void main() {
  group('Simplified Display Test', () {
    test('should extract only overallHarmonyScore and Face Golden Ratio', () {
      // Mock API response with full harmony scores data
      final apiResponse = {
        "status": "success",
        "analysis": {
          "analysisResult": {
            "face": {
              "shape": {
                "primary": "Heart",
                "probabilities": {"Heart": 93.15, "Oval": 2.5}
              },
              "proportionality": {
                "overallHarmonyScore": 62.94,
                "harmonyScores": {
                  "Face Golden Ratio": 83.57,
                  "Outer Face Balance": 60.56,
                  "Eye Width Balance": 84.29,
                  "Inter-Eye Gap": 52.55,
                  "Nose Width": 0,
                  "Eye Symmetry": 95.68,
                  "Eyebrow Symmetry": 86.15,
                  "Forehead Height": 79.69,
                  "Midface Height": 54.83,
                  "Lower Face Height": 75.59,
                  "Lower Face Balance": 19.39
                }
              }
            }
          },
          "result": "Test analysis result"
        },
        "annotated_image_url": "https://example.com/image.jpg",
        "message": "Test message",
        "user_id": "test_user",
        "processed_at": "2025-08-02T22:18:30.447811"
      };

      final response = CloudinaryAnalysisResponseModel.fromJson(apiResponse);

      // Verify we can extract the 2 key metrics
      final overallHarmonyScore = response.analysis?.analysisResult?.face?.proportionality?.overallHarmonyScore;
      final harmonyScores = response.analysis?.analysisResult?.face?.proportionality?.harmonyScores;
      final faceGoldenRatio = harmonyScores?['Face Golden Ratio'];

      // Test the 2 key metrics we want to display
      expect(overallHarmonyScore, equals(62.94));
      expect(faceGoldenRatio, equals(83.57));

      // Verify other harmony scores exist but won't be displayed
      expect(harmonyScores?['Eye Symmetry'], equals(95.68));
      expect(harmonyScores?['Nose Width'], equals(0));

      print('✅ Simplified display test passed!');
      print('✅ Overall Harmony Score: $overallHarmonyScore');
      print('✅ Face Golden Ratio: $faceGoldenRatio');
      print('✅ Other scores exist but will be filtered out in UI');
    });

    test('should handle missing Face Golden Ratio gracefully', () {
      final apiResponseWithoutGoldenRatio = {
        "status": "success",
        "analysis": {
          "analysisResult": {
            "face": {
              "proportionality": {
                "overallHarmonyScore": 75.5,
                "harmonyScores": {
                  "Eye Symmetry": 95.68,
                  "Nose Width": 0
                  // No Face Golden Ratio
                }
              }
            }
          }
        },
        "message": "Test message",
        "user_id": "test_user",
        "processed_at": "2025-08-02T22:18:30.447811"
      };

      final response = CloudinaryAnalysisResponseModel.fromJson(apiResponseWithoutGoldenRatio);

      final overallHarmonyScore = response.analysis?.analysisResult?.face?.proportionality?.overallHarmonyScore;
      final harmonyScores = response.analysis?.analysisResult?.face?.proportionality?.harmonyScores;
      final faceGoldenRatio = harmonyScores?['Face Golden Ratio'];

      expect(overallHarmonyScore, equals(75.5));
      expect(faceGoldenRatio, isNull); // Should handle missing gracefully

      print('✅ Missing Face Golden Ratio handled gracefully');
    });
  });
}
