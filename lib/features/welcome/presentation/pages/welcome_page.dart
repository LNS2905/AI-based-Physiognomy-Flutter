import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bagua_logo.dart';

/// Welcome page that matches the Figma design
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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
          // Bagua Logo icon
          const BaguaIcon(
            size: 38,
          ),
          const SizedBox(width: 12),
          
          // App name and subtitle
          Column(
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
                'Phân tích khuôn mặt',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.15,
                ),
              ),
            ],
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
                'Khám phá những gì',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w700,
                  fontSize: 36,
                  color: Color(0xFF333333),
                  height: 1.15,
                ),
              ),
              const Text(
                'Khuôn mặt bạn tiết lộ',
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
                'Phân tích AI tiên tiến tiết lộ các đặc điểm tính cách thông qua các nét mặt và đường chỉ tay của bạn.',
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
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
      child: Column(
        children: [
          // Google login button
          _buildSocialButton(
            context,
            icon: 'G',
            text: 'Tiếp tục với Google',
            backgroundColor: const Color(0xFF333333),
            textColor: Colors.white,
            borderColor: const Color(0xFF333333),
            onTap: () => _handleGoogleLogin(context),
          ),

          const SizedBox(height: 16),

          // Apple login button
          _buildSocialButton(
            context,
            icon: '',
            text: 'Tiếp tục với Apple',
            backgroundColor: Colors.white,
            textColor: const Color(0xFF333333),
            borderColor: const Color(0xFF999999),
            isApple: true,
            onTap: () => _handleAppleLogin(context),
          ),

          const SizedBox(height: 24),

          // Or continue text
          const Text(
            'hoặc tiếp tục đến',
            style: TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF999999),
              height: 1.15,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Login button
          _buildLoginButton(context),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required String icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
    bool isApple = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 62,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isApple)
              Icon(
                Icons.apple,
                color: textColor,
                size: 24,
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: backgroundColor,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: textColor,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/login'),
      child: Container(
        width: double.infinity,
        height: 53,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Đăng nhập vào tài khoản',
            style: TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF666666),
              height: 1.15,
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

  void _handleGoogleLogin(BuildContext context) {
    // TODO: Implement Google login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đăng nhập Google sẽ được triển khai'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _handleAppleLogin(BuildContext context) {
    // TODO: Implement Apple login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đăng nhập Apple sẽ được triển khai'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
