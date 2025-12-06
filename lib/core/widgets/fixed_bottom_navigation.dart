import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// Fixed bottom navigation bar with modern floating design
/// Inspired by Cracker Book UI - clean, rounded, with subtle shadows
class FixedBottomNavigation extends StatelessWidget {
  final String currentRoute;
  final EdgeInsets? padding;

  const FixedBottomNavigation({
    super.key,
    required this.currentRoute,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: padding ?? const EdgeInsets.only(bottom: 24, top: 8),
        child: _buildBottomNavigation(context),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.navBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            icon: Icons.home_rounded,
            label: 'Trang chủ',
            isActive: _isActive('/home'),
            onTap: () => _navigateToHome(context),
          ),
          _buildNavItem(
            context,
            icon: Icons.face_retouching_natural_rounded,
            label: 'Quét',
            isActive: _isActive('/face-scanning') || _isActive('/palm-scanning'),
            onTap: () => _navigateToScan(context),
          ),
          _buildNavItem(
            context,
            icon: Icons.auto_awesome_rounded,
            label: 'Tử vi',
            isActive: _isActive('/tu-vi-input'),
            onTap: () => _navigateToTuVi(context),
          ),
          _buildNavItem(
            context,
            icon: Icons.person_rounded,
            label: 'Hồ sơ',
            isActive: _isActive('/profile'),
            onTap: () => _navigateToProfile(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.textOnPrimary : AppColors.navInactive,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isActive(String route) {
    // Handle special cases
    if (currentRoute.startsWith('/face-scanning') ||
        currentRoute.startsWith('/palm-scanning') ||
        currentRoute.startsWith('/camera') ||
        currentRoute.startsWith('/palm-camera')) {
      return route == '/face-scanning';
    }

    if (currentRoute.startsWith('/tu-vi')) {
      return route == '/tu-vi-input';
    }

    if (currentRoute.startsWith('/profile')) {
      return route == '/profile';
    }

    if (currentRoute == '/' || currentRoute.startsWith('/home')) {
      return route == '/home';
    }

    return currentRoute.startsWith(route);
  }

  void _navigateToHome(BuildContext context) {
    if (!_isActive('/home')) {
      context.go('/home');
    }
  }

  void _navigateToScan(BuildContext context) {
    if (!_isActive('/face-scanning')) {
      context.push('/face-scanning');
    }
  }

  void _navigateToTuVi(BuildContext context) {
    if (!_isActive('/tu-vi-input')) {
      context.push('/tu-vi-input');
    }
  }

  void _navigateToProfile(BuildContext context) {
    if (!_isActive('/profile')) {
      context.push('/profile');
    }
  }
}

/// Wrapper widget to add fixed bottom navigation to any screen
class ScreenWithFixedNavigation extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final EdgeInsets? navPadding;
  final double? bottomPadding;

  const ScreenWithFixedNavigation({
    super.key,
    required this.child,
    required this.currentRoute,
    this.navPadding,
    this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content with bottom padding to avoid footer overlap
        Padding(
          padding: EdgeInsets.only(bottom: bottomPadding ?? 100),
          child: child,
        ),

        // Fixed bottom navigation
        FixedBottomNavigation(
          currentRoute: currentRoute,
          padding: navPadding,
        ),
      ],
    );
  }
}
