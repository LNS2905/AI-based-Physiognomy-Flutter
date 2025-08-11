import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bagua_logo.dart';
import '../providers/enhanced_auth_provider.dart';

/// Change Password Page for authenticated users
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
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

                        const SizedBox(height: 24),

                        // Password form
                        _buildPasswordForm(),

                        const SizedBox(height: 32),

                        // Change password button
                        _buildChangePasswordButton(),

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
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Đổi mật khẩu',
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
    return const Column(
      children: [
        Text(
          'Tạo mật khẩu mới',
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF333333),
            height: 1.15,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Vui lòng nhập mật khẩu cũ và mật khẩu mới để thay đổi',
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
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Old password field
        _buildPasswordField(
          title: 'Mật khẩu hiện tại',
          controller: _oldPasswordController,
          isVisible: _isOldPasswordVisible,
          onVisibilityToggle: () => setState(() => _isOldPasswordVisible = !_isOldPasswordVisible),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mật khẩu hiện tại';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

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

  Widget _buildChangePasswordButton() {
    return Consumer<EnhancedAuthProvider>(
      builder: (context, authProvider, child) {
        return GestureDetector(
          onTap: authProvider.isLoading ? null : _handleChangePassword,
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
                      'Đổi mật khẩu',
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

  void _handleChangePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final enhancedAuthProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);

      try {
        await enhancedAuthProvider.changePassword(
          oldPassword: _oldPasswordController.text,
          newPassword: _newPasswordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đổi mật khẩu thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop(); // Return to previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(enhancedAuthProvider.errorMessage ?? 'Đổi mật khẩu thất bại'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
