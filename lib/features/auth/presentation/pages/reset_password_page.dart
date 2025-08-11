import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bagua_logo.dart';
import '../providers/enhanced_auth_provider.dart';

/// Reset Password Page for setting new password with token
class ResetPasswordPage extends StatefulWidget {
  final String token;

  const ResetPasswordPage({
    super.key,
    required this.token,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPasswordReset = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
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

                        // Title section
                        _buildTitleSection(),

                        const SizedBox(height: 32),

                        if (!_isPasswordReset) ...[
                          // Password form
                          _buildPasswordForm(),

                          const SizedBox(height: 32),

                          // Reset password button
                          _buildResetPasswordButton(),
                        ] else ...[
                          // Success confirmation
                          _buildSuccessConfirmation(),

                          const SizedBox(height: 32),

                          // Go to login button
                          _buildGoToLoginButton(),
                        ],

                        const SizedBox(height: 24),

                        if (!_isPasswordReset)
                          // Back to login link
                          _buildBackToLoginLink(),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationHeader(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (!_isPasswordReset)
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF333333),
                  size: 18,
                ),
              ),
            )
          else
            const SizedBox(width: 40),
          const Expanded(
            child: Center(
              child: Text(
                'Đặt lại mật khẩu',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF333333),
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return const Column(
      children: [
        BaguaLogo(size: 80),
        SizedBox(height: 16),
        Text(
          'BaGua AI',
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Color(0xFF333333),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          _isPasswordReset ? 'Đặt lại mật khẩu thành công!' : 'Tạo mật khẩu mới',
          style: const TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF333333),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isPasswordReset
              ? 'Mật khẩu của bạn đã được đặt lại thành công. Bây giờ bạn có thể đăng nhập với mật khẩu mới.'
              : 'Nhập mật khẩu mới cho tài khoản của bạn',
          style: const TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF666666),
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // New password field
        _buildPasswordField(
          title: 'Mật khẩu mới',
          controller: _newPasswordController,
          isVisible: _isNewPasswordVisible,
          onVisibilityToggle: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mật khẩu mới';
            }
            if (value.length < 6) {
              return 'Mật khẩu phải có ít nhất 6 ký tự';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Confirm new password field
        _buildPasswordField(
          title: 'Xác nhận mật khẩu mới',
          controller: _confirmPasswordController,
          isVisible: _isConfirmPasswordVisible,
          onVisibilityToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng xác nhận mật khẩu mới';
            }
            if (value != _newPasswordController.text) {
              return 'Mật khẩu xác nhận không khớp';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String title,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
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
            controller: controller,
            obscureText: !isVisible,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF333333),
            ),
            decoration: InputDecoration(
              hintText: 'Nhập $title',
              hintStyle: const TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xFF999999),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              suffixIcon: GestureDetector(
                onTap: onVisibilityToggle,
                child: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF999999),
                  size: 20,
                ),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessConfirmation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: Color(0xFF16A34A),
          ),
          SizedBox(height: 16),
          Text(
            'Mật khẩu đã được đặt lại!',
            style: TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF16A34A),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'Bạn có thể đăng nhập với mật khẩu mới ngay bây giờ.',
            style: TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResetPasswordButton() {
    return Consumer<EnhancedAuthProvider>(
      builder: (context, authProvider, child) {
        return GestureDetector(
          onTap: authProvider.isLoading ? null : _handleResetPassword,
          child: Container(
            width: double.infinity,
            height: 61,
            decoration: BoxDecoration(
              color: authProvider.isLoading 
                  ? const Color(0xFF999999) 
                  : const Color(0xFF333333),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Đặt lại mật khẩu',
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
      },
    );
  }

  Widget _buildGoToLoginButton() {
    return GestureDetector(
      onTap: () => context.go('/login'),
      child: Container(
        width: double.infinity,
        height: 61,
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Đi đến đăng nhập',
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

  Widget _buildBackToLoginLink() {
    return GestureDetector(
      onTap: () => context.go('/login'),
      child: const Text(
        'Quay lại đăng nhập',
        style: TextStyle(
          fontFamily: 'Arial',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xFF666666),
          height: 1.15,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final enhancedAuthProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);

      try {
        await enhancedAuthProvider.resetPassword(
          token: widget.token,
          newPassword: _newPasswordController.text,
        );

        if (mounted) {
          setState(() {
            _isPasswordReset = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đặt lại mật khẩu thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(enhancedAuthProvider.errorMessage ?? 'Đặt lại mật khẩu thất bại'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
