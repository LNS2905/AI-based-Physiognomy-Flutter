// Enhanced Authentication Repository with new API integration
import 'dart:convert';
import 'package:ai_physiognomy_app/core/utils/logger.dart';
import 'package:ai_physiognomy_app/core/storage/secure_storage_service.dart';
import 'package:ai_physiognomy_app/core/storage/storage_service.dart';
import 'package:ai_physiognomy_app/core/constants/app_constants.dart';
import 'package:ai_physiognomy_app/features/auth/data/services/auth_api_service.dart';
import 'package:ai_physiognomy_app/features/auth/data/models/auth_models.dart';
import 'package:ai_physiognomy_app/core/services/google_sign_in_service.dart';
import 'package:ai_physiognomy_app/core/services/logout_service.dart';

class EnhancedAuthRepository {
  final AuthApiService _authApiService;
  final GoogleSignInService _googleSignInService;
  final SecureStorageService _secureStorage;

  EnhancedAuthRepository({
    AuthApiService? authApiService,
    GoogleSignInService? googleSignInService,
    SecureStorageService? secureStorage,
  })  : _authApiService = authApiService ?? AuthApiService(),
        _googleSignInService = googleSignInService ?? GoogleSignInService(),
        _secureStorage = secureStorage ?? SecureStorageService();

  /// Register new user
  Future<AuthResponse> register(CreateUserDTO createUserDto) async {
    try {
      AppLogger.info('EnhancedAuthRepository: Registering new user');
      
      final authResponse = await _authApiService.register(createUserDto);
      
      // Store tokens securely
      await _storeAuthTokens(authResponse);
      
      AppLogger.info('EnhancedAuthRepository: User registered successfully');
      return authResponse;
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Registration failed', e);
      rethrow;
    }
  }

  /// Login user
  Future<AuthResponse> login(AuthRequest authRequest) async {
    try {
      AppLogger.info('EnhancedAuthRepository: Logging in user');
      
      final authResponse = await _authApiService.login(authRequest);
      
      // Store tokens securely
      await _storeAuthTokens(authResponse);
      
      AppLogger.info('EnhancedAuthRepository: User logged in successfully');
      return authResponse;
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Login failed', e);
      rethrow;
    }
  }

  /// Login with Google
  Future<AuthResponse> loginWithGoogle() async {
    try {
      AppLogger.info('EnhancedAuthRepository: Starting Google Sign-In');
      
      // Get Google ID token
      final googleResult = await _googleSignInService.signInWithGoogle();
      final idToken = googleResult.idToken;
      
      if (idToken == null) {
        throw Exception('Failed to get Google ID token');
      }
      
      // Send to backend
      final googleRequest = GoogleLoginRequest(token: idToken);
      final authResponse = await _authApiService.loginWithGoogle(googleRequest);
      
      // Store tokens securely
      await _storeAuthTokens(authResponse);
      
      AppLogger.info('EnhancedAuthRepository: Google Sign-In completed successfully');
      return authResponse;
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Google Sign-In failed', e);
      rethrow;
    }
  }

  /// Get current user
  Future<User> getCurrentUser() async {
    try {
      AppLogger.info('EnhancedAuthRepository: Getting current user');
      
      final user = await _authApiService.getCurrentUser();
      
      // Update stored user data
      await StorageService.store(AppConstants.userDataKey, user.toJson());
      
      AppLogger.info('EnhancedAuthRepository: Current user retrieved successfully');
      return user;
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Get current user failed', e);
      rethrow;
    }
  }

  /// Update user profile
  Future<User> updateProfile(UpdateUserDTO updateUserDto) async {
    try {
      AppLogger.info('EnhancedAuthRepository: Updating user profile');
      
      final user = await _authApiService.updateProfile(updateUserDto);
      
      // Update stored user data
      await StorageService.store(AppConstants.userDataKey, user.toJson());
      
      AppLogger.info('EnhancedAuthRepository: Profile updated successfully');
      return user;
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Update profile failed', e);
      rethrow;
    }
  }

