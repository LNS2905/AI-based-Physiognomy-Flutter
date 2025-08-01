/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'Ứng dụng Tướng học AI';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://inspired-bear-emerging.ngrok-free.app';
  static const String apiVersion = 'v1';

  // Face Analysis API Configuration
  static const String faceAnalysisApiUrl = 'analyze-face-from-cloudinary/';

  // Palm Analysis API Configuration
  static const String palmAnalysisApiUrl = 'analyze-palm-cloudinary/';

  static const Duration requestTimeout = Duration(seconds: 120); // Increased for Cloudinary processing
  static const Duration connectTimeout = Duration(seconds: 15);

  // Cloudinary Configuration
  static const String cloudinaryCloudName = 'dd0wymyqj';
  static const String cloudinaryApiKey = '389718786139835';
  static const String cloudinaryApiSecret = 'aS_7wWncQjOLpKRKnHEd0_dr07M';
  static const String cloudinaryUploadFolder = 'physiognomy_analysis';
  
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
  static const String palmScanningRoute = '/palm-scanning';
  static const String userGuideRoute = '/user-guide';
  static const String cameraRoute = '/camera';
  static const String palmCameraRoute = '/palm-camera';
  static const String resultRoute = '/result';
  static const String chatbotRoute = '/chatbot';
  static const String aiConversationRoute = '/ai-conversation';
  static const String historyRoute = '/history';
  static const String historyFaceAnalysisDetailRoute = '/history/face-analysis';
  static const String historyPalmAnalysisDetailRoute = '/history/palm-analysis';
  static const String historyChatDetailRoute = '/history/chat';
  static const String profileRoute = '/profile';
  
  // Error Messages
  static const String networkErrorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet của bạn.';
  static const String serverErrorMessage = 'Lỗi máy chủ. Vui lòng thử lại sau.';
  static const String unknownErrorMessage = 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.';
  static const String timeoutErrorMessage = 'Hết thời gian chờ. Vui lòng thử lại.';
  
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
