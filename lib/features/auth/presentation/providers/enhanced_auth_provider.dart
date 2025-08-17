// Enhanced Authentication Provider
import 'package:ai_physiognomy_app/core/providers/base_provider.dart';
import 'package:ai_physiognomy_app/core/utils/logger.dart';
import 'package:ai_physiognomy_app/core/network/api_result.dart';
import 'package:ai_physiognomy_app/features/auth/data/repositories/enhanced_auth_repository.dart';
import 'package:ai_physiognomy_app/features/auth/data/models/auth_models.dart';

class EnhancedAuthProvider extends BaseProvider {
  final EnhancedAuthRepository _authRepository;

  EnhancedAuthProvider({
    EnhancedAuthRepository? authRepository,
  }) : _authRepository = authRepository ?? EnhancedAuthRepository() {
    // Initialize auth state when provider is created
    _initializeOnCreate();
  }

  /// Initialize auth state when provider is created (only once)
  void _initializeOnCreate() {
    if (!_hasInitialized) {
      _hasInitialized = true;
      // Use Future.microtask to avoid calling during constructor
      Future.microtask(() => initializeAuth());
    }
  }

  // Authentication state
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _hasInitialized = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasInitialized => _hasInitialized;
  String get userDisplayName => _currentUser?.fullName ?? 'User';
  String? get userEmail => _currentUser?.email;
  String? get userAvatar => _currentUser?.avatar;

  /// Initialize authentication state
  Future<void> initializeAuth() async {
    await executeApiOperation(
      () async {
        AppLogger.info('EnhancedAuthProvider: Initializing authentication state');
        
        // Check if user is logged in
        final isLoggedIn = await _authRepository.isLoggedIn();
        
        if (isLoggedIn) {
          // Try to get stored user data first
          final storedUser = await _authRepository.getStoredUser();
          
          if (storedUser != null) {
            _currentUser = storedUser;
            _isAuthenticated = true;
            AppLogger.info('EnhancedAuthProvider: Loaded stored user data');
          } else {
            // Try to get current user from API
            try {
              _currentUser = await _authRepository.getCurrentUser();
              _isAuthenticated = true;
              AppLogger.info('EnhancedAuthProvider: Loaded user data from API');
            } catch (e) {
              AppLogger.warning('EnhancedAuthProvider: Failed to load user from API: $e');

              // Try to refresh token if it's an auth error
              if (e.toString().contains('401') || e.toString().contains('UNAUTHORIZED')) {
                AppLogger.info('EnhancedAuthProvider: Attempting token refresh');
                try {
                  await _authRepository.refreshToken();
                  // Retry getting current user after refresh
                  _currentUser = await _authRepository.getCurrentUser();
                  _isAuthenticated = true;
                  AppLogger.info('EnhancedAuthProvider: Successfully refreshed token and loaded user');
                } catch (refreshError) {
                  AppLogger.warning('EnhancedAuthProvider: Token refresh failed, clearing auth state');
                  await _clearAuthState();
                }
              } else {
                await _clearAuthState();
              }
            }
          }
        } else {
          await _clearAuthState();
        }

        AppLogger.info('EnhancedAuthProvider: Authentication state initialized');
        return Success(_isAuthenticated);
      },
      operationName: 'initialize_auth',
    );
  }

  /// Register new user
  Future<void> register({
    String? username,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required double age,
    required Gender gender,
    String? avatar,
  }) async {
    await executeApiOperation(
      () async {
        AppLogger.info('EnhancedAuthProvider: Registering new user');
        
        final createUserDto = CreateUserDTO(
          username: username,
          password: password,
          confirmPassword: confirmPassword,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          age: age,
          gender: gender,
          avatar: avatar,
        );
        
        final authResponse = await _authRepository.register(createUserDto);

        // Get user data after successful registration
        _currentUser = await _authRepository.getCurrentUser();
        _isAuthenticated = true;

        AppLogger.info('EnhancedAuthProvider: User registered successfully');
        return Success(authResponse);
      },
      operationName: 'register',
    );
  }

  /// Login user
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final result = await executeApiOperation(
      () async {
        AppLogger.info('EnhancedAuthProvider: Logging in user');

        final authRequest = AuthRequest(
          username: username,
          password: password,
        );

        final authResponse = await _authRepository.login(authRequest);

        // Get user data after successful login
        _currentUser = await _authRepository.getCurrentUser();
        _isAuthenticated = true;

        AppLogger.info('EnhancedAuthProvider: User logged in successfully');
        return Success(authResponse);
      },
      operationName: 'login',
    );

