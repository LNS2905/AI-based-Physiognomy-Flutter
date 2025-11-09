import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/welcome/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/auth/presentation/pages/google_signin_test_page.dart';
import '../../features/auth/data/models/auth_models.dart';
import '../../features/survey/presentation/pages/survey_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/face_scan/presentation/pages/face_scan_page.dart';
import '../../features/face_scan/presentation/pages/camera_screen.dart';
import '../../features/palm_scan/presentation/pages/palm_scan_page.dart';
import '../../features/palm_scan/presentation/pages/palm_camera_screen.dart';
import '../../features/palm_scan/presentation/pages/palm_analysis_history_list_page.dart';
import '../../features/face_scan/presentation/pages/facial_analysis_history_list_page.dart';
import '../../features/news/presentation/pages/news_detail_page.dart';
import '../../features/news/presentation/pages/news_list_page.dart';
import '../../features/face_scan/presentation/pages/user_guide_page.dart';
import '../../features/ai_conversation/presentation/pages/ai_conversation_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/history/presentation/pages/face_analysis_history_detail_page.dart';
import '../../features/history/presentation/pages/palm_analysis_history_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/history/presentation/pages/chat_history_detail_page.dart';
import '../../features/testing/presentation/pages/new_api_test_page.dart';
import '../../features/testing/presentation/pages/tu_vi_test_page.dart';
import '../../features/tu_vi/presentation/pages/tu_vi_input_page.dart';
import '../../features/tu_vi/presentation/pages/tu_vi_result_page.dart';
import '../../features/payment/presentation/pages/payment_packages_page.dart';
import '../widgets/auth_guard.dart';

