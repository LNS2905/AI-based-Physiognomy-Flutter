import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/base_provider.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/logout_service.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../auth/data/repositories/user_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';
import '../../data/services/analysis_statistics_service.dart';

/// Profile provider for managing user profile state
class ProfileProvider extends BaseProvider {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  AnalysisStatisticsService? _statisticsService;

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
    // Initialize statistics service with auth provider from context
    if (_statisticsService == null) {
      final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);
      _statisticsService = AnalysisStatisticsService(authProvider: authProvider);
    }
  }

  /// Initialize profile with user data
  Future<void> initializeProfile() async {
    AppLogger.info('ProfileProvider: Initializing profile...');
    await executeOperation(
      () async {
        await _loadUserFromStorage();
        // Menu items should always be loaded regardless of user data source
        if (_menuItems.isEmpty) {
          _loadMenuItems();
        }
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
      // Load real stats when user is loaded from storage
      await _loadRealStats();
    } else {
      AppLogger.warning('ProfileProvider: Failed to load user from storage: ${result is Error ? (result as Error).failure.message : 'Unknown error'}');
      AppLogger.warning('ProfileProvider: Using mock data for demonstration');
      _loadMockUserData();
      await _loadRealStats();
    }
  }

  /// Load user data from AuthProvider (alternative method)
  Future<void> loadUserFromAuthProvider(User? user) async {
    if (user != null) {
      _currentUser = user;
      AppLogger.info('ProfileProvider: User data loaded from AuthProvider: ${_currentUser?.displayName}');
      // Load real stats when user is loaded from AuthProvider
      await _loadRealStats();
      // Load menu items if not already loaded
      if (_menuItems.isEmpty) {
        _loadMenuItems();
      }
      notifyListeners();
    } else {
      AppLogger.warning('ProfileProvider: No user data from AuthProvider, using mock data');
      _loadMockUserData();
      await _loadRealStats();
      _loadMenuItems();
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

          // Refresh real stats after getting updated user data
          await _loadRealStats();
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
    _currentUser = const User(
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

  /// Load real profile statistics from API
  Future<void> _loadRealStats() async {
    if (_statisticsService == null) {
      AppLogger.warning('ProfileProvider: Statistics service not initialized, loading mock stats');
      _loadMockStats();
      return;
    }

    try {
      AppLogger.info('ProfileProvider: Loading real statistics from API...');
      final result = await _statisticsService!.getUserStatistics();
      
      if (result is Success<Map<String, dynamic>>) {
        _profileStats = result.data;
        AppLogger.info('ProfileProvider: Real stats loaded: ${_profileStats?['totalAnalyses']} total analyses');
      } else if (result is Error) {
        AppLogger.error('ProfileProvider: Failed to load real stats: ${result.failure?.message ?? 'Unknown error'}');
        // Fallback to mock stats if API fails
        _loadMockStats();
      }
    } catch (e) {
      AppLogger.error('ProfileProvider: Exception loading real stats: $e');
      // Fallback to mock stats on error
      _loadMockStats();
    }
  }

  /// Load mock profile statistics (fallback)
  void _loadMockStats() {
    _profileStats = {
      'totalAnalyses': 0,
      'faceAnalyses': 0,
      'palmAnalyses': 0,
      'lastAnalysisDate': null,
      'memberSince': DateTime.now(),
      'accuracyScore': 0.0,
    };
    
    AppLogger.info('ProfileProvider: Mock stats loaded (fallback): ${_profileStats?['totalAnalyses']} total analyses');
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

  /// Public method to perform logout
  Future<void> logout() async {
    await _logout();
  }

  Future<void> _logout() async {
    AppLogger.info('ProfileProvider: Logout requested');
    
    if (_context == null) {
      AppLogger.error('ProfileProvider: Context not available for logout');
      return;
    }

    try {
      // Show loading indicator
      setLoading(true);
      
      // Perform complete logout
      await LogoutService.performCompleteLogout();
      
      // Clear auth provider state
      if (_context != null) {
        final authProvider = Provider.of<EnhancedAuthProvider>(_context!, listen: false);
        await authProvider.logout();
      }
      
      // Clear local profile data
      _currentUser = null;
      _profileStats = null;
      _menuItems.clear();
      
      AppLogger.info('ProfileProvider: Logout completed successfully');
      
      // Navigate to login screen
      if (_context != null && _context!.mounted) {
        _context!.go('/login');
      }
      
    } catch (e) {
      AppLogger.error('ProfileProvider: Logout failed', e);
      
      // Still navigate to login even if logout partially failed
      if (_context != null && _context!.mounted) {
        _context!.go('/login');
      }
    } finally {
      setLoading(false);
    }
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
