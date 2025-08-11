import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';

/// Password Management section widget for profile page
class PasswordManagementSection extends StatelessWidget {
  const PasswordManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section header
          _buildSectionHeader(isTablet),
          
          // Password management buttons
          _buildPasswordActions(context, isTablet),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: Row(
        children: [
          Container(
            width: isTablet ? 48 : 40,
            height: isTablet ? 48 : 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.security,
              color: AppColors.primary,
              size: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bảo mật tài khoản',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: isTablet ? 4 : 2),
                Text(
                  'Quản lý mật khẩu và bảo mật',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordActions(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 20 : 16,
        0,
        isTablet ? 20 : 16,
        isTablet ? 20 : 16,
      ),
      child: Column(
        children: [
          // Change Password Button
          _buildActionButton(
            context: context,
            icon: Icons.lock_reset,
            title: 'Đổi mật khẩu',
            subtitle: 'Thay đổi mật khẩu hiện tại',
            color: AppColors.primary,
            onTap: () => context.go('/change-password'),
            isTablet: isTablet,
          ),
          
          SizedBox(height: isTablet ? 12 : 8),
          
          // Quick Access to Forgot Password (for testing)
          _buildActionButton(
            context: context,
            icon: Icons.help_outline,
            title: 'Quên mật khẩu?',
            subtitle: 'Khôi phục mật khẩu qua email',
            color: AppColors.warning,
            onTap: () => context.go('/forgot-password'),
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: isTablet ? 48 : 40,
              height: isTablet ? 48 : 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: isTablet ? 24 : 20,
              ),
            ),
            
            SizedBox(width: isTablet ? 16 : 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: isTablet ? 4 : 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.chevron_right,
              color: color,
              size: isTablet ? 24 : 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Testing section for API testing (Development only)
class ApiTestingSection extends StatelessWidget {
  const ApiTestingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section header
          _buildSectionHeader(isTablet),
          
          // API testing buttons
          _buildTestingButtons(context, isTablet),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: Row(
        children: [
          Container(
            width: isTablet ? 48 : 40,
            height: isTablet ? 48 : 40,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.api,
              color: AppColors.info,
              size: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API Testing',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: isTablet ? 4 : 2),
                Text(
                  'Test password management APIs',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestingButtons(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 20 : 16,
        0,
        isTablet ? 20 : 16,
        isTablet ? 20 : 16,
      ),
      child: Column(
        children: [
          // Test Change Password
          _buildTestButton(
            context: context,
            icon: Icons.password,
            title: 'Test Change Password',
            subtitle: 'Test /auth/me/change-password API',
            color: AppColors.primary,
            onTap: () => _testChangePassword(context),
            isTablet: isTablet,
          ),
          
          SizedBox(height: isTablet ? 8 : 6),
          
          // Test Forgot Password  
          _buildTestButton(
            context: context,
            icon: Icons.email,
            title: 'Test Request Reset',
            subtitle: 'Test /auth/request-forgot-pass API',
            color: AppColors.warning,
            onTap: () => _testRequestReset(context),
            isTablet: isTablet,
          ),
          
          SizedBox(height: isTablet ? 8 : 6),
          
          // Test Reset Password with dummy token
          _buildTestButton(
            context: context,
            icon: Icons.refresh,
            title: 'Test Reset Password',
            subtitle: 'Test /auth/reset-pass with dummy token',
            color: AppColors.error,
            onTap: () => _testResetPassword(context),
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: isTablet ? 20 : 18,
            ),
            
            SizedBox(width: isTablet ? 12 : 10),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.play_arrow,
              color: color,
              size: isTablet ? 20 : 18,
            ),
          ],
        ),
      ),
    );
  }

  void _testChangePassword(BuildContext context) async {
    final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);
    
    try {
      // Test with dummy data - this will fail but show the API call
      await authProvider.changePassword(
        oldPassword: 'testOldPassword',
        newPassword: 'testNewPassword',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Change Password API called successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔴 Change Password API error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _testRequestReset(BuildContext context) async {
    final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);
    
    try {
      await authProvider.requestPasswordReset('test@example.com');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Request Reset API called successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔴 Request Reset API error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _testResetPassword(BuildContext context) async {
    final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);
    
    try {
      await authProvider.resetPassword(
        token: 'dummy-token-for-testing',
        newPassword: 'testNewPassword123',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Reset Password API called successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔴 Reset Password API error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
