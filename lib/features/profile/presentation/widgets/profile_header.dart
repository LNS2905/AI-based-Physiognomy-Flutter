import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/models/auth_models.dart';

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
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
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
                  bottom: 0,
                  right: 0,
                  child: _buildEditButton(),
                ),
            ],
          ),
          
          SizedBox(height: isTablet ? 20 : 16),
          
          // User name
          Text(
            user.displayName,
            style: TextStyle(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: isTablet ? 8 : 6),
          
          // User email
          Text(
            user.email,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (user.phone?.isNotEmpty ?? false) ...[
            SizedBox(height: isTablet ? 6 : 4),
            Text(
              user.phone ?? '',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.edit,
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
