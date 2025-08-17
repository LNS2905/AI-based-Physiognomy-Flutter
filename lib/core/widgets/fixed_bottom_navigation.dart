import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// Fixed bottom navigation bar with 4 main navigation items
/// Uses transparent background and floating style
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
        padding: padding ?? const EdgeInsets.only(bottom: 16),
        child: _buildBottomNavigation(context),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(
            Icons.home_outlined,
            isActive: _isActive('/home'),
            onTap: () => _navigateToHome(context),
          ),
          _buildBottomNavItem(
            Icons.face_outlined,
            isActive: _isActive('/face-scanning') || _isActive('/palm-scanning'),
            onTap: () => _navigateToScan(context),
          ),
          _buildBottomNavItem(
            Icons.chat_bubble_outline,
            isActive: _isActive('/ai-conversation'),
            onTap: () => _navigateToChat(context),
          ),
          _buildBottomNavItem(
            Icons.person_outline,
            isActive: _isActive('/profile'),
            onTap: () => _navigateToProfile(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                )
              : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: isActive ? 22 : 20,
          color: isActive ? Colors.white : AppColors.textSecondary,
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
    
    if (currentRoute.startsWith('/ai-conversation') || 
        currentRoute.startsWith('/chatbot')) {
      return route == '/ai-conversation';
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

  void _navigateToChat(BuildContext context) {
    if (!_isActive('/ai-conversation')) {
      context.push('/ai-conversation');
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