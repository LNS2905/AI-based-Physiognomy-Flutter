// New Authentication Manager for Backend Integration
import 'package:ai_physiognomy_app/core/utils/logger.dart';
import 'package:ai_physiognomy_app/core/storage/secure_storage_service.dart';
import 'package:ai_physiognomy_app/core/storage/storage_service.dart';
import 'package:ai_physiognomy_app/core/constants/app_constants.dart';
import 'package:ai_physiognomy_app/core/services/new_api_service.dart';
import 'package:ai_physiognomy_app/core/services/google_sign_in_service.dart';
import 'package:ai_physiognomy_app/features/auth/data/models/auth_models.dart';

class NewAuthManager {
  static final NewAuthManager _instance = NewAuthManager._internal();
  factory NewAuthManager() => _instance;
  NewAuthManager._internal();

  final NewApiService _apiService = NewApiService();
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  final SecureStorageService _secureStorage = SecureStorageService();

  User? _currentUser;
  bool _isAuthenticated = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  String get userDisplayName => _currentUser?.fullName ?? 'User';
  String? get userEmail => _currentUser?.email;
  int? get userId => _currentUser?.id;

  /// Initialize authentication state
  Future<bool> initialize() async {
    try {
      AppLogger.info('NewAuthManager: Initializing authentication state');
      
      // Check if user has stored tokens
      final accessToken = await _secureStorage.getAccessToken();
      
      if (accessToken != null) {
        // Try to get current user from API
        try {
          _currentUser = await _apiService.getCurrentUser();
          _isAuthenticated = true;
          
          // Update stored user data
          await StorageService.store(AppConstants.userDataKey, _currentUser!.toJson());
          
          AppLogger.info('NewAuthManager: User authenticated from stored token');
          return true;
        } catch (e) {
          AppLogger.warning('NewAuthManager: Failed to authenticate with stored token, clearing auth state');
          await _clearAuthState();
          return false;
        }
      } else {
        // Try to get stored user data
        final userData = await StorageService.get(AppConstants.userDataKey);
        if (userData != null) {
          _currentUser = User.fromJson(userData);
          AppLogger.info('NewAuthManager: Loaded user data from storage (offline mode)');
        }
        
        _isAuthenticated = false;
        return false;
      }
    } catch (e) {
      AppLogger.error('NewAuthManager: Initialization failed', e);
      await _clearAuthState();
      return false;
    }
  }

