import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/utils/logger.dart';
import 'core/services/google_sign_in_service.dart';
import 'features/auth/presentation/providers/enhanced_auth_provider.dart';
import 'features/survey/presentation/providers/survey_provider.dart';
import 'features/face_scan/presentation/providers/face_scan_provider.dart';
import 'features/ai_conversation/presentation/providers/chat_provider.dart';
import 'features/history/presentation/providers/history_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/tu_vi/presentation/providers/tu_vi_provider.dart';
import 'features/payment/presentation/providers/payment_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await _initializeServices();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Run the app
  runApp(const MyApp());
}

/// Initialize application services
Future<void> _initializeServices() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Initialize Stripe
    Stripe.publishableKey = 'pk_test_51SR6hxPofBTvOXyOgfTqc2CwRZex2Oe1u0NesBJKFOAD3MgxxbzQqInnzpbTNODCC0rv2QjuPOMyUp9RzwMHXXTr00jGlA5ohH';
    await Stripe.instance.applySettings();

    // Initialize storage service
    await StorageService.init();

    // Initialize Google Sign-In service
    GoogleSignInService().initialize();

    AppLogger.info('Application services initialized successfully');
  } catch (e) {
    AppLogger.error('Failed to initialize services', e);
    // Continue with app launch even if some services fail
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Enhanced Authentication Provider
        ChangeNotifierProvider(
          create: (context) => EnhancedAuthProvider(),
          lazy: false, // Ensure provider is created immediately
        ),

        // Survey Provider
        ChangeNotifierProvider(
          create: (context) => SurveyProvider(),
        ),

        // Face Scan Provider
        ChangeNotifierProxyProvider<EnhancedAuthProvider, FaceScanProvider>(
          create: (context) => FaceScanProvider(),
          update: (context, authProvider, previous) {
            // Use updateDependency pattern to avoid lifecycle issues
            // This prevents '_dependents.isEmpty' assertion error
            if (previous == null) {
              return FaceScanProvider(authProvider: authProvider);
            }
            // Update the auth provider dependency on the existing instance
            previous.updateAuthProvider(authProvider);
            return previous;
          },
        ),

        // AI Chat Provider - initialized when user logs in
        ChangeNotifierProvider(
          create: (context) => ChatProvider(),
        ),

        // History Provider
        ChangeNotifierProxyProvider<EnhancedAuthProvider, HistoryProvider>(
          create: (context) {
            AppLogger.info('HistoryProvider CREATE called');
            final authProvider = context.read<EnhancedAuthProvider>();
            return HistoryProvider(authProvider: authProvider);
          },
          update: (context, authProvider, previous) {
            // Use updateDependency pattern to avoid lifecycle issues
            // This prevents '_dependents.isEmpty' assertion error on Samsung S23 Note
            if (previous == null) {
              AppLogger.warning('HistoryProvider UPDATE called with NULL previous - creating new instance');
              return HistoryProvider(authProvider: authProvider);
            }
            // Update the auth provider dependency on the existing instance
            // instead of creating a new instance
            previous.updateAuthProvider(authProvider);
            AppLogger.info('HistoryProvider UPDATE called - updated auth dependency on existing instance');
            return previous;
          },
        ),

        // Profile Provider
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(),
        ),

        // Tu Vi Provider
        ChangeNotifierProvider(
          create: (context) => TuViProvider(),
        ),

        // Payment Provider
        ChangeNotifierProvider(
          create: (context) => PaymentProvider(),
        ),

        // Add other providers here as needed
      ],
      child: MaterialApp.router(
        title: 'Ứng dụng Tướng học AI',
        debugShowCheckedModeBanner: false,
        
        // Disable all debug overlays
        showPerformanceOverlay: false,
        checkerboardRasterCacheImages: false,
        checkerboardOffscreenLayers: false,
        showSemanticsDebugger: false,
        
        // Theme configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        
        // Router configuration
        routerConfig: AppRouter.router,
        
        // Global error handling
        builder: (context, child) {
          // Disable all UI warnings in debug mode
          // ErrorWidget.builder = (FlutterErrorDetails details) {
          //   // Log error for debugging
          //   AppLogger.error('Flutter Error', details.exception, details.stack);

          //   // In debug mode, suppress UI warnings and return empty widget
          //   // This will hide all visual error indicators
          //   return const SizedBox.shrink();
          // };

          // Wrap child to prevent text scaling warnings
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0, // Prevent text scaling warnings
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  /// Build error widget for production
  Widget _buildErrorWidget(FlutterErrorDetails details) {
    return MaterialApp(
      home: Scaffold(
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
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please restart the app',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  SystemNavigator.pop();
                },
                child: const Text('Restart App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
