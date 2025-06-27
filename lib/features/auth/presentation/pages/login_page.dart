import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Login page that matches the Figma design
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
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
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '←',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // Sign In title
          const Text(
            'Sign In',
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
    return Column(
      children: [
        // Logo icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF999999), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.face,
            color: Color(0xFF999999),
            size: 32,
          ),
        ),
        const SizedBox(height: 8),

        // LOGO text
        const Text(
          'LOGO',
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF999999),
            height: 1.15,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        const Text(
          'Welcome Back',
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
          'Sign in to your account',
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
        // Email field
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
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF333333),
            ),
            decoration: const InputDecoration(
              hintText: 'Enter your email',
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
                return 'Please enter your email';
              }
              if (!RegExp(AppConstants.emailPattern).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),

        const SizedBox(height: 20),

        // Password field
        const Text(
          'Password',
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
              hintText: 'Enter your password',
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
                return 'Please enter your password';
              }
              if (value.length < AppConstants.minPasswordLength) {
                return 'Password must be at least ${AppConstants.minPasswordLength} characters';
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
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Forgot password feature coming soon'),
                ),
              );
            },
            child: const Text(
              'Forgot Password?',
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
    return GestureDetector(
      onTap: _handleLogin,
      child: Container(
        width: double.infinity,
        height: 61,
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Sign In',
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
    return Column(
      children: [
        // Google login button
        _buildSocialButton(
          icon: 'G',
          text: 'Continue with Google',
          onTap: () => _handleGoogleLogin(context),
        ),

        const SizedBox(height: 12),

        // Apple login button
        _buildSocialButton(
          icon: '',
          text: 'Continue with Apple',
          isApple: true,
          onTap: () => _handleAppleLogin(context),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String text,
    required VoidCallback onTap,
    bool isApple = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isApple)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF999999), width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.apple,
                  color: Color(0xFF333333),
                  size: 16,
                ),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF999999), width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xFF333333),
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF666666),
            height: 1.15,
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/signup'),
          child: const Text(
            'Sign Up',
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

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement actual login logic with AuthProvider
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login functionality will be implemented'),
          backgroundColor: AppColors.info,
        ),
      );

      // Navigate to survey after successful login (for new users) or home (for returning users)
      // For demo, navigate to survey
      context.go('/survey');
    }
  }
}