    return result != null;
  }

  /// Login with Google
  Future<void> loginWithGoogle() async {
    await executeApiOperation(
      () async {
        AppLogger.info('EnhancedAuthProvider: Starting Google Sign-In');
        
        final authResponse = await _authRepository.loginWithGoogle();

        // Get user data after successful Google login
        _currentUser = await _authRepository.getCurrentUser();
        _isAuthenticated = true;

        AppLogger.info('EnhancedAuthProvider: Google Sign-In completed successfully');
        return Success(authResponse);
      },
      operationName: 'google_login',
    );
  }

  /// Update user profile
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required double age,
    required Gender gender,
    String? avatar,
  }) async {
    await executeApiOperation(
      () async {
        AppLogger.info('EnhancedAuthProvider: Updating user profile');
        
        final updateUserDto = UpdateUserDTO(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          age: age,
          gender: gender,
          avatar: avatar,
        );
        
        final updatedUser = await _authRepository.updateProfile(updateUserDto);
        
        _currentUser = updatedUser;
        
        AppLogger.info('EnhancedAuthProvider: Profile updated successfully');
        return Success(updatedUser);
      },
      operationName: 'update_profile',
    );
  }

  /// Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await executeApiOperation(
      () async {
        AppLogger.info('EnhancedAuthProvider: Changing password');
        
        final changePasswordDto = ChangePasswordDTO(
          oldPassword: oldPassword,
          password: newPassword,
        );
        
        await _authRepository.changePassword(changePasswordDto);
        
        AppLogger.info('EnhancedAuthProvider: Password changed successfully');
        return Success(true);
      },
      operationName: 'change_password',
    );
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    await executeApiOperation(
      () async {
        AppLogger.info('EnhancedAuthProvider: Requesting password reset');
        
        await _authRepository.requestPasswordReset(email);
        
        AppLogger.info('EnhancedAuthProvider: Password reset requested successfully');
        return Success(true);
      },
      operationName: 'request_password_reset',
    );
  }

  /// Reset password with token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await executeApiOperation(
      () async {
        AppLogger.info('EnhancedAuthProvider: Resetting password');
        
        await _authRepository.resetPassword(token, newPassword);
        
        AppLogger.info('EnhancedAuthProvider: Password reset successfully');
        return Success(true);
      },
      operationName: 'reset_password',
    );
  }

  /// Refresh current user data
  Future<void> refreshUserData() async {
    await executeApiOperation(
      () async {
        AppLogger.info('EnhancedAuthProvider: Refreshing user data');
        
        final user = await _authRepository.getCurrentUser();
        
        _currentUser = user;
        
        AppLogger.info('EnhancedAuthProvider: User data refreshed successfully');
        return Success(user);
      },
      operationName: 'refresh_user_data',
    );
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      AppLogger.info('EnhancedAuthProvider: Manually refreshing token');

      final authResponse = await _authRepository.refreshToken();

      // Get updated user data after token refresh
      _currentUser = await _authRepository.getCurrentUser();
      _isAuthenticated = true;

      notifyListeners();
      AppLogger.info('EnhancedAuthProvider: Token refreshed successfully');
      return true;
    } catch (e) {
      AppLogger.error('EnhancedAuthProvider: Manual token refresh failed', e);
      await _clearAuthState();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await executeApiOperation(
      () async {
        AppLogger.info('EnhancedAuthProvider: Logging out user');

        await _authRepository.logout();

        await _clearAuthState();

        AppLogger.info('EnhancedAuthProvider: User logged out successfully');
        return Success(true);
      },
      operationName: 'logout',
    );
  }

  /// Silent Google Sign-In (for auto-login)
  Future<bool> silentGoogleSignIn() async {
    try {
      AppLogger.info('EnhancedAuthProvider: Attempting silent Google Sign-In');
      
      final authResponse = await _authRepository.silentGoogleSignIn();
      
      if (authResponse != null) {
        // Get user data after successful silent login
        _currentUser = await _authRepository.getCurrentUser();
        _isAuthenticated = true;
        notifyListeners();

        AppLogger.info('EnhancedAuthProvider: Silent Google Sign-In successful');
        return true;
      } else {
        AppLogger.info('EnhancedAuthProvider: No previous Google Sign-In found');
        return false;
      }
    } catch (e) {
      AppLogger.warning('EnhancedAuthProvider: Silent Google Sign-In failed', e);
      return false;
    }
  }

  /// Check authentication status
  Future<bool> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      
      if (isLoggedIn && _currentUser == null) {
        // Try to load user data
        await initializeAuth();
      } else if (!isLoggedIn) {
        await _clearAuthState();
      }
      
      return _isAuthenticated;
    } catch (e) {
      AppLogger.error('EnhancedAuthProvider: Failed to check auth status', e);
      await _clearAuthState();
      return false;
    }
  }

  /// Clear authentication state
  Future<void> _clearAuthState() async {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
    AppLogger.info('EnhancedAuthProvider: Authentication state cleared');
  }

  /// Get user ID
  int? get userId => _currentUser?.id;

  /// Check if user has complete profile
  bool get hasCompleteProfile {
    if (_currentUser == null) return false;
    
    return _currentUser!.firstName.isNotEmpty &&
           _currentUser!.lastName.isNotEmpty &&
           _currentUser!.email.isNotEmpty &&
           (_currentUser!.phone?.isNotEmpty ?? false);
  }

  /// Get user initials for avatar
  String get userInitials {
    if (_currentUser == null) return 'U';
    
    final firstName = _currentUser!.firstName;
    final lastName = _currentUser!.lastName;
    
    if (firstName.isEmpty && lastName.isEmpty) return 'U';
    
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    
    return '$firstInitial$lastInitial';
  }
}
