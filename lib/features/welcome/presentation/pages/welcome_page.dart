import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bagua_logo.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';

/// Welcome page that matches the Figma design
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                // Top branding section
                _buildTopBranding(context),
                
                // Main content section
                Expanded(
                  child: _buildMainContent(context),
                ),
                
                // Action section
                _buildActionSection(context),
                
                // Bottom indicator
                _buildBottomIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBranding(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
      child: Row(
        children: [
          // Bagua Logo icon with animated glow
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withOpacity(_glowAnimation.value),
                      blurRadius: 16,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: const BaguaIcon(
              size: 48,
            ),
          ),
          const SizedBox(width: 12),

          // App name and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tướng học AI',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF333333),
                    height: 1.15,
                  ),
                ),
                const Text(
                  'AI cho khuôn mặt & tính cách của bạn',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF666666),
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),

          // Debug button for Google Sign-In test
          IconButton(
            onPressed: () => context.push('/google-signin-test'),
            icon: const Icon(Icons.bug_report),
            tooltip: 'Google Sign-In Test',
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 38),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main heading and description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Khám phá những gì\nkhuôn mặt bạn tiết lộ cùng AI',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w700,
                  fontSize: 36,
                  color: Color(0xFF333333),
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Phân tích tính cách thông qua khuôn mặt và chỉ tay.',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Consumer<EnhancedAuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
          child: Column(
            children: [
              // Google login button
              _buildSocialButton(
                context,
                iconWidget: Image.asset(
                  'google-icon.png',
                  width: 24,
                  height: 24,
                ),
                text: authProvider.isLoading 
                    ? 'Đang đăng nhập...' 
                    : 'Tiếp tục với Google',
                backgroundColor: Colors.white,
                textColor: const Color(0xFF333333),
                borderColor: const Color(0xFFCCCCCC),
                onTap: authProvider.isLoading 
                    ? null 
                    : () => _handleGoogleLogin(context),
                isLoading: authProvider.isLoading,
              ),

              const SizedBox(height: 24),

              // Or continue text
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'hoặc tiếp tục đến',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.15,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Login button
              _buildLoginButton(context, isDisabled: authProvider.isLoading),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    Widget? iconWidget,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: textColor.withOpacity(0.1),
          highlightColor: textColor.withOpacity(0.05),
          child: Container(
            width: double.infinity,
            height: 62,
            decoration: BoxDecoration(
              color: onTap == null ? backgroundColor.withOpacity(0.6) : backgroundColor,
              border: Border.all(
                color: onTap == null ? borderColor.withOpacity(0.6) : borderColor, 
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                else if (iconWidget != null)
                  iconWidget,
                if (iconWidget != null && !isLoading) const SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: onTap == null ? textColor.withOpacity(0.6) : textColor,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, {bool isDisabled = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : () => context.push('/login'),
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: AppColors.primary.withOpacity(0.05),
        child: Container(
          width: double.infinity,
          height: 53,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDisabled 
                  ? const Color(0xFFCCCCCC).withOpacity(0.5) 
                  : AppColors.primary, 
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Đăng nhập vào tài khoản',
              style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isDisabled 
                    ? const Color(0xFF666666).withOpacity(0.5)
                    : AppColors.primary,
                height: 1.15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: 88,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFFCCCCCC),
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }

  void _handleGoogleLogin(BuildContext context) async {
    final enhancedAuthProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);

    try {
      await enhancedAuthProvider.loginWithGoogle();

      if (enhancedAuthProvider.isAuthenticated) {
        // Navigate to home after successful login
        context.go('/home');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập Google thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng nhập Google thất bại: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

}
