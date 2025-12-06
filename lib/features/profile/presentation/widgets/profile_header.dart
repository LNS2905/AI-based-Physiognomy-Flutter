import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../payment/presentation/widgets/credit_display_widget.dart';

/// Profile header widget displaying user avatar and basic info
class ProfileHeader extends StatelessWidget {
  final User user;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.user,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowYellow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.borderYellow.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Avatar and edit button
          Stack(
            children: [
              _buildAvatar(isTablet),
              if (onEditPressed != null)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: _buildEditButton(),
                ),
            ],
          ),
          
          SizedBox(height: isTablet ? 24 : 20),
          
          // User name
          Text(
            user.displayName,
            style: TextStyle(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: isTablet ? 10 : 8),
          
          // User email with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.iconBgTeal,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: isTablet ? 16 : 14,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          
          if (user.phone?.isNotEmpty ?? false) ...[
            SizedBox(height: isTablet ? 10 : 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.iconBgPeach,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_outlined,
                    size: isTablet ? 16 : 14,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  user.phone ?? '',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
          
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.borderYellow.withValues(alpha: 0.5),
                    AppColors.borderYellow.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),
          
          // Credits Display
          CreditDisplayWidget(
            credits: user.credits ?? 0,
            onTap: () => context.go('/payment/packages'),
            showAddButton: true,
          ),
        ],
      ),
    );
  }

  /// Build user avatar
  Widget _buildAvatar(bool isTablet) {
    final size = isTablet ? 120.0 : 100.0;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowYellow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: user.avatar != null
            ? Image.network(
                user.avatar!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(size),
              )
            : _buildDefaultAvatar(size),
      ),
    );
  }

  /// Build default avatar with user initials
  Widget _buildDefaultAvatar(double size) {
    final initials = _getUserInitials();
    
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  /// Build edit button
  Widget _buildEditButton() {
    return GestureDetector(
      onTap: onEditPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondary,
              AppColors.secondaryDark,
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.edit_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  /// Get user initials for default avatar
  String _getUserInitials() {
    String initials = '';

    if (user.firstName?.isNotEmpty ?? false) {
      initials += user.firstName![0].toUpperCase();
    }

    if (user.lastName?.isNotEmpty ?? false) {
      initials += user.lastName![0].toUpperCase();
    }

    if (initials.isEmpty) {
      initials = user.email[0].toUpperCase();
    }

    return initials;
  }
}
