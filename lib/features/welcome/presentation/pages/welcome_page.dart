import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

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
          // Logo icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF999999), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.face,
              color: Color(0xFF999999),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // App name and subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Physiognomy',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF333333),
                  height: 1.15,
                ),
              ),
              const Text(
                'Face Analysis',
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
          // Background decorative elements
          Stack(
            children: [
              // Dashed border decoration
              Container(
                margin: const EdgeInsets.only(top: 40),
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFD0D0D0),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomPaint(
                  painter: DashedBorderPainter(),
                  child: Container(),
                ),
              ),
              
              // Main heading and description
              Container(
                margin: const EdgeInsets.only(top: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Discover What',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.w700,
                        fontSize: 36,
                        color: Color(0xFF333333),
                        height: 1.15,
                      ),
                    ),
                    const Text(
                      'Your Face Reveals',
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
                      'Advanced AI analysis reveals personality traits through your facial features and palm lines.',
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
            text: 'Continue with Google',
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
            text: 'Continue with Apple',
            backgroundColor: Colors.white,
            textColor: const Color(0xFF333333),
            borderColor: const Color(0xFF999999),
            isApple: true,
            onTap: () => _handleAppleLogin(context),
          ),
          
          const SizedBox(height: 24),
          
          // Or continue text
          const Text(
            'or continue to',
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
      onTap: () => context.go('/login'),
      child: Container(
        width: double.infinity,
        height: 53,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Login to your account',
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
        content: Text('Google login will be implemented'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _handleAppleLogin(BuildContext context) {
    // TODO: Implement Apple login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple login will be implemented'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

/// Custom painter for dashed border decoration
class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    // Top border
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    // Right border
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width, startY),
        Offset(size.width, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }

    // Bottom border
    startX = size.width;
    while (startX > 0) {
      canvas.drawLine(
        Offset(startX, size.height),
        Offset(startX - dashWidth, size.height),
        paint,
      );
      startX -= dashWidth + dashSpace;
    }

    // Left border
    startY = size.height;
    while (startY > 0) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY - dashWidth),
        paint,
      );
      startY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
