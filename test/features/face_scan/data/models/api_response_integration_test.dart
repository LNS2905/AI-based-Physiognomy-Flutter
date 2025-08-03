import 'package:flutter_test/flutter_test.dart';
import 'package:ai_physiognomy_app/features/face_scan/data/models/cloudinary_analysis_response_model.dart';

void main() {
  group('API Response Integration Test', () {
    test('should correctly parse the actual API response structure', () {
      // This is the actual API response structure from the test call
      final apiResponse = {
        "status": "success",
        "analysis": {
          "metadata": {
            "reportTitle": "Facial Analysis Report v9.5.0",
            "sourceFilename": "cloudinary_image_test_user_123.jpg",
            "timestampUTC": "2025-08-02T15:18:19.785579Z"
          },
          "analysisResult": {
            "face": {
              "shape": {
                "primary": "Heart",
                "probabilities": {
                  "Heart": 93.15,
                  "Oval": 2.5,
                  "Round": 2.21,
                  "Square": 1.17,
                  "Oblong": 0.98
                }
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
                },
                "metrics": [
                  {
                    "label": "Inter-Eye Gap",
                    "pixels": 139.79,
                    "percentage": 26.33,
                    "orientation": "horizontal"
                  },
                  {
                    "label": "Forehead Height",
                    "pixels": 206.73,
                    "percentage": 28.79,
                    "orientation": "vertical"
                  }
                ]
              }
            }
          },
          "result": "Khuôn mặt bạn có dạng heart, mặt trái tim có trán rộng, cằm nhọn..."
        },
        "annotated_image_url": "https://api.cloudinary.com/v1_1/dsfmzrwc1/image/download?timestamp=1754147910&public_id=uploads%2Fface_analysis%2Fresults%2Fannotated_1754147899&format=jpg&expires_at=1754234310&signature=17d95edbf29ac34bdef5082350fb440372791037&api_key=595277418892966",
        "message": "Analysis completed successfully with Cloudinary storage.",
        "user_id": "test_user_123",
        "processed_at": "2025-08-02T22:18:30.447811"
      };

      // Test parsing
      final response = CloudinaryAnalysisResponseModel.fromJson(apiResponse);

      // Verify basic response fields
      expect(response.status, equals('success'));
      expect(response.message, equals('Analysis completed successfully with Cloudinary storage.'));
      expect(response.userId, equals('test_user_123'));
      expect(response.processedAt, equals('2025-08-02T22:18:30.447811'));
      expect(response.annotatedImageUrl, isNotNull);
      expect(response.annotatedImageUrl, contains('cloudinary.com'));

      // Verify analysis data
      expect(response.analysis, isNotNull);
      expect(response.analysis!.result, isNotNull);
      expect(response.analysis!.result, contains('Khuôn mặt bạn có dạng heart'));

      // Verify metadata
      expect(response.analysis!.metadata, isNotNull);
      expect(response.analysis!.metadata!.reportTitle, equals('Facial Analysis Report v9.5.0'));
      expect(response.analysis!.metadata!.sourceFilename, equals('cloudinary_image_test_user_123.jpg'));

      // Verify face shape data
      expect(response.analysis!.analysisResult, isNotNull);
      expect(response.analysis!.analysisResult!.face, isNotNull);
      expect(response.analysis!.analysisResult!.face!.shape, isNotNull);
      expect(response.analysis!.analysisResult!.face!.shape!.primary, equals('Heart'));
      
      // Verify probabilities
      final probabilities = response.analysis!.analysisResult!.face!.shape!.probabilities;
      expect(probabilities, isNotNull);
      expect(probabilities!['Heart'], equals(93.15));
      expect(probabilities['Oval'], equals(2.5));

      // Verify proportionality data
      final proportionality = response.analysis!.analysisResult!.face!.proportionality;
      expect(proportionality, isNotNull);
      expect(proportionality!.overallHarmonyScore, equals(62.94));
      
      // Verify harmony scores
      final harmonyScores = proportionality.harmonyScores;
      expect(harmonyScores, isNotNull);
      expect(harmonyScores!['Face Golden Ratio'], equals(83.57));
      expect(harmonyScores['Eye Symmetry'], equals(95.68));

      // Verify metrics
      final metrics = proportionality.metrics;
      expect(metrics, isNotNull);
      expect(metrics!.length, equals(2));
      expect(metrics[0].label, equals('Inter-Eye Gap'));
      expect(metrics[0].pixels, equals(139.79));
      expect(metrics[0].percentage, equals(26.33));
      expect(metrics[0].orientation, equals('horizontal'));

      print('✅ All API response parsing tests passed!');
      print('✅ Face shape: ${response.analysis!.analysisResult!.face!.shape!.primary}');
      print('✅ Harmony score: ${response.analysis!.analysisResult!.face!.proportionality!.overallHarmonyScore}');
      print('✅ Metrics count: ${response.analysis!.analysisResult!.face!.proportionality!.metrics!.length}');
    });
  });
}
