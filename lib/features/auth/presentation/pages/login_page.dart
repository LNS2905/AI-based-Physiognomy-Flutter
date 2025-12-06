import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bagua_logo.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../providers/enhanced_auth_provider.dart';

/// Login page with Cracker Book design style
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Focus nodes for input styling
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

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

    // Listen to focus changes
    _emailFocusNode.addListener(() {
      setState(() => _isEmailFocused = _emailFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
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
              AppColors.primarySoft, // Warm cream top
              AppColors.background, // Clean background
            ],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Navigation header
              _buildNavigationHeader(context),

              // Main scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 24),

                          // Logo section
                          _buildLogoSection(),

                          const SizedBox(height: 24),

                          // Welcome section
                          _buildWelcomeSection(),

                          const SizedBox(height: 32),

                          // Form section in a card
                          _buildFormCard(),

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
      ),
    );
  }

  Widget _buildNavigationHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Back button with new style
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: StandardBackButton(),
            ),
          ),

          const Spacer(),

          // Sign In title with badge style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'Đăng nhập',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const Spacer(),

          // Empty space to balance the layout
          const SizedBox(width: 48),
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
                color: AppColors.primary.withOpacity(_glowAnimation.value),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        child: const BaguaLogo(
          size: 48,
          showText: false,
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        const Text(
          'Chào mừng trở lại',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Đăng nhập vào tài khoản của bạn',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email field
          _buildInputLabel('Email', Icons.email_outlined),
          const SizedBox(height: 8),
          _buildEmailField(),

          const SizedBox(height: 20),

          // Password field
          _buildInputLabel('Mật khẩu', Icons.lock_outline),
          const SizedBox(height: 8),
          _buildPasswordField(),

          const SizedBox(height: 16),

          // Forgot password link
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => context.go('/forgot-password'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: _isEmailFocused
            ? AppColors.primarySoft
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEmailFocused ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: _usernameController,
        focusNode: _emailFocusNode,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Nhập email của bạn',
          hintStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.alternate_email,
              color:
                  _isEmailFocused ? AppColors.primary : AppColors.textTertiary,
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 50),
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
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: _isPasswordFocused
            ? AppColors.primarySoft
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isPasswordFocused ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        obscureText: !_isPasswordVisible,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Nhập mật khẩu của bạn',
          hintStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.lock_outline,
              color: _isPasswordFocused
                  ? AppColors.primary
                  : AppColors.textTertiary,
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 50),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
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
    );
  }

  Widget _buildSignInButton() {
    return Consumer<EnhancedAuthProvider>(
      builder: (context, authProvider, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: authProvider.isLoading ? null : _handleLogin,
            borderRadius: BorderRadius.circular(20),
            splashColor: AppColors.primaryDark.withOpacity(0.2),
            highlightColor: AppColors.primaryDark.withOpacity(0.1),
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: authProvider.isLoading
                    ? null
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                color: authProvider.isLoading
                    ? AppColors.primary.withOpacity(0.5)
                    : null,
                borderRadius: BorderRadius.circular(20),
                boxShadow: authProvider.isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Center(
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textOnPrimary),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.login_rounded,
                            color: AppColors.textOnPrimary,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: AppColors.textOnPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.border,
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'HOẶC',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.border,
                  Colors.transparent,
                ],
              ),
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
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.g_mobiledata,
                  size: 28,
                  color: Colors.red,
                ),
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
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: AppColors.primary.withOpacity(0.05),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: onTap == null
                  ? AppColors.border.withOpacity(0.5)
                  : AppColors.border,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.textSecondary),
                  ),
                )
              else if (iconWidget != null)
                iconWidget,
              if (iconWidget != null && !isLoading) const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: onTap == null
                      ? AppColors.textSecondary.withOpacity(0.5)
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Chưa có tài khoản? ",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/signup'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Đăng ký',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: 100,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  void _handleGoogleLogin(BuildContext context) async {
    final enhancedAuthProvider =
        Provider.of<EnhancedAuthProvider>(context, listen: false);

    try {
      await enhancedAuthProvider.loginWithGoogle();

      if (mounted && enhancedAuthProvider.isAuthenticated) {
        // Navigate to home after successful login
        context.go('/home');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Đăng nhập Google thành công!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Đăng nhập Google thất bại: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final enhancedAuthProvider =
          Provider.of<EnhancedAuthProvider>(context, listen: false);

      final success = await enhancedAuthProvider.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Đăng nhập thành công!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        // Navigate to home after successful login
        context.go('/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                      enhancedAuthProvider.errorMessage ?? 'Đăng nhập thất bại'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}
