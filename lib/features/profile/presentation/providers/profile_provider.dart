import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/base_provider.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../auth/data/repositories/user_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';

/// Profile provider for managing user profile state
class ProfileProvider extends BaseProvider {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  ProfileProvider({
    UserRepository? userRepository,
    AuthRepository? authRepository,
  })  : _userRepository = userRepository ?? UserRepository(),
        _authRepository = authRepository ?? AuthRepository();

  User? _currentUser;
  Map<String, dynamic>? _profileStats;
  List<ProfileMenuItem> _menuItems = [];
  BuildContext? _context;

  /// Current user profile
  User? get currentUser => _currentUser;

  /// Profile statistics
  Map<String, dynamic>? get profileStats => _profileStats;

  /// Profile menu items
  List<ProfileMenuItem> get menuItems => _menuItems;

  /// Set context for navigation and dialogs
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Initialize profile with user data
  Future<void> initializeProfile() async {
    AppLogger.info('ProfileProvider: Initializing profile...');
    await executeOperation(
      () async {
        await _loadUserFromStorage();
        _loadMockStats();
        _loadMenuItems();
      },
      operationName: 'initializeProfile',
      showLoading: false,
    );
  }

  /// Load user data from storage
  Future<void> _loadUserFromStorage() async {
    final result = await _userRepository.getCurrentUserFromStorage();
    if (result is Success<User>) {
      _currentUser = result.data;
      AppLogger.info('ProfileProvider: User data loaded from storage: ${_currentUser?.displayName}');
    } else {
      AppLogger.warning('ProfileProvider: Failed to load user from storage: ${result is Error ? (result as Error).failure.message : 'Unknown error'}');
      AppLogger.warning('ProfileProvider: Using mock data for demonstration');
      _loadMockUserData();
    }
  }

  /// Load user data from AuthProvider (alternative method)
  void loadUserFromAuthProvider(User? user) {
    if (user != null) {
      _currentUser = user;
      AppLogger.info('ProfileProvider: User data loaded from AuthProvider: ${_currentUser?.displayName}');
      notifyListeners();
    } else {
      AppLogger.warning('ProfileProvider: No user data from AuthProvider, using mock data');
      _loadMockUserData();
      notifyListeners();
    }
  }

  /// Refresh user data from API /auth/me
  Future<void> refreshUserData() async {
    AppLogger.info('ProfileProvider: Refreshing user data from API...');
    await executeOperation(
      () async {
        final result = await _authRepository.getCurrentUser();
        AppLogger.info('ProfileProvider: API call result type: ${result.runtimeType}');

        if (result is Success<User>) {
          _currentUser = result.data;
          AppLogger.info('ProfileProvider: User data refreshed successfully');
          AppLogger.info('ProfileProvider: User ID: ${_currentUser?.id}');
          AppLogger.info('ProfileProvider: User Name: ${_currentUser?.displayName}');
          AppLogger.info('ProfileProvider: User Email: ${_currentUser?.email}');
          AppLogger.info('ProfileProvider: User Phone: ${_currentUser?.phone}');
          AppLogger.info('ProfileProvider: User Age: ${_currentUser?.age}');
          AppLogger.info('ProfileProvider: User Gender: ${_currentUser?.gender}');
          AppLogger.info('ProfileProvider: User Avatar: ${_currentUser?.avatar}');

          // Update stored user data
          await _userRepository.storeUserData(result.data);

          // Refresh stats after getting updated user data
          _loadMockStats();
        } else if (result is Error<User>) {
          AppLogger.error('ProfileProvider: Failed to refresh user data: ${result.failure.message}');
          AppLogger.error('ProfileProvider: Failure type: ${result.failure.runtimeType}');
          AppLogger.error('ProfileProvider: Failure code: ${result.failure.code}');
          throw Exception('Failed to refresh user data: ${result.failure.message}');
        } else {
          AppLogger.error('ProfileProvider: Unexpected result type: ${result.runtimeType}');
          throw Exception('Unexpected result type from API call');
        }
      },
      operationName: 'refreshUserData',
      showLoading: true,
    );
  }

  /// Update user profile
  Future<bool> updateProfile({
    required UpdateUserDTO updateUserDto,
  }) async {
    final result = await executeApiOperation(
      () => _userRepository.updateProfile(updateUserDto: updateUserDto),
      operationName: 'updateProfile',
    );

    if (result != null) {
      _currentUser = result;
      AppLogger.info('ProfileProvider: Profile updated successfully');
      return true;
    }
    return false;
  }

  /// Load mock user data
  void _loadMockUserData() {
    _currentUser = User(
      id: 1,
      email: 'nguyenvana@example.com',
      firstName: 'Nguyễn',
      lastName: 'Văn A',
      phone: '+84 123 456 789',
      age: 30,
      gender: Gender.male,
      avatar: null, // Will use default avatar
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
        icon: Icons.lock_outline,
        title: 'Đổi mật khẩu',
        subtitle: 'Thay đổi mật khẩu tài khoản',
        onTap: () => _navigateToChangePassword(),
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



  /// Navigation methods (to be implemented)
  void _navigateToPersonalInfo() {
    AppLogger.info('ProfileProvider: Navigate to personal info');
    // TODO: Implement navigation
  }

  void _navigateToChangePassword() {
    AppLogger.info('ProfileProvider: Navigate to change password');
    if (_context != null) {
      _context!.go('/change-password');
    }
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
