// New API Service for Backend Integration
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_physiognomy_app/core/config/api_config.dart';
import 'package:ai_physiognomy_app/core/utils/logger.dart';
import 'package:ai_physiognomy_app/core/storage/secure_storage_service.dart';
import 'package:ai_physiognomy_app/features/auth/data/models/auth_models.dart';

class NewApiService {
  static const String _baseUrl = ApiConfig.baseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();

  // Helper method to get authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method to handle API response
  Map<String, dynamic> _handleResponse(http.Response response, String operation) {
    AppLogger.info('NewApiService: $operation response status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseData = jsonDecode(response.body);
      // API uses 'OPERATION_SUCCESS' as success code
      if (responseData['code'] == 'OPERATION_SUCCESS') {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? '$operation failed');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '$operation failed');
    }
  }

  // ==================== AUTHENTICATION APIs ====================

  /// Register new user
  Future<RegisterResponse> register(CreateUserDTO createUserDto) async {
    try {
      AppLogger.info('NewApiService: Registering new user');

      final response = await http.post(
        Uri.parse('$_baseUrl/users/signUp'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(createUserDto.toJson()),
      );

      final responseData = _handleResponse(response, 'Register');
      final user = User.fromJson(responseData['data']);
      final registerResponse = RegisterResponse(user: user);

      AppLogger.info('NewApiService: User registered successfully');
      return registerResponse;
    } catch (e) {
      AppLogger.error('NewApiService: Registration error: $e');
      rethrow;
    }
  }

  /// Login user
  Future<AuthResponse> login(AuthRequest authRequest) async {
    try {
      AppLogger.info('NewApiService: Logging in user');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/user'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(authRequest.toJson()),
      );

      final responseData = _handleResponse(response, 'Login');
      final authResponse = AuthResponse.fromJson(responseData['data']);
      
      AppLogger.info('NewApiService: User logged in successfully');
      return authResponse;
    } catch (e) {
      AppLogger.error('NewApiService: Login error: $e');
      rethrow;
    }
  }

  /// Login with Google
  Future<AuthResponse> loginWithGoogle(GoogleLoginRequest googleRequest) async {
    try {
      AppLogger.info('NewApiService: Logging in with Google');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/google'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(googleRequest.toJson()),
      );

      final responseData = _handleResponse(response, 'Google Login');
      final authResponse = AuthResponse.fromJson(responseData['data']);
      
      AppLogger.info('NewApiService: Google login successful');
      return authResponse;
    } catch (e) {
      AppLogger.error('NewApiService: Google login error: $e');
      rethrow;
    }
  }

  /// Get current user info
  Future<User> getCurrentUser() async {
    try {
      AppLogger.info('NewApiService: Getting current user info');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: await _getAuthHeaders(),
      );

      final responseData = _handleResponse(response, 'Get Current User');
      final user = User.fromJson(responseData['data']);
      
      AppLogger.info('NewApiService: Current user info retrieved successfully');
      return user;
    } catch (e) {
      AppLogger.error('NewApiService: Get current user error: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<User> updateProfile(UpdateUserDTO updateUserDto) async {
    try {
      AppLogger.info('NewApiService: Updating user profile');
      
      final response = await http.put(
        Uri.parse('$_baseUrl/users/me'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(updateUserDto.toJson()),
      );

      final responseData = _handleResponse(response, 'Update Profile');
      final user = User.fromJson(responseData['data']);
      
      AppLogger.info('NewApiService: Profile updated successfully');
      return user;
    } catch (e) {
      AppLogger.error('NewApiService: Update profile error: $e');
      rethrow;
    }
  }

  /// Change password
  Future<void> changePassword(ChangePasswordDTO changePasswordDto) async {
    try {
      AppLogger.info('NewApiService: Changing password');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/me/change-password'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(changePasswordDto.toJson()),
      );

      _handleResponse(response, 'Change Password');
      AppLogger.info('NewApiService: Password changed successfully');
    } catch (e) {
      AppLogger.error('NewApiService: Change password error: $e');
      rethrow;
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset(RequestResetPasswordDTO requestDto) async {
    try {
      AppLogger.info('NewApiService: Requesting password reset');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/request-forgot-pass'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(requestDto.toJson()),
      );

      _handleResponse(response, 'Request Password Reset');
      AppLogger.info('NewApiService: Password reset requested successfully');
    } catch (e) {
      AppLogger.error('NewApiService: Request password reset error: $e');
      rethrow;
    }
  }

  /// Reset password with token
  Future<void> resetPassword(String token, ResetPasswordDTO resetDto) async {
    try {
      AppLogger.info('NewApiService: Resetting password');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-pass?token=$token'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(resetDto.toJson()),
      );

      _handleResponse(response, 'Reset Password');
      AppLogger.info('NewApiService: Password reset successfully');
    } catch (e) {
      AppLogger.error('NewApiService: Reset password error: $e');
      rethrow;
    }
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken(RefreshTokenRequest refreshRequest) async {
    try {
      AppLogger.info('NewApiService: Refreshing token');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh-token'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(refreshRequest.toJson()),
      );

      final responseData = _handleResponse(response, 'Refresh Token');
      final authResponse = AuthResponse.fromJson(responseData['data']);
      
      AppLogger.info('NewApiService: Token refreshed successfully');
      return authResponse;
    } catch (e) {
      AppLogger.error('NewApiService: Refresh token error: $e');
      rethrow;
    }
  }

  // ==================== FACIAL ANALYSIS APIs ====================

  /// Save facial analysis result
  Future<Map<String, dynamic>> saveFacialAnalysis(Map<String, dynamic> analysisData) async {
    try {
      AppLogger.info('NewApiService: Saving facial analysis');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/facial-analysis'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(analysisData),
      );

      final responseData = _handleResponse(response, 'Save Facial Analysis');
      AppLogger.info('NewApiService: Facial analysis saved successfully');
      return responseData['data'];
    } catch (e) {
      AppLogger.error('NewApiService: Save facial analysis error: $e');
      rethrow;
    }
  }

  /// Get facial analyses by user ID
  Future<List<Map<String, dynamic>>> getFacialAnalysesByUser(int userId) async {
    try {
      AppLogger.info('NewApiService: Getting facial analyses for user $userId');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/facial-analysis/user/$userId'),
        headers: await _getAuthHeaders(),
      );

      final responseData = _handleResponse(response, 'Get Facial Analyses');
      final List<dynamic> analysesJson = responseData['data'];
      
      AppLogger.info('NewApiService: Retrieved ${analysesJson.length} facial analyses');
      return analysesJson.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error('NewApiService: Get facial analyses error: $e');
      rethrow;
    }
  }

  /// Update facial analysis
  Future<Map<String, dynamic>> updateFacialAnalysis(int id, Map<String, dynamic> analysisData) async {
    try {
      AppLogger.info('NewApiService: Updating facial analysis $id');
      
      final response = await http.put(
        Uri.parse('$_baseUrl/facial-analysis/$id'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(analysisData),
      );

      final responseData = _handleResponse(response, 'Update Facial Analysis');
      AppLogger.info('NewApiService: Facial analysis updated successfully');
      return responseData['data'];
    } catch (e) {
      AppLogger.error('NewApiService: Update facial analysis error: $e');
      rethrow;
    }
  }

  /// Delete facial analysis
  Future<void> deleteFacialAnalysis(int id) async {
    try {
      AppLogger.info('NewApiService: Deleting facial analysis $id');
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/facial-analysis/$id'),
        headers: await _getAuthHeaders(),
      );

      _handleResponse(response, 'Delete Facial Analysis');
      AppLogger.info('NewApiService: Facial analysis deleted successfully');
    } catch (e) {
      AppLogger.error('NewApiService: Delete facial analysis error: $e');
      rethrow;
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Test API connection by trying to access a simple endpoint
  Future<bool> testConnection() async {
    try {
      AppLogger.info('NewApiService: Testing API connection');

      // Test with a simple POST request that should return 400 (invalid credentials)
      // This confirms the API is responding
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/user'),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({'username': 'test', 'password': 'test'}),
      ).timeout(const Duration(seconds: 10));

      // If we get 400 (bad request), it means API is working
      final isConnected = response.statusCode == 400 || response.statusCode == 200;
      AppLogger.info('NewApiService: API connection test ${isConnected ? 'successful' : 'failed'}');
      return isConnected;
    } catch (e) {
      AppLogger.error('NewApiService: API connection test failed: $e');
      return false;
    }
  }
}
