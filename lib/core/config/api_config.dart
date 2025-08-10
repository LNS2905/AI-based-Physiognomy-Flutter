/// API Configuration for the application
/// This file contains all API-related configuration that can be easily updated
class ApiConfig {
  // Base API Configuration - Updated with actual backend URL
  static const String baseUrl = 'https://ai-based-physiognomy-backend.onrender.com';
  static const String apiVersion = 'v1';
  
  // Face Analysis API Configuration
  // Updated with new ngrok URL
  static const String faceAnalysisApiUrl = 'https://inspired-bear-emerging.ngrok-free.app/analyze-face-from-cloudinary/';
  
  // Alternative URLs for different environments
  static const String faceAnalysisApiUrlLocal = 'http://localhost:8000/analyze-face/';
  static const String faceAnalysisApiUrlStaging = 'https://staging-api.example.com/analyze-face/';
  static const String faceAnalysisApiUrlProduction = 'https://api.example.com/analyze-face/';
  
  // Environment-based URL selection
  static String get currentFaceAnalysisUrl {
    // You can implement environment detection here
    // For now, return the main URL
    return faceAnalysisApiUrl;
  }
  
  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String facialAnalysisEndpoint = '/facial-analysis';
  static const String palmAnalysisEndpoint = '/palm-analysis';

  // Timeout configurations
  static const Duration requestTimeout = Duration(seconds: 90);
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // API Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Multipart headers for file uploads
  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
  };

  // API Response codes
  static const String successCode = 'OPERATION_SUCCESS';

  // Error messages
  static const String networkErrorMessage = 'Network error occurred';
  static const String timeoutErrorMessage = 'Request timeout';
  static const String unauthorizedErrorMessage = 'Unauthorized access';
  static const String serverErrorMessage = 'Server error occurred';
  static const String unknownErrorMessage = 'Unknown error occurred';

  // Token refresh threshold (refresh when token expires in less than this time)
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // Maximum retry attempts for failed requests
  static const int maxRetryAttempts = 3;

  // Retry delay
  static const Duration retryDelay = Duration(seconds: 2);
}

/// Instructions for updating the API URL:
/// 
/// 1. If using ngrok for local development:
///    - Start your backend server
///    - Run: ngrok http 8000 (or your port)
///    - Copy the https URL from ngrok
///    - Update faceAnalysisApiUrl above
/// 
/// 2. If using a production API:
///    - Update faceAnalysisApiUrlProduction
///    - Modify currentFaceAnalysisUrl to return the production URL
/// 
/// 3. For local development without ngrok:
///    - Update faceAnalysisApiUrlLocal with your local server URL
///    - Modify currentFaceAnalysisUrl to return the local URL
