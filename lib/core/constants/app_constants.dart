/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'AI Physiognomy App';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.example.com'; // Replace with actual API URL
  static const String apiVersion = 'v1';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'theme_mode';
  
  // Route Names
  static const String splashRoute = '/';
  static const String introRoute = '/intro';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String surveyRoute = '/survey';
  static const String demographicsRoute = '/demographics';
  static const String homeRoute = '/home';
  static const String faceScanningRoute = '/face-scanning';
  static const String userGuideRoute = '/user-guide';
  static const String cameraRoute = '/camera';
  static const String resultRoute = '/result';
  static const String chatbotRoute = '/chatbot';
  static const String profileRoute = '/profile';
  
  // Error Messages
  static const String networkErrorMessage = 'Network connection error. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unknownErrorMessage = 'An unexpected error occurred. Please try again.';
  static const String timeoutErrorMessage = 'Request timeout. Please try again.';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 48.0;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}
