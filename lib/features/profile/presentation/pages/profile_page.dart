import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_menu_items.dart';

/// Profile page displaying user information and settings
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileProvider _profileProvider;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _profileProvider = context.read<ProfileProvider>();
    _authProvider = context.read<AuthProvider>();

    // Initialize profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProfileData();
    });
  }

  /// Initialize profile data with priority: API > AuthProvider > Storage > Mock
  Future<void> _initializeProfileData() async {
    try {
      // First, try to refresh user data from API /auth/me
      if (_authProvider.isAuthenticated) {
        await _profileProvider.refreshUserData();
        return;
      }
    } catch (e) {
      // If API call fails, fallback to other methods
      print('Failed to refresh from API, falling back: $e');
    }

    // Fallback: Try to load user from AuthProvider first
    final currentUser = _authProvider.currentUser;
    if (currentUser != null) {
      _profileProvider.loadUserFromAuthProvider(currentUser);
    } else {
      // Final fallback: Load from storage or use mock data
      await _profileProvider.initializeProfile();
    }
  }

  /// Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    try {
      if (_authProvider.isAuthenticated) {
        await _profileProvider.refreshUserData();
      } else {
        await _initializeProfileData();
      }
    } catch (e) {
      // Show error message to user
      if (mounted) {
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
        child: Consumer2<AuthProvider, ProfileProvider>(
          builder: (context, authProvider, profileProvider, child) {
            // Check if user is authenticated
            if (!authProvider.isAuthenticated) {
              return _buildUnauthenticatedState();
            }

            // Use user from AuthProvider if available, otherwise from ProfileProvider
            final currentUser = authProvider.currentUser ?? profileProvider.currentUser;

            if (profileProvider.isLoading) {
              return _buildLoadingState();
            }

            if (currentUser == null) {
              return _buildErrorState();
            }

            // Update ProfileProvider with current user if needed
            if (profileProvider.currentUser == null && authProvider.currentUser != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                profileProvider.loadUserFromAuthProvider(authProvider.currentUser);
              });
            }

            return RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.primary,
              child: _buildProfileContent(profileProvider, currentUser),
            );
          },
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
  Widget _buildProfileContent(ProfileProvider provider, UserModel currentUser) {
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
              
              // Quick actions
              ProfileQuickActions(
                onEditProfile: () => _showEditProfileDialog(),
                onViewHistory: () => _navigateToHistory(),
                onSettings: () => _navigateToSettings(),
              ),
              
              // Profile statistics
              if (provider.profileStats != null)
                ProfileStats(
                  stats: provider.profileStats!,
                  memberSinceText: provider.memberSinceText,
                  lastAnalysisText: provider.lastAnalysisText,
                ),
              
              // Menu items
              ProfileMenuItems(
                menuItems: provider.menuItems,
              ),
              
              // Bottom spacing
              SizedBox(height: isTablet ? 32 : 24),
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
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.textPrimary,
          size: isTablet ? 28 : 24,
        ),
        onPressed: () => context.pop(),
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
