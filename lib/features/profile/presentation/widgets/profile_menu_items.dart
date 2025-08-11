import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/logout_button.dart';
import '../providers/profile_provider.dart';

/// Profile menu items widget displaying navigation options
class ProfileMenuItems extends StatelessWidget {
  final List<ProfileMenuItem> menuItems;

  const ProfileMenuItems({
    super.key,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Hide the entire options section
    return const SizedBox.shrink();
  }
}

/// Quick action buttons widget for common actions
class ProfileQuickActions extends StatelessWidget {
  final VoidCallback? onEditProfile;
  final VoidCallback? onViewHistory;
  final VoidCallback? onSettings;

  const ProfileQuickActions({
    super.key,
    this.onEditProfile,
    this.onViewHistory,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      child: Row(
        children: [
          if (onEditProfile != null)
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.edit_outlined,
                label: 'Chỉnh sửa',
                onTap: onEditProfile!,
                color: AppColors.primary,
                isTablet: isTablet,
              ),
            ),
          
          if (onEditProfile != null && onViewHistory != null)
            SizedBox(width: isTablet ? 16 : 12),
          
          if (onViewHistory != null)
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.history,
                label: 'Lịch sử',
                onTap: onViewHistory!,
                color: AppColors.secondary,
                isTablet: isTablet,
              ),
            ),
          
          if (onViewHistory != null && onSettings != null)
            SizedBox(width: isTablet ? 16 : 12),
          
          if (onSettings != null)
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.settings_outlined,
                label: 'Cài đặt',
                onTap: onSettings!,
                color: AppColors.accent,
                isTablet: isTablet,
              ),
            ),
        ],
      ),
    );
  }

  /// Build quick action button
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required bool isTablet,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16 : 12,
          horizontal: isTablet ? 16 : 12,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: isTablet ? 28 : 24,
            ),
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
