

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
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Không thể tải thông tin hồ sơ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng thử lại sau',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _profileProvider.initializeProfile(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  /// Build unauthenticated state
  Widget _buildUnauthenticatedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa đăng nhập',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Đăng nhập'),
          ),
        ],
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
              
              const SizedBox(height: 8),
              
              // Quick access buttons
              const ProfileQuickAccess(),
              
              const SizedBox(height: 8),
              
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: StandardBackButton(),
      ),
      title: Text(
        'Hồ sơ',
        style: TextStyle(
          fontSize: isTablet ? 22 : 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            return IconButton(
              icon: profileProvider.isLoading
                  ? SizedBox(
                      width: isTablet ? 20 : 16,
                      height: isTablet ? 20 : 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : Icon(
                      Icons.refresh,
                      color: AppColors.primary,
                      size: isTablet ? 28 : 24,
                    ),
              onPressed: profileProvider.isLoading ? null : _handleRefresh,
              tooltip: 'Cập nhật thông tin',
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.logout,
            color: AppColors.error,
            size: isTablet ? 28 : 24,
          ),
          onPressed: () => _showLogoutConfirmation(),
          tooltip: 'Đăng xuất',
        ),
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: AppColors.textPrimary,
            size: isTablet ? 28 : 24,
          ),
          onPressed: () => _showMoreOptions(),
        ),
      ],
    );
  }

  /// Show edit profile dialog
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa hồ sơ'),
        content: const Text('Tính năng chỉnh sửa hồ sơ sẽ được triển khai trong phiên bản tiếp theo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Navigate to history page
  void _navigateToHistory() {
    context.push('/history');
  }

  /// Navigate to settings page
  void _navigateToSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cài đặt'),
        content: const Text('Tính năng cài đặt sẽ được triển khai trong phiên bản tiếp theo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performLogout();
            },
            child: Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.error),
            ),
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
          ),
        );
      }
    }
  }

  /// Show more options
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Options
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.primary),
              title: const Text('Chia sẻ hồ sơ'),
              onTap: () {
                Navigator.pop(context);
                _shareProfile();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.download, color: AppColors.secondary),
              title: const Text('Xuất dữ liệu'),
              onTap: () {
                Navigator.pop(context);
                _exportData();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.help_outline, color: AppColors.accent),
              title: const Text('Trợ giúp'),
              onTap: () {
                Navigator.pop(context);
                _showHelp();
              },
            ),
            
            const SizedBox(height: 20),
          ],
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
        title: const Text('Trợ giúp'),
        content: const Text('Nếu bạn cần hỗ trợ, vui lòng liên hệ với chúng tôi qua email: support@example.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
