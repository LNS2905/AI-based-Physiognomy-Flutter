import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/welcome/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/survey/presentation/pages/survey_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/face_scan/presentation/pages/face_scan_page.dart';
import '../../features/face_scan/presentation/pages/camera_screen.dart';
import '../../features/face_scan/presentation/pages/user_guide_page.dart';

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
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Demographics Screen - To be implemented'),
          ),
        ),
      ),

      // Home Route
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Face Scanning Route
      GoRoute(
        path: AppConstants.faceScanningRoute,
        name: 'face-scanning',
        builder: (context, state) => const FaceScanPage(),
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
        builder: (context, state) => const CameraScreen(),
      ),

      // Result Route
      GoRoute(
        path: AppConstants.resultRoute,
        name: 'result',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Result Screen - To be implemented'),
          ),
        ),
      ),

      // Chatbot Route
      GoRoute(
        path: AppConstants.chatbotRoute,
        name: 'chatbot',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Chatbot Screen - To be implemented'),
          ),
        ),
      ),

      // Profile Route
      GoRoute(
        path: AppConstants.profileRoute,
        name: 'profile',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Profile Screen - To be implemented'),
          ),
        ),
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
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri}" could not be found.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('Go to Home'),
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
  static void goToUserGuide() => _router.go(AppConstants.userGuideRoute);
  static void goToCamera() => _router.go(AppConstants.cameraRoute);
  static void goToResult() => _router.go(AppConstants.resultRoute);
  static void goToChatbot() => _router.go(AppConstants.chatbotRoute);
  static void goToProfile() => _router.go(AppConstants.profileRoute);

  /// Push navigation methods
  static void pushWelcome() => _router.push(AppConstants.introRoute);
  static void pushLogin() => _router.push(AppConstants.loginRoute);
  static void pushSignup() => _router.push(AppConstants.signupRoute);
  static void pushSurvey() => _router.push(AppConstants.surveyRoute);
  static void pushDemographics() => _router.push(AppConstants.demographicsRoute);
  static void pushHome() => _router.push(AppConstants.homeRoute);
  static void pushFaceScanning() => _router.push(AppConstants.faceScanningRoute);
  static void pushUserGuide() => _router.push(AppConstants.userGuideRoute);
  static void pushCamera() => _router.push(AppConstants.cameraRoute);
  static void pushResult() => _router.push(AppConstants.resultRoute);
  static void pushChatbot() => _router.push(AppConstants.chatbotRoute);
  static void pushProfile() => _router.push(AppConstants.profileRoute);

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
