import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../utils/logger.dart';
import '../../features/auth/presentation/providers/enhanced_auth_provider.dart';

/// Reusable logout button widget
class LogoutButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onLogoutStart;
  final VoidCallback? onLogoutComplete;
  final VoidCallback? onLogoutError;
  final bool showConfirmation;
  final String? confirmationTitle;
  final String? confirmationMessage;
  final ButtonStyle? style;

  const LogoutButton({
    super.key,
    this.text,
    this.icon,
    this.onLogoutStart,
    this.onLogoutComplete,
    this.onLogoutError,
    this.showConfirmation = true,
    this.confirmationTitle,
    this.confirmationMessage,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedAuthProvider>(
      builder: (context, authProvider, child) {
        return ElevatedButton.icon(
          onPressed: authProvider.isLoading
              ? null
              : () => _handleLogout(context, authProvider),
          icon: authProvider.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon ?? Icons.logout),
          label: Text(text ?? 'Đăng xuất'),
          style: style ?? ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        );
      },
    );
  }

  /// Handle logout process
  Future<void> _handleLogout(BuildContext context, EnhancedAuthProvider authProvider) async {
    if (showConfirmation) {
      final confirmed = await _showLogoutConfirmation(context);
      if (!confirmed) return;
    }

    try {
      onLogoutStart?.call();
      
      AppLogger.info('LogoutButton: Starting logout process');
      await authProvider.logout();
      
      AppLogger.info('LogoutButton: Logout completed, navigating to welcome');
      
      // Navigate to welcome page and clear navigation stack
      if (context.mounted) {
        context.go('/intro');
      }
      
      onLogoutComplete?.call();
      
    } catch (e) {
      AppLogger.error('LogoutButton: Logout failed', e);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng xuất thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () => _handleLogout(context, authProvider),
            ),
          ),
        );
      }
      
      onLogoutError?.call();
    }
  }

  /// Show logout confirmation dialog
  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(confirmationTitle ?? 'Xác nhận đăng xuất'),
        content: Text(confirmationMessage ?? 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}

/// Simple logout list tile for use in menus
class LogoutListTile extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onLogoutStart;
  final VoidCallback? onLogoutComplete;
  final VoidCallback? onLogoutError;
  final bool showConfirmation;

  const LogoutListTile({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.onLogoutStart,
    this.onLogoutComplete,
    this.onLogoutError,
    this.showConfirmation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedAuthProvider>(
      builder: (context, authProvider, child) {
        return ListTile(
          leading: Icon(
            icon ?? Icons.logout,
            color: AppColors.error,
          ),
          title: Text(
            title ?? 'Đăng xuất',
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null
              ? Text(subtitle!)
              : null,
          trailing: authProvider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
          onTap: authProvider.isLoading
              ? null
              : () => _handleLogout(context, authProvider),
        );
      },
    );
  }

  /// Handle logout process
  Future<void> _handleLogout(BuildContext context, EnhancedAuthProvider authProvider) async {
    if (showConfirmation) {
      final confirmed = await _showLogoutConfirmation(context);
      if (!confirmed) return;
    }

    try {
      onLogoutStart?.call();
      
      AppLogger.info('LogoutListTile: Starting logout process');
      await authProvider.logout();
      
      AppLogger.info('LogoutListTile: Logout completed, navigating to welcome');
      
      // Navigate to welcome page and clear navigation stack
      if (context.mounted) {
        context.go('/intro');
      }
      
      onLogoutComplete?.call();
      
    } catch (e) {
      AppLogger.error('LogoutListTile: Logout failed', e);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng xuất thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      
      onLogoutError?.call();
    }
  }

  /// Show logout confirmation dialog
  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}
