import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/error_handler.dart';
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

  @override
  void initState() {
    super.initState();
    _profileProvider = context.read<ProfileProvider>();
    
    // Initialize profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileProvider.initializeProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return _buildLoadingState();
            }

            if (provider.currentUser == null) {
              return _buildErrorState();
            }

            return _buildProfileContent(provider);
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

  /// Build main profile content
  Widget _buildProfileContent(ProfileProvider provider) {
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
                user: provider.currentUser!,
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
