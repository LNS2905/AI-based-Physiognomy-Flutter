import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/base_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Profile provider for managing user profile state
class ProfileProvider extends BaseProvider {
  UserModel? _currentUser;
  Map<String, dynamic>? _profileStats;
  List<ProfileMenuItem> _menuItems = [];
  BuildContext? _context;

  /// Current user profile
  UserModel? get currentUser => _currentUser;

  /// Profile statistics
  Map<String, dynamic>? get profileStats => _profileStats;

  /// Profile menu items
  List<ProfileMenuItem> get menuItems => _menuItems;

  /// Set context for navigation and dialogs
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Initialize profile with mock data
  void initializeProfile() {
    _loadMockUserData();
    _loadMockStats();
    _loadMenuItems();
    notifyListeners();
  }

  /// Load mock user data
  void _loadMockUserData() {
    _currentUser = UserModel(
      id: 'mock_user_001',
      email: 'nguyenvana@example.com',
      firstName: 'Nguyễn',
      lastName: 'Văn A',
      phoneNumber: '+84 123 456 789',
      dateOfBirth: DateTime(1990, 5, 15),
      gender: 'Nam',
      profileImageUrl: null, // Will use default avatar
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    );
    
    AppLogger.info('ProfileProvider: Mock user data loaded: ${_currentUser?.displayName}');
  }

  /// Load mock profile statistics
  void _loadMockStats() {
    _profileStats = {
      'totalAnalyses': 15,
      'faceAnalyses': 8,
      'palmAnalyses': 7,
      'lastAnalysisDate': DateTime.now().subtract(const Duration(days: 2)),
      'memberSince': DateTime(2024, 1, 1),
      'accuracyScore': 92.5,
    };
    
    AppLogger.info('ProfileProvider: Mock stats loaded: ${_profileStats?['totalAnalyses']} total analyses');
  }

  /// Load profile menu items
  void _loadMenuItems() {
    _menuItems = [
      ProfileMenuItem(
        icon: Icons.person_outline,
        title: 'Thông tin cá nhân',
        subtitle: 'Chỉnh sửa thông tin cá nhân',
        onTap: () => _navigateToPersonalInfo(),
      ),
      ProfileMenuItem(
        icon: Icons.history,
        title: 'Lịch sử phân tích',
        subtitle: 'Xem lại các kết quả đã phân tích',
        onTap: () => _navigateToHistory(),
      ),
      ProfileMenuItem(
        icon: Icons.analytics_outlined,
        title: 'Thống kê',
        subtitle: 'Xem thống kê chi tiết',
        onTap: () => _navigateToStatistics(),
      ),
      ProfileMenuItem(
        icon: Icons.settings_outlined,
        title: 'Cài đặt',
        subtitle: 'Tùy chỉnh ứng dụng',
        onTap: () => _navigateToSettings(),
      ),
      ProfileMenuItem(
        icon: Icons.help_outline,
        title: 'Trợ giúp',
        subtitle: 'Hướng dẫn và hỗ trợ',
        onTap: () => _navigateToHelp(),
      ),
      ProfileMenuItem(
        icon: Icons.info_outline,
        title: 'Về ứng dụng',
        subtitle: 'Thông tin phiên bản',
        onTap: () => _navigateToAbout(),
      ),
      ProfileMenuItem(
        icon: Icons.logout,
        title: 'Đăng xuất',
        subtitle: 'Thoát khỏi tài khoản',
        onTap: () => _logout(),
        isDestructive: true,
      ),
    ];
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return false;

    setLoading(true);
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      final updatedUser = _currentUser!.copyWith(
        firstName: firstName ?? _currentUser!.firstName,
        lastName: lastName ?? _currentUser!.lastName,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        dateOfBirth: dateOfBirth ?? _currentUser!.dateOfBirth,
        gender: gender ?? _currentUser!.gender,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        updatedAt: DateTime.now(),
      );

      _currentUser = updatedUser;
      AppLogger.info('ProfileProvider: Profile updated successfully');

      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('ProfileProvider: Failed to update profile', e);
      setLoading(false);
      return false;
    }
  }

  /// Navigation methods (to be implemented)
  void _navigateToPersonalInfo() {
    AppLogger.info('ProfileProvider: Navigate to personal info');
    // TODO: Implement navigation
  }

  void _navigateToHistory() {
    AppLogger.info('ProfileProvider: Navigate to history');
    // TODO: Implement navigation
  }

  void _navigateToStatistics() {
    AppLogger.info('ProfileProvider: Navigate to statistics');
    // TODO: Implement navigation
  }

  void _navigateToSettings() {
    AppLogger.info('ProfileProvider: Navigate to settings');
    // TODO: Implement navigation
  }

  void _navigateToHelp() {
    AppLogger.info('ProfileProvider: Navigate to help');
    // TODO: Implement navigation
  }

  void _navigateToAbout() {
    AppLogger.info('ProfileProvider: Navigate to about');
    // TODO: Implement navigation
  }

  void _logout() {
    AppLogger.info('ProfileProvider: Logout requested');
    // Logout will be handled by LogoutButton/LogoutListTile widget
  }

  /// Get formatted member since text
  String get memberSinceText {
    if (_profileStats == null) return '';
    final memberSince = _profileStats!['memberSince'] as DateTime?;
    if (memberSince == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(memberSince);
    
    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '$years năm';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng';
    } else {
      return '${difference.inDays} ngày';
    }
  }

  /// Get formatted last analysis text
  String get lastAnalysisText {
    if (_profileStats == null) return 'Chưa có phân tích';
    final lastAnalysis = _profileStats!['lastAnalysisDate'] as DateTime?;
    if (lastAnalysis == null) return 'Chưa có phân tích';
    
    final now = DateTime.now();
    final difference = now.difference(lastAnalysis);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inMinutes} phút trước';
    }
  }
}

/// Profile menu item model
class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });
}
