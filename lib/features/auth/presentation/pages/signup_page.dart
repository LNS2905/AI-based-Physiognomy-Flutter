import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/bagua_logo.dart';

/// Sign Up page that matches the Figma design
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                        
                        // Create Account button
                        _buildCreateAccountButton(),
                        
                        const SizedBox(height: 24),
                        
                        // OR divider
                        _buildOrDivider(),
                        
                        const SizedBox(height: 20),
                        
                        // Social signup buttons
                        _buildSocialSignupSection(),
                        
                        const SizedBox(height: 32),
                        
                        // Sign in link
                        _buildSignInLink(),
                        
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
          
          // Sign Up title
          const Text(
            'Sign Up',
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
    return const BaguaLogo(
      size: 56,
      showText: true,
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        const Text(
          'Create Account',
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
          'Join us to get started',
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
        // Full Name field
        const Text(
          'Full Name',
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF333333),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        _buildInputField(
          controller: _fullNameController,
          hintText: 'Enter your full name',
          validator: (value) => Validators.validateRequired(value, 'Full name'),
        ),

        const SizedBox(height: 20),

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
        _buildInputField(
          controller: _emailController,
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
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
        _buildInputField(
          controller: _passwordController,
          hintText: 'Create a password',
          obscureText: !_isPasswordVisible,
          validator: Validators.validatePassword,
          suffixIcon: _buildPasswordToggle(
            isVisible: _isPasswordVisible,
            onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
        ),

        const SizedBox(height: 20),

        // Confirm Password field
        const Text(
          'Confirm Password',
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF333333),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        _buildInputField(
          controller: _confirmPasswordController,
          hintText: 'Confirm your password',
          obscureText: !_isConfirmPasswordVisible,
          validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
          suffixIcon: _buildPasswordToggle(
            isVisible: _isConfirmPasswordVisible,
            onToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
          ),
        ),

        const SizedBox(height: 20),

        // Terms and conditions checkbox
        _buildTermsCheckbox(),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          fontFamily: 'Arial',
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: Color(0xFF333333),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Color(0xFF999999),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordToggle({
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            '👁',
            style: TextStyle(
              fontSize: 12,
              color: isVisible ? const Color(0xFF333333) : const Color(0xFF999999),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
          child: Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
              borderRadius: BorderRadius.circular(2),
              color: _agreeToTerms ? const Color(0xFF333333) : Colors.transparent,
            ),
            child: _agreeToTerms
                ? const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.15,
              ),
              children: [
                TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return GestureDetector(
      onTap: _handleCreateAccount,
      child: Container(
        width: double.infinity,
        height: 61,
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Create Account',
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

  Widget _buildSocialSignupSection() {
    return Row(
      children: [
        // Google signup button
        Expanded(
          child: _buildSocialButton(
            icon: 'G',
            text: 'Google',
            onTap: () => _handleGoogleSignup(context),
          ),
        ),

        const SizedBox(width: 16),

        // Apple signup button
        Expanded(
          child: _buildSocialButton(
            icon: '',
            text: 'Apple',
            isApple: true,
            onTap: () => _handleAppleSignup(context),
          ),
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
        height: 52,
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
                      fontSize: 10,
                      color: Color(0xFF999999),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF333333),
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF666666),
            height: 1.15,
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: const Text(
            'Sign In',
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

  void _handleCreateAccount() {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Conditions and Privacy Policy'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement actual signup logic with AuthProvider
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account creation functionality will be implemented'),
          backgroundColor: AppColors.info,
        ),
      );

      // Navigate to survey after successful signup
      context.go('/survey');
    }
  }

  void _handleGoogleSignup(BuildContext context) {
    // TODO: Implement Google signup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google signup will be implemented'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _handleAppleSignup(BuildContext context) {
    // TODO: Implement Apple signup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple signup will be implemented'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
