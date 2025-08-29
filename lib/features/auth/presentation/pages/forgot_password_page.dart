import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bagua_logo.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../providers/enhanced_auth_provider.dart';

/// Forgot Password Page for requesting password reset
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
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

                        if (!_isEmailSent) ...[
                          // Email form
                          _buildEmailForm(),

                          const SizedBox(height: 32),

                          // Send reset email button
                          _buildSendEmailButton(),
                        ] else ...[
                          // Email sent confirmation
                          _buildEmailSentConfirmation(),

                          const SizedBox(height: 32),

                          // Resend email button
                          _buildResendEmailButton(),
                        ],

                        const SizedBox(height: 24),

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
          const StandardBackButton(),
          const Expanded(
            child: Center(
              child: Text(
                'Quên mật khẩu',
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
        
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          _isEmailSent ? 'Kiểm tra email của bạn' : 'Khôi phục mật khẩu',
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
          _isEmailSent
              ? 'Chúng tôi đã gửi liên kết khôi phục mật khẩu đến email của bạn'
              : 'Nhập địa chỉ email để nhận liên kết khôi phục mật khẩu',
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

  Widget _buildEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              hintText: 'Nhập địa chỉ email',
              hintStyle: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xFF999999),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: Color(0xFF999999),
                size: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập địa chỉ email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Vui lòng nhập địa chỉ email hợp lệ';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailSentConfirmation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            size: 48,
            color: Color(0xFF0891B2),
          ),
          const SizedBox(height: 16),
          Text(
            'Email đã được gửi đến\n${_emailController.text}',
            style: const TextStyle(
              fontFamily: 'Arial',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xFF0891B2),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Vui lòng kiểm tra hộp thư đến và làm theo hướng dẫn để đặt lại mật khẩu.',
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

  Widget _buildSendEmailButton() {
    return Consumer<EnhancedAuthProvider>(
      builder: (context, authProvider, child) {
        return GestureDetector(
          onTap: authProvider.isLoading ? null : _handleSendResetEmail,
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
                      'Gửi email khôi phục',
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

  Widget _buildResendEmailButton() {
    return Consumer<EnhancedAuthProvider>(
      builder: (context, authProvider, child) {
        return GestureDetector(
          onTap: authProvider.isLoading ? null : _handleSendResetEmail,
          child: Container(
            width: double.infinity,
            height: 61,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: authProvider.isLoading 
                    ? const Color(0xFF999999) 
                    : const Color(0xFF333333),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF333333)),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Gửi lại email',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Color(0xFF333333),
                        height: 1.15,
                      ),
                    ),
            ),
          ),
        );
      },
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

  void _handleSendResetEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      final enhancedAuthProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);

      try {
        await enhancedAuthProvider.requestPasswordReset(_emailController.text.trim());

        if (mounted) {
          setState(() {
            _isEmailSent = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email khôi phục mật khẩu đã được gửi!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(enhancedAuthProvider.errorMessage ?? 'Gửi email thất bại'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
