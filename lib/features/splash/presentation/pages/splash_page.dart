import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/bagua_logo.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';

/// Splash screen page with Cracker Book design style
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      AppLogger.info('SplashPage: Starting app initialization');

      // Wait for minimum splash duration
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // BYPASS AUTH FOR TESTING UI/UX
      if (AppConstants.bypassAuthentication) {
        AppLogger.info(
            'SplashPage: Authentication bypassed, navigating to home');
        context.go(AppConstants.homeRoute);
        return;
      }

      // Get auth provider
      final authProvider =
          Provider.of<EnhancedAuthProvider>(context, listen: false);

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
        AppLogger.info(
            'SplashPage: User is not authenticated, navigating to welcome');
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primarySoft, // #FFF8E7 - Warm cream
              AppColors.backgroundWarm, // Slightly warmer
              AppColors.background, // Clean background
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo with glow effect
                  _buildLogoSection(),

                  const SizedBox(height: 32),

                  // App name
                  _buildAppName(),

                  const SizedBox(height: 12),

                  // Tagline
                  _buildTagline(),

                  const Spacer(flex: 2),

                  // Loading indicator
                  _buildLoadingIndicator(),

                  const SizedBox(height: 48),

                  // Version text
                  _buildVersionText(),

                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary
                        .withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 40 * _glowAnimation.value,
                    spreadRadius: 10 * _glowAnimation.value,
                  ),
                  BoxShadow(
                    color: AppColors.primaryLight
                        .withOpacity(0.5 * _glowAnimation.value),
                    blurRadius: 60 * _glowAnimation.value,
                    spreadRadius: 20 * _glowAnimation.value,
                  ),
                ],
              ),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowYellow.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: BaguaLogo(
                    size: 72,
                    showText: false,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppName() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        AppConstants.appName,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Khám phá vận mệnh qua gương mặt',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary.withOpacity(0.8),
              ),
              backgroundColor: AppColors.primaryLight.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Đang khởi tạo...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionText() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        'Phiên bản ${AppConstants.appVersion}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
