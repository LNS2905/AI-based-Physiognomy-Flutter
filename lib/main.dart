import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/utils/logger.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/survey/presentation/providers/survey_provider.dart';
import 'features/face_scan/presentation/providers/face_scan_provider.dart';
import 'features/ai_conversation/presentation/providers/chat_provider.dart';
import 'features/history/presentation/providers/history_provider.dart';

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
    // Initialize storage service
    await StorageService.init();
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
        // Authentication Provider
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..initialize(),
        ),

        // Survey Provider
        ChangeNotifierProvider(
          create: (context) => SurveyProvider(),
        ),

        // Face Scan Provider
        ChangeNotifierProvider(
          create: (context) => FaceScanProvider(),
        ),

        // AI Chat Provider
        ChangeNotifierProvider(
          create: (context) => ChatProvider()..initialize(),
        ),

        // History Provider
        ChangeNotifierProvider(
          create: (context) => HistoryProvider(),
        ),

        // Add other providers here as needed
      ],
      child: MaterialApp.router(
        title: 'Ứng dụng Tướng học AI',
        debugShowCheckedModeBanner: false,
        
        // Theme configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        
        // Router configuration
        routerConfig: AppRouter.router,
        
        // Global error handling
        builder: (context, child) {
          // Handle global errors
          ErrorWidget.builder = (FlutterErrorDetails details) {
            AppLogger.error('Flutter Error', details.exception, details.stack);
            return _buildErrorWidget(details);
          };
          
          return child ?? const SizedBox.shrink();
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
