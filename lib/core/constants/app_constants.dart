/// Application-wide constants
class AppConstants {
  // Debug Configuration
  static const bool bypassAuthentication = true; // Set to true to bypass auth for testing UI/UX

  // App Information
  static const String appName = 'Ứng dụng Tướng học AI';
  static const String appVersion = '1.0.0';
  
  // Old Backend API Configuration (Face/Palm Analysis)
  // VPS Production: http://160.250.180.132:3000/ai
  // Local Development: http://192.168.100.55:3000/ai
  static const String oldBackendBaseUrl = 'http://160.250.180.132:3000/ai';

  // Chatbot API Configuration (Separate service)
  // Ngrok URL (temporary): https://crayfish-pretty-certainly.ngrok-free.app
  static const String chatbotBaseUrl = 'https://crayfish-pretty-certainly.ngrok-free.app';

  // New Backend API Configuration (Auth, User Management from OpenAPI docs)
  // VPS Production: http://160.250.180.132:3000
  // Local Development: http://192.168.100.55:3000
  static const String baseUrl = 'http://160.250.180.132:3000';
  static const String apiVersion = 'v1';

  // Authentication API Endpoints (New Backend - OpenAPI docs)
  static const String loginEndpoint = 'auth/user';
  static const String googleLoginEndpoint = 'auth/google';
  static const String getCurrentUserEndpoint = 'auth/me';

  // User Management API Endpoints (New Backend - OpenAPI docs)
  static const String signupEndpoint = 'users/signUp';
  static const String updateProfileEndpoint = 'users/me';

  // Face Analysis API Configuration (Old Backend)
  static const String faceAnalysisApiUrl = 'analyze-face-from-cloudinary/';

  // Palm Analysis API Configuration (Old Backend)
  static const String palmAnalysisApiUrl = 'analyze-palm-cloudinary/';

  static const Duration requestTimeout = Duration(seconds: 120); // Increased for Cloudinary processing
  static const Duration connectTimeout = Duration(seconds: 15);

  // Cloudinary Configuration
  static const String cloudinaryCloudName = 'dsfmzrwc1';
  static const String cloudinaryApiKey = '595277418892966';
  static const String cloudinaryApiSecret = 'qvNpRQG2NDF9nYeYhAg7bF_-lqo';
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
  static const String palmAnalysisHistoryRoute = '/palm-analysis-history';
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
