import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';

/// Splash screen page
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      AppLogger.info('SplashPage: Starting app initialization');

      // Wait for minimum splash duration
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Get auth provider
      final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);

      // Initialize auth provider if not already initialized
      if (!authProvider.hasInitialized) {
        AppLogger.info('SplashPage: Initializing auth provider');
        await authProvider.initializeAuth();
      }

      if (!mounted) return;

      // Check authentication status
      AppLogger.info('SplashPage: Checking authentication status');
      final isAuthenticated = await authProvider.checkAuthStatus();

      if (!mounted) return;

      // Navigate based on authentication status
      if (isAuthenticated) {
        AppLogger.info('SplashPage: User is authenticated, navigating to home');
        context.go(AppConstants.homeRoute);
      } else {
        AppLogger.info('SplashPage: User is not authenticated, navigating to welcome');
        context.go(AppConstants.introRoute);
      }
    } catch (e) {
      AppLogger.error('SplashPage: Error during initialization', e);
      if (mounted) {
        // On error, navigate to welcome screen as fallback
        context.go(AppConstants.introRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.face,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