  /// Change password
  Future<void> changePassword(ChangePasswordDTO changePasswordDto) async {
    try {
      AppLogger.info('EnhancedAuthRepository: Changing password');
      
      await _authApiService.changePassword(changePasswordDto);
      
      AppLogger.info('EnhancedAuthRepository: Password changed successfully');
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Change password failed', e);
      rethrow;
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    try {
      AppLogger.info('EnhancedAuthRepository: Requesting password reset');
      
      final requestDto = RequestResetPasswordDTO(email: email);
      await _authApiService.requestPasswordReset(requestDto);
      
      AppLogger.info('EnhancedAuthRepository: Password reset requested successfully');
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Request password reset failed', e);
      rethrow;
    }
  }

  /// Reset password with token
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      AppLogger.info('EnhancedAuthRepository: Resetting password');
      
      final resetDto = ResetPasswordDTO(password: newPassword);
      await _authApiService.resetPassword(token, resetDto);
      
      AppLogger.info('EnhancedAuthRepository: Password reset successfully');
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Reset password failed', e);
      rethrow;
    }
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken() async {
    try {
      AppLogger.info('EnhancedAuthRepository: Refreshing token');
      
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }
      
      final refreshRequest = RefreshTokenRequest(refreshToken: refreshToken);
      final authResponse = await _authApiService.refreshToken(refreshRequest);
      
      // Store new tokens
      await _storeAuthTokens(authResponse);
      
      AppLogger.info('EnhancedAuthRepository: Token refreshed successfully');
      return authResponse;
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Refresh token failed', e);
      // Clear invalid tokens
      await _clearAuthTokens();
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      AppLogger.info('EnhancedAuthRepository: Logging out user');
      
      // Perform complete logout using LogoutService
      await LogoutService.performCompleteLogout();
      
      AppLogger.info('EnhancedAuthRepository: User logged out successfully');
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Logout failed', e);
      // Even if logout fails, try to clear local data
      try {
        await LogoutService.clearAuthDataOnly();
      } catch (clearError) {
        AppLogger.error('EnhancedAuthRepository: Failed to clear auth data during logout error', clearError);
      }
      rethrow;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await _secureStorage.getAccessToken();
      return accessToken != null;
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Failed to check login status', e);
      return false;
    }
  }

  /// Get stored user data
  Future<User?> getStoredUser() async {
    try {
      final userData = await StorageService.get(AppConstants.userDataKey);
      if (userData != null) {
        // Handle both String and Map cases
        Map<String, dynamic> userMap;

        if (userData is String) {
          // Parse JSON string to Map
          userMap = jsonDecode(userData);
        } else if (userData is Map<String, dynamic>) {
          userMap = userData;
        } else {
          AppLogger.warning('EnhancedAuthRepository: Invalid user data format: ${userData.runtimeType}');
          return null;
        }

        // Normalize data types to handle inconsistencies
        userMap = _normalizeUserData(userMap);

        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Failed to get stored user', e);
      // Clear corrupted data
      try {
        await StorageService.remove(AppConstants.userDataKey);
        AppLogger.info('EnhancedAuthRepository: Cleared corrupted user data');
      } catch (clearError) {
        AppLogger.error('EnhancedAuthRepository: Failed to clear corrupted data', clearError);
      }
      return null;
    }
  }

  /// Normalize user data to handle type inconsistencies
  Map<String, dynamic> _normalizeUserData(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);

    AppLogger.info('EnhancedAuthRepository: Normalizing user data: ${data.keys.toList()}');

    // Handle id field - convert string to int if needed
    if (normalized['id'] != null) {
      if (normalized['id'] is String) {
        try {
          normalized['id'] = int.parse(normalized['id']);
          AppLogger.info('EnhancedAuthRepository: Converted id from string to int: ${normalized['id']}');
        } catch (e) {
          AppLogger.warning('EnhancedAuthRepository: Failed to parse id as int: ${normalized['id']}, error: $e');
          // Try to extract numeric part if it's a mixed string
          final idStr = normalized['id'] as String;
          final numericPart = RegExp(r'\d+').firstMatch(idStr)?.group(0);
          if (numericPart != null) {
            try {
              normalized['id'] = int.parse(numericPart);
              AppLogger.info('EnhancedAuthRepository: Extracted numeric id: ${normalized['id']}');
            } catch (e2) {
              AppLogger.error('EnhancedAuthRepository: Failed to extract numeric id', e2);
              normalized['id'] = 0; // Default fallback
            }
          } else {
            normalized['id'] = 0; // Default fallback
          }
        }
      } else if (normalized['id'] is double) {
        normalized['id'] = (normalized['id'] as double).toInt();
      }
    }

    // Handle age field - ensure it's a double
    if (normalized['age'] != null) {
      if (normalized['age'] is String) {
        try {
          normalized['age'] = double.parse(normalized['age']);
          AppLogger.info('EnhancedAuthRepository: Converted age from string to double: ${normalized['age']}');
        } catch (e) {
          AppLogger.warning('EnhancedAuthRepository: Failed to parse age as double: ${normalized['age']}, error: $e');
          normalized['age'] = 0.0; // Default value
        }
      } else if (normalized['age'] is int) {
        normalized['age'] = (normalized['age'] as int).toDouble();
      }
    } else {
      normalized['age'] = 0.0; // Default if null
    }

    // Handle string fields that should remain strings
    final stringFields = ['phone', 'firstName', 'lastName', 'email', 'username', 'avatar'];
    for (final field in stringFields) {
      if (normalized[field] != null && normalized[field] is! String) {
        normalized[field] = normalized[field].toString();
      }
    }

    // Handle gender field
    if (normalized['gender'] != null && normalized['gender'] is String) {
      final genderStr = (normalized['gender'] as String).toLowerCase();
      if (!['male', 'female'].contains(genderStr)) {
        AppLogger.warning('EnhancedAuthRepository: Invalid gender value: ${normalized['gender']}, defaulting to male');
        normalized['gender'] = 'male';
      }
    } else if (normalized['gender'] == null) {
      normalized['gender'] = 'male'; // Default
    }

    // Handle date fields
    final dateFields = ['createdAt', 'updatedAt'];
    for (final field in dateFields) {
      if (normalized[field] is String && normalized[field] != null) {
        try {
          // Validate that it's a proper date string
          DateTime.parse(normalized[field]);
          // Keep as ISO string for JSON serialization
        } catch (e) {
          AppLogger.warning('EnhancedAuthRepository: Failed to parse date field $field: ${normalized[field]}, error: $e');
          normalized[field] = null;
        }
      }
    }

    AppLogger.info('EnhancedAuthRepository: Normalized user data successfully');
    return normalized;
  }

  /// Store authentication tokens
  Future<void> _storeAuthTokens(AuthResponse authResponse) async {
    try {
      await _secureStorage.storeAccessToken(authResponse.accessToken);
      await _secureStorage.storeRefreshToken(authResponse.refreshToken);
      // Note: AuthResponse doesn't contain user data, store tokens only
      // User data should be fetched separately using getCurrentUser()
      
      AppLogger.info('EnhancedAuthRepository: Auth tokens stored successfully');
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Failed to store auth tokens', e);
      rethrow;
    }
  }

  /// Clear authentication tokens
  Future<void> _clearAuthTokens() async {
    try {
      await _secureStorage.clearAccessToken();
      await _secureStorage.clearRefreshToken();
      await StorageService.remove(AppConstants.userDataKey);
      
      AppLogger.info('EnhancedAuthRepository: Auth tokens cleared successfully');
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Failed to clear auth tokens', e);
    }
  }

  /// Silent Google Sign-In (for auto-login)
  Future<AuthResponse?> silentGoogleSignIn() async {
    try {
      AppLogger.info('EnhancedAuthRepository: Attempting silent Google Sign-In');
      
      final googleResult = await _googleSignInService.silentSignIn();
      
      if (googleResult == null) {
        AppLogger.info('EnhancedAuthRepository: No previous Google Sign-In found');
        return null;
      }
      
      final idToken = googleResult.idToken;
      if (idToken == null) {
        AppLogger.warning('EnhancedAuthRepository: No ID token from silent sign-in');
        return null;
      }
      
      // Authenticate with backend
      final googleRequest = GoogleLoginRequest(token: idToken);
      final authResponse = await _authApiService.loginWithGoogle(googleRequest);
      
      // Store tokens securely
      await _storeAuthTokens(authResponse);
      
      AppLogger.info('EnhancedAuthRepository: Silent Google Sign-In completed successfully');
      return authResponse;
    } catch (e) {
      AppLogger.warning('EnhancedAuthRepository: Silent Google Sign-In failed', e);
      return null;
    }
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignInService.signOut();
      AppLogger.info('EnhancedAuthRepository: Google Sign-Out completed');
    } catch (e) {
      AppLogger.error('EnhancedAuthRepository: Google Sign-Out failed', e);
      rethrow;
    }
  }
}
