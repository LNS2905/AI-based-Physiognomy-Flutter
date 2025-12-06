

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/fixed_bottom_navigation.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';
import '../../../auth/data/models/auth_models.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_menu_items.dart';
import '../widgets/password_management_section.dart';
import '../widgets/profile_quick_access.dart';

/// Profile page displaying user information and settings
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileProvider _profileProvider;
  late EnhancedAuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _profileProvider = context.read<ProfileProvider>();
    _authProvider = context.read<EnhancedAuthProvider>();

    // Set context for navigation
    _profileProvider.setContext(context);

    // Initialize profile data asynchronously
    Future.microtask(() => _initializeProfileData());
  }

  /// Initialize profile data with priority: EnhancedAuthProvider > API > Storage > Mock
  Future<void> _initializeProfileData() async {
    try {
      // First, try to load user from EnhancedAuthProvider if available
      final currentUser = _authProvider.currentUser;
      if (currentUser != null) {
        // Use a microtask to avoid setState during build
        // This will now also load stats and menu items
        await Future.microtask(() async => await _profileProvider.loadUserFromAuthProvider(currentUser));
        return;
      }

      // If no user in AuthProvider but still authenticated, try API
      if (_authProvider.isAuthenticated) {
        try {
          await _profileProvider.refreshUserData();
          return;
        } catch (e) {
          // If API call fails due to auth issues, clear auth state
          if (e.toString().contains('Authentication') || e.toString().contains('token')) {
            // Don't clear auth state here, let the auth provider handle it
          }
        }
      }

      // Final fallback: Load from storage or use mock data
      await _profileProvider.initializeProfile();
    } catch (e) {
      // Ensure we have some data to show
      await _profileProvider.initializeProfile();
    }
  }

  /// Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    try {
      if (_authProvider.isAuthenticated) {
        // Synchronize ProfileProvider with current user from AuthProvider
        if (_profileProvider.currentUser == null && _authProvider.currentUser != null) {
          await Future.microtask(() async => await _profileProvider.loadUserFromAuthProvider(_authProvider.currentUser));
        }

        try {
          await _profileProvider.refreshUserData();
        } catch (e) {
          // If refresh fails due to auth issues, fall back to current user data
          if (e.toString().contains('Authentication') || e.toString().contains('token')) {
            if (_authProvider.currentUser != null) {
              await Future.microtask(() async => await _profileProvider.loadUserFromAuthProvider(_authProvider.currentUser));
            } else {
              await _initializeProfileData();
            }
          } else {
            rethrow;
          }
        }
      } else {
        await _initializeProfileData();
      }
    } catch (e) {
      // Show error message to user only for non-auth errors
      if (mounted && !e.toString().contains('Authentication') && !e.toString().contains('token')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể cập nhật thông tin: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Consumer2<EnhancedAuthProvider, ProfileProvider>(
              builder: (context, authProvider, profileProvider, child) {
                try {
                  // Check if user is authenticated
                  if (!authProvider.isAuthenticated) {
                    return _buildUnauthenticatedState();
                  }

                  // Use user from EnhancedAuthProvider if available, otherwise from ProfileProvider
                  final User? currentUser = authProvider.currentUser ?? profileProvider.currentUser;

                  if (profileProvider.isLoading) {
                    return _buildLoadingState();
                  }

                  if (currentUser == null) {
                    return _buildErrorState();
                  }

                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    child: _buildProfileContent(profileProvider, currentUser),
                  );
                } catch (e, stackTrace) {
                  // Catch any rendering errors and show error state
                  return _buildErrorState();
                }
              },
            ),
            
            // Fixed Bottom Navigation
            FixedBottomNavigation(currentRoute: '/profile'),
          ],
        ),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.iconBgYellow,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Đang tải thông tin...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Không thể tải thông tin hồ sơ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Vui lòng thử lại sau',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _profileProvider.initializeProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Thử lại',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build unauthenticated state
  Widget _buildUnauthenticatedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.iconBgTeal,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 48,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Chưa đăng nhập',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Vui lòng đăng nhập để xem thông tin hồ sơ',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build main profile content
  Widget _buildProfileContent(ProfileProvider provider, User currentUser) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return CustomScrollView(
      slivers: [
        // App bar
        _buildSliverAppBar(isTablet),

        // Profile content
        SliverToBoxAdapter(
          child: Column(
            children: [
              // Profile header
              ProfileHeader(
                user: currentUser,
                onEditPressed: () => _showEditProfileDialog(),
              ),
              
              const SizedBox(height: 12),
              
              // Quick access buttons
              const ProfileQuickAccess(),
              
              const SizedBox(height: 12),
              
              // Profile statistics
              if (provider.profileStats != null &&
                  provider.memberSinceText.isNotEmpty)
                ProfileStats(
                  stats: provider.profileStats!,
                  memberSinceText: provider.memberSinceText,
                  lastAnalysisText: provider.lastAnalysisText,
                ),
              
              // Password Management Section
              const PasswordManagementSection(),
              
              // Menu items
              ProfileMenuItems(
                menuItems: provider.menuItems,
              ),


              
              // Bottom spacing for fixed navigation
              SizedBox(height: isTablet ? 132 : 124), // Extra space for fixed footer
            ],
          ),
        ),
      ],
    );
  }

  /// Build sliver app bar
  Widget _buildSliverAppBar(bool isTablet) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: false,
      backgroundColor: AppColors.backgroundWarm,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: StandardBackButton(),
      ),
      title: Text(
        'Hồ sơ',
        style: TextStyle(
          fontSize: isTablet ? 24 : 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            return Container(
              margin: const EdgeInsets.only(right: 4),
              child: IconButton(
                icon: profileProvider.isLoading
                    ? SizedBox(
                        width: isTablet ? 20 : 18,
                        height: isTablet ? 20 : 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.iconBgYellow,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: AppColors.primaryDark,
                          size: isTablet ? 22 : 20,
                        ),
                      ),
                onPressed: profileProvider.isLoading ? null : _handleRefresh,
                tooltip: 'Cập nhật thông tin',
              ),
            );
          },
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: isTablet ? 22 : 20,
              ),
            ),
            onPressed: () => _showLogoutConfirmation(),
            tooltip: 'Đăng xuất',
          ),
        ),
      ],
    );
  }

  /// Show edit profile dialog
  void _showEditProfileDialog() {
    context.push('/edit-profile');
  }

  /// Navigate to history page
  void _navigateToHistory() {
    context.push('/history');
  }

  /// Navigate to settings page
  void _navigateToSettings() {
    ErrorHandler.showInfo(
      context,
      'Tính năng cài đặt sẽ được triển khai trong phiên bản tiếp theo.',
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Xác nhận đăng xuất',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _performLogout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Perform logout operation
  Future<void> _performLogout() async {
    try {
      // Call logout method from ProfileProvider
      await _profileProvider.logout();
    } catch (e) {
      AppLogger.error('ProfilePage: Logout failed', e);
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng xuất thất bại: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  /// Show more options
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Options
            _buildOptionTile(
              icon: Icons.share_rounded,
              iconBgColor: AppColors.iconBgYellow,
              iconColor: AppColors.primaryDark,
              title: 'Chia sẻ hồ sơ',
              onTap: () {
                Navigator.pop(context);
                _shareProfile();
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildOptionTile(
              icon: Icons.download_rounded,
              iconBgColor: AppColors.iconBgTeal,
              iconColor: AppColors.secondary,
              title: 'Xuất dữ liệu',
              onTap: () {
                Navigator.pop(context);
                _exportData();
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildOptionTile(
              icon: Icons.help_outline_rounded,
              iconBgColor: AppColors.iconBgPeach,
              iconColor: AppColors.accent,
              title: 'Trợ giúp',
              onTap: () {
                Navigator.pop(context);
                _showHelp();
              },
            ),
            
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  /// Build option tile for bottom sheet
  Widget _buildOptionTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Share profile
  void _shareProfile() {
    ErrorHandler.showInfo(
      context,
      'Tính năng chia sẻ hồ sơ sẽ được triển khai trong phiên bản tiếp theo.',
    );
  }

  /// Export data
  void _exportData() {
    ErrorHandler.showInfo(
      context,
      'Tính năng xuất dữ liệu sẽ được triển khai trong phiên bản tiếp theo.',
    );
  }

  /// Show help
  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.iconBgBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.help_outline_rounded,
                color: AppColors.info,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Trợ giúp',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Nếu bạn cần hỗ trợ, vui lòng liên hệ với chúng tôi qua email: support@example.com',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Đóng',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
