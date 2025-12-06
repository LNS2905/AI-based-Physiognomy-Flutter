import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Quick access buttons for common profile actions
class ProfileQuickAccess extends StatelessWidget {
  const ProfileQuickAccess({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 4 : 2,
              vertical: isTablet ? 8 : 6,
            ),
            child: Text(
              'Truy cập nhanh',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          SizedBox(height: isTablet ? 8 : 6),
          
          // Quick access buttons
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessButton(
                  context: context,
                  icon: Icons.lock_reset,
                  title: 'Đổi mật khẩu',
                  color: AppColors.primary,
                  onTap: () => context.go('/change-password'),
                  isTablet: isTablet,
                ),
              ),
              
              SizedBox(width: isTablet ? 16 : 12),
              
              Expanded(
                child: _buildQuickAccessButton(
                  context: context,
                  icon: Icons.history,
                  title: 'Lịch sử',
                  color: AppColors.secondary,
                  onTap: () => context.go('/history'),
                  isTablet: isTablet,
                ),
              ),
              
              /*
              SizedBox(width: isTablet ? 16 : 12),
              
              Expanded(
                child: _buildQuickAccessButton(
                  context: context,
                  icon: Icons.security,
                  title: 'Bảo mật',
                  color: AppColors.warning,
                  onTap: () => _showSecurityOptions(context),
                  isTablet: isTablet,
                ),
              ),
              */
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16 : 12,
          horizontal: isTablet ? 12 : 8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: isTablet ? 40 : 32,
              height: isTablet ? 40 : 32,
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
            
            SizedBox(height: isTablet ? 8 : 6),
            
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showSecurityOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tùy chọn bảo mật',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Security options
            _buildSecurityOption(
              context: context,
              icon: Icons.password,
              title: 'Đổi mật khẩu',
              subtitle: 'Thay đổi mật khẩu tài khoản',
              onTap: () {
                Navigator.pop(context);
                context.go('/change-password');
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildSecurityOption(
              context: context,
              icon: Icons.help_outline,
              title: 'Quên mật khẩu?',
              subtitle: 'Khôi phục mật khẩu qua email',
              onTap: () {
                Navigator.pop(context);
                context.go('/forgot-password');
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildSecurityOption(
              context: context,
              icon: Icons.logout,
              title: 'Đăng xuất',
              subtitle: 'Thoát khỏi tài khoản hiện tại',
              onTap: () {
                Navigator.pop(context);
                // Logout will be handled by existing logout functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sử dụng nút đăng xuất trong menu để đăng xuất'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
              isDestructive: true,
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.primary;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.chevron_right,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
