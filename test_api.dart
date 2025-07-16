import 'dart:io';
import 'package:http/http.dart' as http;

/// Simple script to test API connectivity
/// Run this with: dart test_api.dart
void main() async {
  // Test URLs - update these with your actual URLs
  final testUrls = [
    'https://mako-fast-bobcat.ngrok-free.app/analyze-face-from-cloudinary/'
    // Add your other API URLs here
  ];

  print('🔍 Testing API connectivity...\n');

  for (final url in testUrls) {
    await testApiEndpoint(url);
    print(''); // Empty line for readability
  }
}

Future<void> testApiEndpoint(String url) async {
  print('Testing: $url');
  
  try {
    // Test with a simple GET request first
    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    
    print('✅ Status: ${response.statusCode}');
    print('📝 Response: ${response.body.length > 100 ? '${response.body.substring(0, 100)}...' : response.body}');
    
    if (response.statusCode == 200) {
      print('🎉 API is accessible!');
    } else if (response.statusCode == 404) {
      print('❌ Endpoint not found (404)');
    } else if (response.statusCode == 405) {
      print('⚠️  Method not allowed (405) - API might expect POST');
    } else {
      print('⚠️  Unexpected status code');
    }
    
  } catch (e) {
    if (e.toString().contains('SocketException')) {
      print('❌ Connection failed - Server not reachable');
    } else if (e.toString().contains('TimeoutException')) {
      print('⏰ Request timeout - Server too slow');
    } else {
      print('❌ Error: $e');
    }
  }
}
