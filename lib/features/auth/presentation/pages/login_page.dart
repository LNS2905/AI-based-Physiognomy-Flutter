import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bagua_logo.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../providers/enhanced_auth_provider.dart';

/// Login page that matches the Figma design
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Navigation header
            _buildNavigationHeader(context),

            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 38),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                      const SizedBox(height: 32),

                      // Logo section
                      _buildLogoSection(),

                      const SizedBox(height: 20),

                      // Welcome section
                      _buildWelcomeSection(),

                      const SizedBox(height: 24),

                      // Form section
                      _buildFormSection(),

                      const SizedBox(height: 24),

                      // Sign in button
                      _buildSignInButton(),

                      const SizedBox(height: 24),

                      // OR divider
                      _buildOrDivider(),

                      const SizedBox(height: 20),

                      // Social login buttons
                      _buildSocialLoginSection(),

                      const SizedBox(height: 32),

                      // Sign up link
                      _buildSignUpLink(),

                      const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom indicator
            _buildBottomIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Row(
        children: [
          // Back button
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: StandardBackButton(),
          ),

          const Spacer(),

          // Sign In title
          const Text(
            'Đăng nhập',
            style: TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF333333),
              height: 1.15,
            ),
          ),

          const Spacer(),

          // Empty space to balance the layout
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
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
      child: const BaguaLogo(
        size: 56,
        showText: true,
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        const Text(
          'Chào mừng trở lại',
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: Color(0xFF333333),
            height: 1.15,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Đăng nhập vào tài khoản của bạn',
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Color(0xFF666666),
            height: 1.15,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field (used as username for new backend)
        const Text(
          'Email',
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF333333),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _usernameController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF333333),
            ),
            decoration: const InputDecoration(
              hintText: 'Nhập email của bạn',
              hintStyle: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xFF999999),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email của bạn';
              }
              // Basic email validation
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Vui lòng nhập email hợp lệ';
              }
              return null;
            },
          ),
        ),

        const SizedBox(height: 20),

        // Password field
        const Text(
          'Mật khẩu',
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF333333),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF333333),
            ),
            decoration: InputDecoration(
              hintText: 'Nhập mật khẩu của bạn',
              hintStyle: const TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xFF999999),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF666666),
                    size: 16,
                  ),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu của bạn';
              }
              if (value.length < AppConstants.minPasswordLength) {
                return 'Mật khẩu phải có ít nhất ${AppConstants.minPasswordLength} ký tự';
              }
              return null;
            },
          ),
        ),

        const SizedBox(height: 16),

        // Forgot password link
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => context.go('/forgot-password'),
            child: const Text(
              'Quên mật khẩu?',
              style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleLogin,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          width: double.infinity,
          height: 61,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'Đăng nhập',
              style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: Colors.white,
                height: 1.15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 1,
          color: const Color(0xFFEEEEEE),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white,
          child: const Text(
            'OR',
            style: TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0xFF999999),
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginSection() {
    return Consumer<EnhancedAuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            // Google login button
            _buildSocialButton(
              iconWidget: Image.asset(
                'google-icon.png',
                width: 24,
                height: 24,
              ),
              text: authProvider.isLoading 
                  ? 'Đang đăng nhập...' 
                  : 'Tiếp tục với Google',
              onTap: authProvider.isLoading 
                  ? null 
                  : () => _handleGoogleLogin(context),
              isLoading: authProvider.isLoading,
            ),

          ],
        );
      },
    );
  }

  Widget _buildSocialButton({
    Widget? iconWidget,
    required String text,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: const Color(0xFF333333).withOpacity(0.1),
        highlightColor: const Color(0xFF333333).withOpacity(0.05),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: onTap == null 
                  ? const Color(0xFFCCCCCC).withOpacity(0.5) 
                  : const Color(0xFFCCCCCC), 
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF333333)),
                  ),
                )
              else if (iconWidget != null)
                iconWidget,
              if (iconWidget != null && !isLoading) const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: onTap == null 
                      ? const Color(0xFF333333).withOpacity(0.5)
                      : const Color(0xFF333333),
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Chưa có tài khoản? ",
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF666666),
            height: 1.15,
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/signup'),
          child: const Text(
            'Đăng ký',
            style: TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF333333),
              height: 1.15,
            ),
          ),
        ),
      ],
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

      if (mounted && enhancedAuthProvider.isAuthenticated) {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập Google thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }


  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final enhancedAuthProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);

      final success = await enhancedAuthProvider.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigate to home after successful login
        context.go('/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enhancedAuthProvider.errorMessage ?? 'Đăng nhập thất bại'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
