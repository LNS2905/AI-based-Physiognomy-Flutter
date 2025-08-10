// Authentication API Service
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_physiognomy_app/core/config/api_config.dart';
import 'package:ai_physiognomy_app/core/utils/logger.dart';
import 'package:ai_physiognomy_app/core/storage/secure_storage_service.dart';
import 'package:ai_physiognomy_app/features/auth/data/models/auth_models.dart';

class AuthApiService {
  static const String _baseUrl = ApiConfig.baseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Register new user
  Future<AuthResponse> register(CreateUserDTO createUserDto) async {
    AppLogger.info('AuthApiService: Registering new user');
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/signUp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(createUserDto.toJson()),
      );

      AppLogger.info('AuthApiService: Register response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          final authResponse = AuthResponse.fromJson(responseData['data']);
          AppLogger.info('AuthApiService: User registered successfully');
          return authResponse;
        } else {
          throw Exception(responseData['message'] ?? 'Registration failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      AppLogger.error('AuthApiService: Registration error: $e');
      rethrow;
    }
  }

  /// Login user
  Future<AuthResponse> login(AuthRequest authRequest) async {
    AppLogger.info('AuthApiService: Logging in user');
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(authRequest.toJson()),
      );

      AppLogger.info('AuthApiService: Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          final authResponse = AuthResponse.fromJson(responseData['data']);
          AppLogger.info('AuthApiService: User logged in successfully');
          return authResponse;
        } else {
          throw Exception(responseData['message'] ?? 'Login failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      AppLogger.error('AuthApiService: Login error: $e');
      rethrow;
    }
  }

  /// Login with Google
  Future<AuthResponse> loginWithGoogle(GoogleLoginRequest googleRequest) async {
    AppLogger.info('AuthApiService: Logging in with Google');
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/google'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(googleRequest.toJson()),
      );

      AppLogger.info('AuthApiService: Google login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          final authResponse = AuthResponse.fromJson(responseData['data']);
          AppLogger.info('AuthApiService: Google login successful');
          return authResponse;
        } else {
          throw Exception(responseData['message'] ?? 'Google login failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Google login failed');
      }
    } catch (e) {
      AppLogger.error('AuthApiService: Google login error: $e');
      rethrow;
    }
  }

  /// Get current user info
  Future<User> getCurrentUser() async {
    AppLogger.info('AuthApiService: Getting current user info');
    
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.info('AuthApiService: Get current user response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          final user = User.fromJson(responseData['data']);
          AppLogger.info('AuthApiService: Current user info retrieved successfully');
          return user;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to get user info');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get user info');
      }
    } catch (e) {
      AppLogger.error('AuthApiService: Get current user error: $e');
      rethrow;
    }
  }

  /// Update current user profile
  Future<User> updateProfile(UpdateUserDTO updateUserDto) async {
    AppLogger.info('AuthApiService: Updating user profile');
    
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateUserDto.toJson()),
      );

      AppLogger.info('AuthApiService: Update profile response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          final user = User.fromJson(responseData['data']);
          AppLogger.info('AuthApiService: Profile updated successfully');
          return user;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update profile');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      AppLogger.error('AuthApiService: Update profile error: $e');
      rethrow;
    }
  }

  /// Change password
  Future<void> changePassword(ChangePasswordDTO changePasswordDto) async {
    AppLogger.info('AuthApiService: Changing password');
    
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/me/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(changePasswordDto.toJson()),
      );

      AppLogger.info('AuthApiService: Change password response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          AppLogger.info('AuthApiService: Password changed successfully');
        } else {
          throw Exception(responseData['message'] ?? 'Failed to change password');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      AppLogger.error('AuthApiService: Change password error: $e');
      rethrow;
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset(RequestResetPasswordDTO requestDto) async {
    AppLogger.info('AuthApiService: Requesting password reset');
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/request-forgot-pass'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestDto.toJson()),
      );

      AppLogger.info('AuthApiService: Request password reset response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          AppLogger.info('AuthApiService: Password reset requested successfully');
        } else {
          throw Exception(responseData['message'] ?? 'Failed to request password reset');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to request password reset');
      }
    } catch (e) {
      AppLogger.error('AuthApiService: Request password reset error: $e');
      rethrow;
    }
  }

  /// Reset password with token
  Future<void> resetPassword(String token, ResetPasswordDTO resetDto) async {
    AppLogger.info('AuthApiService: Resetting password');
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-pass?token=$token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(resetDto.toJson()),
      );

      AppLogger.info('AuthApiService: Reset password response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          AppLogger.info('AuthApiService: Password reset successfully');
        } else {
          throw Exception(responseData['message'] ?? 'Failed to reset password');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      AppLogger.error('AuthApiService: Reset password error: $e');
      rethrow;
    }
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken(RefreshTokenRequest refreshRequest) async {
    AppLogger.info('AuthApiService: Refreshing token');
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(refreshRequest.toJson()),
      );

      AppLogger.info('AuthApiService: Refresh token response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          final authResponse = AuthResponse.fromJson(responseData['data']);
          AppLogger.info('AuthApiService: Token refreshed successfully');
          return authResponse;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to refresh token');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to refresh token');
      }
    } catch (e) {
      AppLogger.error('AuthApiService: Refresh token error: $e');
      rethrow;
    }
  }
}
