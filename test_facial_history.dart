import 'dart:convert';
import 'package:http/http.dart' as http;

/// Test script to verify facial analysis history API
/// Run: dart test_facial_history.dart
void main() async {
  const String baseUrl = 'http://72.60.115.238';
  
  // Step 1: Login to get access token
  print('Step 1: Login...');
  final loginResponse = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'email': 'test@gmail.com',
      'password': 'Test@123',
    }),
  );

  if (loginResponse.statusCode != 200) {
    print('Login failed: ${loginResponse.statusCode}');
    print('Response: ${loginResponse.body}');
    return;
  }

  final loginData = jsonDecode(loginResponse.body);
  final accessToken = loginData['data']['accessToken'];
  print('✓ Login successful, got access token');

  // Step 2: Get user info from /auth/me
  print('\nStep 2: Getting user info from /auth/me...');
  final meResponse = await http.get(
    Uri.parse('$baseUrl/auth/me'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    },
  );

  if (meResponse.statusCode != 200) {
    print('Get user info failed: ${meResponse.statusCode}');
    print('Response: ${meResponse.body}');
    return;
  }

  final userData = jsonDecode(meResponse.body);
  final userId = userData['data']['id'];
  print('✓ Got user info:');
  print('  - ID: $userId');
  print('  - Name: ${userData['data']['firstName']} ${userData['data']['lastName']}');
  print('  - Email: ${userData['data']['email']}');

  // Step 3: Get facial analysis history
  print('\nStep 3: Getting facial analysis history for user $userId...');
  final historyResponse = await http.get(
    Uri.parse('$baseUrl/facial-analysis/user/$userId'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    },
  );

  print('Response status: ${historyResponse.statusCode}');
  print('Response headers: ${historyResponse.headers}');
  
  if (historyResponse.statusCode == 200) {
    final historyData = jsonDecode(historyResponse.body);
    
    if (historyData['success'] == true) {
      final analyses = historyData['data'] as List;
      print('✓ Got ${analyses.length} facial analysis records');
      
      if (analyses.isNotEmpty) {
        print('\nSample analysis record:');
        final sample = analyses.first;
        print('  - ID: ${sample['id']}');
        print('  - Face Shape: ${sample['faceShape']}');
        print('  - Harmony Score: ${sample['harmonyScore']}');
        print('  - Created At: ${sample['createdAt']}');
      }
    } else {
      print('API returned unsuccessful response');
    }
  } else {
    print('Failed to get history: ${historyResponse.statusCode}');
    print('Response body: ${historyResponse.body}');
  }

  // Step 4: Test with wrong user ID to verify API behavior
  print('\nStep 4: Testing with non-existent user ID...');
  final wrongUserResponse = await http.get(
    Uri.parse('$baseUrl/facial-analysis/user/99999'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    },
  );

  print('Response for wrong user: ${wrongUserResponse.statusCode}');
  if (wrongUserResponse.statusCode == 200) {
    final data = jsonDecode(wrongUserResponse.body);
    final items = data['data'] as List;
    print('Got ${items.length} items (should be 0 for non-existent user)');
  }

  print('\n✅ Test completed!');
}