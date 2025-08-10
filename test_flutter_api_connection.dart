#!/usr/bin/env dart
/**
 * Test script to verify Flutter app can connect to the server API
 * Run with: dart test_flutter_api_connection.dart
 */

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Simulate Flutter app constants
class AppConstants {
  static const String baseUrl = 'https://inspired-bear-emerging.ngrok-free.app';
  static const String faceAnalysisApiUrl = 'analyze-face-from-cloudinary/';
  static const String palmAnalysisApiUrl = 'analyze-palm-cloudinary/';
}

// Simulate HttpService URI building logic
Uri buildUri(String endpoint) {
  final baseUrl = AppConstants.baseUrl;
  
  // Same logic as in HttpService._buildUri
  final path = endpoint.startsWith('http') ||
               endpoint.contains('analyze-face-from-cloudinary') ||
               endpoint.contains('analyze-palm-cloudinary')
      ? endpoint.replaceFirst(baseUrl, '') // Remove base URL if it's included
      : 'v1/$endpoint';

  return Uri.parse(baseUrl).replace(
    path: path.startsWith('/') ? path : '/$path',
  );
}

Future<void> testApiConnection() async {
  print('🧪 Testing Flutter App API Connection...\n');
  
  // Test Face Analysis API
  print('📱 Testing Face Analysis API...');
  final faceApiUri = buildUri(AppConstants.faceAnalysisApiUrl);
  print('   URL: $faceApiUri');
  
  try {
    final response = await http.post(
      faceApiUri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'signed_url': 'test_url',
        'user_id': 'test_user',
        'timestamp': DateTime.now().toIso8601String(),
        'original_folder_path': 'test_folder',
      }),
    ).timeout(const Duration(seconds: 10));
    
    print('   ✅ Status: ${response.statusCode}');
    if (response.statusCode == 422) {
      print('   ✅ API is accessible (422 = validation error, expected for test data)');
    } else if (response.statusCode == 200) {
      print('   ✅ API is working perfectly!');
    } else {
      print('   ⚠️  Unexpected status: ${response.statusCode}');
    }
    
    // Try to parse response
    try {
      final responseData = jsonDecode(response.body);
      print('   📄 Response type: ${responseData.runtimeType}');
      if (responseData is Map && responseData.containsKey('detail')) {
        print('   📝 Detail: ${responseData['detail']}');
      }
    } catch (e) {
      print('   📄 Response body: ${response.body.substring(0, 100)}...');
    }
    
  } catch (e) {
    print('   ❌ Connection failed: $e');
    return;
  }
  
  print('');
  
  // Test Palm Analysis API
  print('🖐 Testing Palm Analysis API...');
  final palmApiUri = buildUri(AppConstants.palmAnalysisApiUrl);
  print('   URL: $palmApiUri');
  
  try {
    final response = await http.post(
      palmApiUri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'signed_url': 'test_url',
        'user_id': 'test_user',
        'timestamp': DateTime.now().toIso8601String(),
        'original_folder_path': 'test_folder',
      }),
    ).timeout(const Duration(seconds: 10));
    
    print('   ✅ Status: ${response.statusCode}');
    if (response.statusCode == 422) {
      print('   ✅ API is accessible (422 = validation error, expected for test data)');
    } else if (response.statusCode == 200) {
      print('   ✅ API is working perfectly!');
    } else {
      print('   ⚠️  Unexpected status: ${response.statusCode}');
    }
    
  } catch (e) {
    print('   ❌ Connection failed: $e');
    return;
  }
  
  print('\n🎉 API Connection Test Complete!');
  print('✅ Flutter app should be able to connect to the server APIs');
  print('📱 Base URL: ${AppConstants.baseUrl}');
  print('🎭 Face API: ${AppConstants.faceAnalysisApiUrl}');
  print('🖐 Palm API: ${AppConstants.palmAnalysisApiUrl}');
}

void main() async {
  await testApiConnection();
}