/// Application router configuration using GoRouter
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppConstants.splashRoute,
    debugLogDiagnostics: true,
    observers: [NavigationObserver()],
    routes: [
      // Splash Route
      GoRoute(
        path: AppConstants.splashRoute,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Welcome Route
      GoRoute(
        path: AppConstants.introRoute,
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),

      // Login Route
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Sign Up Route
      GoRoute(
        path: AppConstants.signupRoute,
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),

      // Google Sign-In Test Route
      GoRoute(
        path: '/google-signin-test',
        name: 'google-signin-test',
        builder: (context, state) => const GoogleSignInTestPage(),
      ),

      // Forgot Password Route
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Reset Password Route
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordPage(token: token);
        },
      ),

      // Change Password Route (requires authentication)
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordPage().withAuthGuard(
          redirectRoute: AppConstants.introRoute,
        ),
      ),

      // New API Test Route
      GoRoute(
        path: '/new-api-test',
        name: 'new-api-test',
        builder: (context, state) => const NewApiTestPage(),
      ),

      // Tu Vi Test Route
      GoRoute(
        path: '/tu-vi-test',
        name: 'tu-vi-test',
        builder: (context, state) => const TuViTestPage(),
      ),

      // Tu Vi Input Route (Production)
      GoRoute(
        path: '/tu-vi-input',
        name: 'tu-vi-input',
        builder: (context, state) => const TuViInputPage(),
      ),

      // Tu Vi Result Route
      GoRoute(
        path: '/tu-vi-result/:chartId',
        name: 'tu-vi-result',
        builder: (context, state) {
          final chartId = state.pathParameters['chartId'] ?? '1';
          return TuViResultPage(chartId: chartId);
        },
      ),

      // Survey Route
      GoRoute(
        path: AppConstants.surveyRoute,
        name: 'survey',
        builder: (context, state) => const SurveyPage(),
      ),

      // Demographics Route
      GoRoute(
        path: AppConstants.demographicsRoute,
        name: 'demographics',
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Thông tin cá nhân'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: const Center(
            child: Text('Màn hình thông tin cá nhân - Sẽ được triển khai'),
          ),
        ),
      ),

      // Home Route
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        builder: (context, state) => const HomePage().withAuthGuard(
          redirectRoute: AppConstants.introRoute,
        ),
      ),

      // Face Scanning Route
      GoRoute(
        path: AppConstants.faceScanningRoute,
        name: 'face-scanning',
        builder: (context, state) => const FaceScanPage().withAuthGuard(
          redirectRoute: AppConstants.introRoute,
        ),
      ),

      // Palm Scanning Route
      GoRoute(
        path: AppConstants.palmScanningRoute,
        name: 'palm-scanning',
        builder: (context, state) => const PalmScanPage().withAuthGuard(
          redirectRoute: AppConstants.introRoute,
        ),
      ),

      // User Guide Route
      GoRoute(
        path: AppConstants.userGuideRoute,
        name: 'user-guide',
        builder: (context, state) => const UserGuidePage(),
      ),

      // Camera Route
      GoRoute(
        path: AppConstants.cameraRoute,
        name: 'camera',
        builder: (context, state) => const CameraScreen().withAuthGuard(
          redirectRoute: AppConstants.introRoute,
        ),
      ),

      // Palm Camera Route
      GoRoute(
        path: AppConstants.palmCameraRoute,
        name: 'palm-camera',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final gender = extra?['gender'] as Gender?;
          return PalmCameraScreen(gender: gender).withAuthGuard(
            redirectRoute: AppConstants.introRoute,
          );
        },
      ),

      // Palm Analysis History List Route
      GoRoute(
        path: '/palm-analysis-history',
        name: 'palm-analysis-history',
        builder: (context, state) => const PalmAnalysisHistoryListPage().withAuthGuard(
          redirectRoute: AppConstants.introRoute,
        ),
      ),

      // Facial Analysis History List Route
      GoRoute(
        path: '/facial-analysis-history',
        name: 'facial-analysis-history',
        builder: (context, state) => const FacialAnalysisHistoryListPage().withAuthGuard(
          redirectRoute: AppConstants.introRoute,
        ),
      ),

      // Result Route
      GoRoute(
        path: AppConstants.resultRoute,
        name: 'result',
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Kết quả'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: const Center(
            child: Text('Màn hình kết quả - Sẽ được triển khai'),
          ),
        ),
      ),

      // Chatbot Route (Legacy - redirects to AI Conversation)
      GoRoute(
        path: AppConstants.chatbotRoute,
        name: 'chatbot',
        redirect: (context, state) => AppConstants.aiConversationRoute,
      ),

      // AI Conversation Route (No auth required for Tu Vi flow testing)
      GoRoute(
        path: AppConstants.aiConversationRoute,
        name: 'ai-conversation',
        builder: (context, state) {
          final conversationIdStr = state.uri.queryParameters['id'];
          final conversationId = conversationIdStr != null 
              ? int.tryParse(conversationIdStr) 
              : null;
          return AIConversationPage(conversationId: conversationId);
        },
      ),

      // News List Route
      GoRoute(
        path: '/news',
        name: 'news-list',
        builder: (context, state) => const NewsListPage(),
      ),

      // News Detail Route
      GoRoute(
        path: '/news/:articleId',
        name: 'news-detail',
        builder: (context, state) {
          final articleId = state.pathParameters['articleId'] ?? '1';
          return NewsDetailPage(articleId: articleId);
        },
      ),

      // Profile Route
      GoRoute(
        path: AppConstants.profileRoute,
        name: 'profile',
        builder: (context, state) => const ProfilePage().withAuthGuard(
          redirectRoute: AppConstants.introRoute,
        ),
      ),

      // Payment Packages Route (Protected)
      GoRoute(
        path: '/payment/packages',
        name: 'payment-packages',
        builder: (context, state) => const AuthGuard(child: PaymentPackagesPage()),
      ),

      // History Route (Protected)
      GoRoute(
        path: AppConstants.historyRoute,
        name: 'history',
        builder: (context, state) => const HistoryPage().withAuthGuard(
          redirectRoute: AppConstants.introRoute,
          loadingMessage: 'Đang tải lịch sử...',
        ),
      ),

      // History Detail Routes
      GoRoute(
        path: '${AppConstants.historyFaceAnalysisDetailRoute}/:historyId',
        name: 'history-face-analysis-detail',
        builder: (context, state) {
          final historyId = state.pathParameters['historyId'] ?? '';
          return FaceAnalysisHistoryDetailPage(historyId: historyId).withAuthGuard(
            redirectRoute: AppConstants.introRoute,
          );
        },
      ),

      GoRoute(
        path: '${AppConstants.historyPalmAnalysisDetailRoute}/:historyId',
        name: 'history-palm-analysis-detail',
        builder: (context, state) {
          final historyId = state.pathParameters['historyId'] ?? '';
          return PalmAnalysisHistoryDetailPage(historyId: historyId).withAuthGuard(
            redirectRoute: AppConstants.introRoute,
          );
        },
      ),

      GoRoute(
        path: '${AppConstants.historyChatDetailRoute}/:historyId',
        name: 'history-chat-detail',
        builder: (context, state) {
          final historyId = state.pathParameters['historyId'] ?? '';
          return ChatHistoryDetailPage(historyId: historyId).withAuthGuard(
            redirectRoute: AppConstants.introRoute,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy trang',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Không thể tìm thấy trang "${state.uri}".',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    ),
  );

  /// Get the router instance
  static GoRouter get router => _router;

  /// Navigation helper methods
  static void goToWelcome() => _router.go(AppConstants.introRoute);
  static void goToLogin() => _router.go(AppConstants.loginRoute);
  static void goToSignup() => _router.go(AppConstants.signupRoute);
  static void goToSurvey() => _router.go(AppConstants.surveyRoute);
  static void goToDemographics() => _router.go(AppConstants.demographicsRoute);
  static void goToHome() => _router.go(AppConstants.homeRoute);
  static void goToFaceScanning() => _router.go(AppConstants.faceScanningRoute);
  static void goToPalmScanning() => _router.go(AppConstants.palmScanningRoute);
  static void goToUserGuide() => _router.go(AppConstants.userGuideRoute);
  static void goToCamera() => _router.go(AppConstants.cameraRoute);
  static void goToPalmCamera() => _router.go(AppConstants.palmCameraRoute);
  static void goToResult() => _router.go(AppConstants.resultRoute);
  static void goToChatbot() => _router.go(AppConstants.chatbotRoute);
  static void goToAiConversation({String? conversationId}) {
    final uri = conversationId != null
        ? '${AppConstants.aiConversationRoute}?id=$conversationId'
        : AppConstants.aiConversationRoute;
    _router.go(uri);
  }
  static void goToProfile() => _router.go(AppConstants.profileRoute);
  static void goToHistory() => _router.go(AppConstants.historyRoute);
  static void goToPalmAnalysisHistory() => _router.go(AppConstants.palmAnalysisHistoryRoute);
  static void goToForgotPassword() => _router.go('/forgot-password');
  static void goToResetPassword(String token) => _router.go('/reset-password?token=$token');
  static void goToChangePassword() => _router.go('/change-password');
  static void goToTuViInput() => _router.go('/tu-vi-input');
  static void goToTuViResult(int chartId) => _router.go('/tu-vi-result/$chartId');

  /// Push navigation methods
  static void pushWelcome() => _router.push(AppConstants.introRoute);
  static void pushLogin() => _router.push(AppConstants.loginRoute);
  static void pushSignup() => _router.push(AppConstants.signupRoute);
  static void pushSurvey() => _router.push(AppConstants.surveyRoute);
  static void pushDemographics() => _router.push(AppConstants.demographicsRoute);
  static void pushHome() => _router.push(AppConstants.homeRoute);
  static void pushFaceScanning() => _router.push(AppConstants.faceScanningRoute);
  static void pushPalmScanning() => _router.push(AppConstants.palmScanningRoute);
  static void pushUserGuide() => _router.push(AppConstants.userGuideRoute);
  static void pushCamera() => _router.push(AppConstants.cameraRoute);
  static void pushPalmCamera() => _router.push(AppConstants.palmCameraRoute);
  static void pushResult() => _router.push(AppConstants.resultRoute);
  static void pushChatbot() => _router.push(AppConstants.chatbotRoute);
  static void pushAiConversation({String? conversationId}) {
    final uri = conversationId != null
        ? '${AppConstants.aiConversationRoute}?id=$conversationId'
        : AppConstants.aiConversationRoute;
    _router.push(uri);
  }
  static void pushProfile() => _router.push(AppConstants.profileRoute);
  static void pushHistory() => _router.push(AppConstants.historyRoute);
  static void pushPalmAnalysisHistory() => _router.push(AppConstants.palmAnalysisHistoryRoute);
  static void pushForgotPassword() => _router.push('/forgot-password');
  static void pushResetPassword(String token) => _router.push('/reset-password?token=$token');
  static void pushChangePassword() => _router.push('/change-password');
  static void pushTuViInput() => _router.push('/tu-vi-input');
  static void pushTuViResult(int chartId) => _router.push('/tu-vi-result/$chartId');

  /// Go back
  static void goBack() {
    if (_router.canPop()) {
      _router.pop();
    }
  }

  /// Check if can go back
  static bool canGoBack() => _router.canPop();
}

/// Navigation observer for logging
class NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    AppLogger.logNavigation(
      previousRoute?.settings.name ?? 'unknown',
      route.settings.name ?? 'unknown',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    AppLogger.logNavigation(
      route.settings.name ?? 'unknown',
      previousRoute?.settings.name ?? 'unknown',
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    AppLogger.logNavigation(
      oldRoute?.settings.name ?? 'unknown',
      newRoute?.settings.name ?? 'unknown',
    );
  }
}
