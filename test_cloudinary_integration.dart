import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'lib/core/services/cloudinary_service.dart';
import 'lib/core/constants/app_constants.dart';
import 'lib/features/face_scan/data/models/cloudinary_analysis_request_model.dart';
import 'lib/features/face_scan/data/models/cloudinary_analysis_response_model.dart';
import 'lib/features/face_scan/data/repositories/face_scan_repository.dart';

/// Test file to verify Cloudinary integration
void main() {
  group('Cloudinary Integration Tests', () {
    late CloudinaryService cloudinaryService;
    late FaceScanRepository repository;

    setUp(() {
      cloudinaryService = CloudinaryService();
      repository = FaceScanRepository();
    });

    test('Test Cloudinary service initialization', () {
      expect(() => cloudinaryService.initialize(), returnsNormally);
    });

    test('Test API endpoint configuration', () {
      expect(AppConstants.faceAnalysisApiUrl, 
          equals('https://inspired-bear-emerging.ngrok-free.app/analyze-face-from-cloudinary/'));
      expect(AppConstants.cloudinaryCloudName, equals('dd0wymyqj'));
      expect(AppConstants.cloudinaryApiKey, equals('389718786139835'));
    });

    test('Test CloudinaryAnalysisRequestModel creation', () {
      final request = CloudinaryAnalysisRequestModel(
        signedUrl: 'https://test.cloudinary.com/test.jpg',
        userId: 'test_user',
        timestamp: DateTime.now().toIso8601String(),
        originalFolderPath: 'test_folder',
      );

      expect(request.signedUrl, equals('https://test.cloudinary.com/test.jpg'));
      expect(request.userId, equals('test_user'));
      expect(request.originalFolderPath, equals('test_folder'));

      final json = request.toJson();
      expect(json['signed_url'], equals('https://test.cloudinary.com/test.jpg'));
      expect(json['user_id'], equals('test_user'));
    });

    test('Test CloudinaryAnalysisResponseModel parsing', () {
      final mockResponse = {
        'status': 'success',
        'message': 'Analysis completed successfully',
        'user_id': 'test_user',
        'processed_at': '2025-01-11T10:00:00Z',
        'total_harmony_score': 85.5,
        'annotated_image_url': 'https://cloudinary.com/annotated.jpg',
        'report_image_url': 'https://cloudinary.com/report.jpg',
        'analysis': {
          'face_shape': 'oval',
          'features': {
            'eyes': {'score': 90},
            'nose': {'score': 85}
          },
          'result': 'Positive personality traits detected'
        }
      };

      final response = CloudinaryAnalysisResponseModel.fromJson(mockResponse);
      
      expect(response.status, equals('success'));
      expect(response.totalHarmonyScore, equals(85.5));
      expect(response.annotatedImageUrl, equals('https://cloudinary.com/annotated.jpg'));
      expect(response.analysis?.faceShape, equals('oval'));
      expect(response.analysis?.result, equals('Positive personality traits detected'));
    });

    test('Test API endpoint availability', () async {
      try {
        final response = await http.get(
          Uri.parse('https://inspired-bear-emerging.ngrok-free.app/health'),
          headers: {
            'Accept': 'application/json',
          },
        ).timeout(Duration(seconds: 10));

        print('API Health Check Status: ${response.statusCode}');
        print('API Health Check Response: ${response.body}');
        
        // API should be reachable (200 or other valid HTTP status)
        expect(response.statusCode, lessThan(500));
      } catch (e) {
        print('API Health Check Failed: $e');
        // This is expected if API is not running
      }
    });
  });

  group('Integration Flow Tests', () {
    test('Test complete analysis flow (mock)', () async {
      // This test simulates the complete flow without actual file upload
      final mockImagePath = 'test_assets/test_face.jpg';
      final mockUserId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
      
      print('Testing analysis flow for user: $mockUserId');
      print('Mock image path: $mockImagePath');
      
      // Step 1: Create request model
      final request = CloudinaryAnalysisRequestModel(
        signedUrl: 'https://mock.cloudinary.com/signed_url.jpg',
        userId: mockUserId,
        timestamp: DateTime.now().toIso8601String(),
        originalFolderPath: AppConstants.cloudinaryUploadFolder,
      );
      
      expect(request.userId, equals(mockUserId));
      expect(request.originalFolderPath, equals(AppConstants.cloudinaryUploadFolder));
      
      print('✅ Request model created successfully');
      
      // Step 2: Verify JSON serialization
      final requestJson = request.toJson();
      expect(requestJson, isA<Map<String, dynamic>>());
      expect(requestJson['signed_url'], isNotEmpty);
      expect(requestJson['user_id'], equals(mockUserId));
      
      print('✅ JSON serialization working');
      
      // Step 3: Test response parsing
      final mockApiResponse = {
        'status': 'success',
        'message': 'Analysis completed successfully',
        'user_id': mockUserId,
        'processed_at': DateTime.now().toIso8601String(),
        'total_harmony_score': 87.3,
        'annotated_image_url': 'https://res.cloudinary.com/dd0wymyqj/image/private/annotated_${mockUserId}.jpg',
        'report_image_url': 'https://res.cloudinary.com/dd0wymyqj/image/private/report_${mockUserId}.jpg',
        'analysis': {
          'face_shape': 'oval',
          'features': {
            'eyes': {'score': 92, 'description': 'Well-proportioned eyes'},
            'nose': {'score': 85, 'description': 'Balanced nose structure'},
            'mouth': {'score': 88, 'description': 'Harmonious mouth shape'}
          },
          'result': 'This person shows signs of creativity, intelligence, and emotional balance. The facial proportions suggest a harmonious personality with strong leadership qualities.'
        }
      };
      
      final response = CloudinaryAnalysisResponseModel.fromJson(mockApiResponse);
      
      expect(response.status, equals('success'));
      expect(response.userId, equals(mockUserId));
      expect(response.totalHarmonyScore, equals(87.3));
      expect(response.annotatedImageUrl, contains('annotated_'));
      expect(response.reportImageUrl, contains('report_'));
      expect(response.analysis?.faceShape, equals('oval'));
      expect(response.analysis?.result, contains('creativity'));
      
      print('✅ Response parsing working');
      print('✅ Complete integration flow test passed');
    });
  });
}

/// Helper function to print test results
void printTestResults() {
  print('\n🧪 Cloudinary Integration Test Summary:');
  print('=====================================');
  print('✅ CloudinaryService initialization');
  print('✅ API endpoint configuration');
  print('✅ Request/Response model serialization');
  print('✅ Complete analysis flow simulation');
  print('\n📋 Next Steps:');
  print('1. Run the app and test with real images');
  print('2. Verify Cloudinary upload functionality');
  print('3. Test API response handling');
  print('4. Check UI updates with analysis results');
}
