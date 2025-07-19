import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
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
          // Section title
          Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Row(
              children: [
                Icon(
                  Icons.menu,
                  color: AppColors.primary,
                  size: isTablet ? 24 : 20,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Text(
                  'Tùy chọn',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu items
          ...menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == menuItems.length - 1;
            
            return _buildMenuItem(
              item: item,
              isLast: isLast,
              isTablet: isTablet,
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Build individual menu item
  Widget _buildMenuItem({
    required ProfileMenuItem item,
    required bool isLast,
    required bool isTablet,
  }) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.vertical(
        bottom: isLast ? const Radius.circular(AppConstants.borderRadius) : Radius.zero,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 16 : 12,
        ),
        decoration: BoxDecoration(
          border: !isLast
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: isTablet ? 48 : 40,
              height: isTablet ? 48 : 40,
              decoration: BoxDecoration(
                color: item.isDestructive
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.icon,
                color: item.isDestructive ? AppColors.error : AppColors.primary,
                size: isTablet ? 24 : 20,
              ),
            ),
            
            SizedBox(width: isTablet ? 16 : 12),
            
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 15,
                      fontWeight: FontWeight.w600,
                      color: item.isDestructive
                          ? AppColors.error
                          : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: isTablet ? 4 : 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: isTablet ? 24 : 20,
            ),
          ],
        ),
      ),
    );
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