  /// Register new user
  Future<RegisterResponse> register({
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
    try {
      AppLogger.info('NewAuthManager: Registering new user');

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

      final registerResponse = await _apiService.register(createUserDto);

      // Store user data (no tokens from register)
      _currentUser = registerResponse.user;
      await StorageService.store(AppConstants.userDataKey, registerResponse.user.toJson());

      AppLogger.info('NewAuthManager: User registered successfully');
      return registerResponse;
    } catch (e) {
      AppLogger.error('NewAuthManager: Registration failed', e);
      rethrow;
    }
  }

  /// Login user
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      AppLogger.info('NewAuthManager: Logging in user');

      final authRequest = AuthRequest(
        username: username,
        password: password,
      );

      final authResponse = await _apiService.login(authRequest);

      // Store tokens
      await _secureStorage.storeAccessToken(authResponse.accessToken);
      await _secureStorage.storeRefreshToken(authResponse.refreshToken);

      // Get user data separately
      final user = await _apiService.getCurrentUser();
      _currentUser = user;
      _isAuthenticated = true;

      // Store user data
      await StorageService.store(AppConstants.userDataKey, user.toJson());

      AppLogger.info('NewAuthManager: User logged in successfully');
      return authResponse;
    } catch (e) {
      AppLogger.error('NewAuthManager: Login failed', e);
      rethrow;
    }
  }

  /// Login with Google
  Future<AuthResponse> loginWithGoogle() async {
    try {
      AppLogger.info('NewAuthManager: Starting Google Sign-In');
      
      // Get Google ID token
      final googleResult = await _googleSignInService.signInWithGoogle();
      final idToken = googleResult.idToken;
      
      if (idToken == null) {
        throw Exception('Failed to get Google ID token');
      }
      
      // Send to backend
      final googleRequest = GoogleLoginRequest(token: idToken);
      final authResponse = await _apiService.loginWithGoogle(googleRequest);

      // Store tokens
      await _secureStorage.storeAccessToken(authResponse.accessToken);
      await _secureStorage.storeRefreshToken(authResponse.refreshToken);

      // Get user data separately
      final user = await _apiService.getCurrentUser();
      _currentUser = user;
      _isAuthenticated = true;

      // Store user data
      await StorageService.store(AppConstants.userDataKey, user.toJson());

      AppLogger.info('NewAuthManager: Google Sign-In completed successfully');
      return authResponse;
    } catch (e) {
      AppLogger.error('NewAuthManager: Google Sign-In failed', e);
      rethrow;
    }
  }

  /// Update user profile
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required double age,
    required Gender gender,
    String? avatar,
  }) async {
    try {
      AppLogger.info('NewAuthManager: Updating user profile');
      
      final updateUserDto = UpdateUserDTO(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        age: age,
        gender: gender,
        avatar: avatar,
      );
      
      final updatedUser = await _apiService.updateProfile(updateUserDto);
      
      // Update local user data
      _currentUser = updatedUser;
      await StorageService.store(AppConstants.userDataKey, updatedUser.toJson());
      
      AppLogger.info('NewAuthManager: Profile updated successfully');
      return updatedUser;
    } catch (e) {
      AppLogger.error('NewAuthManager: Update profile failed', e);
      rethrow;
    }
  }

  /// Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      AppLogger.info('NewAuthManager: Changing password');
      
      final changePasswordDto = ChangePasswordDTO(
        oldPassword: oldPassword,
        password: newPassword,
      );
      
      await _apiService.changePassword(changePasswordDto);
      
      AppLogger.info('NewAuthManager: Password changed successfully');
    } catch (e) {
      AppLogger.error('NewAuthManager: Change password failed', e);
      rethrow;
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    try {
      AppLogger.info('NewAuthManager: Requesting password reset');
      
      final requestDto = RequestResetPasswordDTO(email: email);
      await _apiService.requestPasswordReset(requestDto);
      
      AppLogger.info('NewAuthManager: Password reset requested successfully');
    } catch (e) {
      AppLogger.error('NewAuthManager: Request password reset failed', e);
      rethrow;
    }
  }

  /// Reset password with token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      AppLogger.info('NewAuthManager: Resetting password');
      
      final resetDto = ResetPasswordDTO(password: newPassword);
      await _apiService.resetPassword(token, resetDto);
      
      AppLogger.info('NewAuthManager: Password reset successfully');
    } catch (e) {
      AppLogger.error('NewAuthManager: Reset password failed', e);
      rethrow;
    }
  }

  /// Refresh user data
  Future<User> refreshUserData() async {
    try {
      AppLogger.info('NewAuthManager: Refreshing user data');
      
      final user = await _apiService.getCurrentUser();
      
      _currentUser = user;
      await StorageService.store(AppConstants.userDataKey, user.toJson());
      
      AppLogger.info('NewAuthManager: User data refreshed successfully');
      return user;
    } catch (e) {
      AppLogger.error('NewAuthManager: Refresh user data failed', e);
      rethrow;
    }
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken() async {
    try {
      AppLogger.info('NewAuthManager: Refreshing token');
      
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }
      
      final refreshRequest = RefreshTokenRequest(refreshToken: refreshToken);
      final authResponse = await _apiService.refreshToken(refreshRequest);
      
      // Store new tokens
      await _secureStorage.storeAccessToken(authResponse.accessToken);
      await _secureStorage.storeRefreshToken(authResponse.refreshToken);
      
      AppLogger.info('NewAuthManager: Token refreshed successfully');
      return authResponse;
    } catch (e) {
      AppLogger.error('NewAuthManager: Refresh token failed', e);
      // Clear invalid tokens
      await _clearAuthState();
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      AppLogger.info('NewAuthManager: Logging out user');
      
      // Sign out from Google if signed in
      try {
        await _googleSignInService.signOut();
      } catch (e) {
        AppLogger.warning('NewAuthManager: Google sign out failed', e);
      }
      
      // Clear authentication state
      await _clearAuthState();
      
      AppLogger.info('NewAuthManager: User logged out successfully');
    } catch (e) {
      AppLogger.error('NewAuthManager: Logout failed', e);
      // Even if logout fails, clear local data
      await _clearAuthState();
      rethrow;
    }
  }

  /// Silent Google Sign-In (for auto-login)
  Future<bool> silentGoogleSignIn() async {
    try {
      AppLogger.info('NewAuthManager: Attempting silent Google Sign-In');
      
      final googleResult = await _googleSignInService.silentSignIn();
      
      if (googleResult == null) {
        AppLogger.info('NewAuthManager: No previous Google Sign-In found');
        return false;
      }
      
      final idToken = googleResult.idToken;
      if (idToken == null) {
        AppLogger.warning('NewAuthManager: No ID token from silent sign-in');
        return false;
      }
      
      // Authenticate with backend
      final googleRequest = GoogleLoginRequest(token: idToken);
      final authResponse = await _apiService.loginWithGoogle(googleRequest);

      // Store tokens
      await _secureStorage.storeAccessToken(authResponse.accessToken);
      await _secureStorage.storeRefreshToken(authResponse.refreshToken);

      // Get user data separately
      final user = await _apiService.getCurrentUser();
      _currentUser = user;
      _isAuthenticated = true;

      // Store user data
      await StorageService.store(AppConstants.userDataKey, user.toJson());

      AppLogger.info('NewAuthManager: Silent Google Sign-In completed successfully');
      return true;
    } catch (e) {
      AppLogger.warning('NewAuthManager: Silent Google Sign-In failed', e);
      return false;
    }
  }



  /// Clear authentication state
  Future<void> _clearAuthState() async {
    try {
      await _secureStorage.clearAccessToken();
      await _secureStorage.clearRefreshToken();
      await StorageService.remove(AppConstants.userDataKey);
      
      _currentUser = null;
      _isAuthenticated = false;
      
      AppLogger.info('NewAuthManager: Auth state cleared successfully');
    } catch (e) {
      AppLogger.error('NewAuthManager: Failed to clear auth state', e);
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await _secureStorage.getAccessToken();
      return accessToken != null;
    } catch (e) {
      AppLogger.error('NewAuthManager: Failed to check login status', e);
      return false;
    }
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

  /// Check if user has complete profile
  bool get hasCompleteProfile {
    if (_currentUser == null) return false;
    
    return _currentUser!.firstName.isNotEmpty &&
           _currentUser!.lastName.isNotEmpty &&
           _currentUser!.email.isNotEmpty &&
           _currentUser!.phone.isNotEmpty;
  }
}
