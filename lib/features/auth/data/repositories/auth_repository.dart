import '../../../../core/network/api_result.dart';
import '../../../../core/network/http_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Authentication repository
class AuthRepository {
  final HttpService _httpService;

  AuthRepository({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  /// Login with email and password
  Future<ApiResult<AuthResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpService.post(
        'auth/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response);
      
      // Store tokens securely
      await _storeAuthTokens(authResponse);
      
      AppLogger.info('User logged in successfully');
      return Success(authResponse);
    } on AuthException catch (e) {
      AppLogger.error('Login failed: Authentication error', e);
      return Error(AuthFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      AppLogger.error('Login failed: Network error', e);
      return Error(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      AppLogger.error('Login failed: Server error', e);
      return Error(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        code: e.code,
      ));
    } catch (e) {
      AppLogger.error('Login failed: Unknown error', e);
      return Error(UnknownFailure(
        message: 'An unexpected error occurred during login',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  /// Register new user
  Future<ApiResult<AuthResponseModel>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _httpService.post(
        'auth/register',
        body: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response);
      
      // Store tokens securely
      await _storeAuthTokens(authResponse);
      
      AppLogger.info('User registered successfully');
      return Success(authResponse);
    } on ValidationException catch (e) {
      AppLogger.error('Registration failed: Validation error', e);
      return Error(ValidationFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      AppLogger.error('Registration failed: Network error', e);
      return Error(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      AppLogger.error('Registration failed: Server error', e);
      return Error(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        code: e.code,
      ));
    } catch (e) {
      AppLogger.error('Registration failed: Unknown error', e);
      return Error(UnknownFailure(
        message: 'An unexpected error occurred during registration',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  /// Logout user
  Future<ApiResult<void>> logout() async {
    try {
      // Call logout endpoint if needed
      // await _httpService.post('auth/logout');
      
      // Clear stored tokens
      await _clearAuthTokens();
      
      AppLogger.info('User logged out successfully');
      return const Success(null);
    } catch (e) {
      AppLogger.error('Logout failed', e);
      // Even if logout fails, clear local tokens
      await _clearAuthTokens();
      return Error(UnknownFailure(
        message: 'Logout completed with errors',
        code: 'LOGOUT_ERROR',
      ));
    }
  }

  /// Refresh access token
  Future<ApiResult<AuthResponseModel>> refreshToken() async {
    try {
      final refreshToken = await StorageService.getSecure(AppConstants.refreshTokenKey);
      if (refreshToken == null) {
        throw const AuthException(
          message: 'No refresh token found',
          code: 'NO_REFRESH_TOKEN',
        );
      }

      final response = await _httpService.post(
        'auth/refresh',
        body: {
          'refreshToken': refreshToken,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response);
      
      // Store new tokens
      await _storeAuthTokens(authResponse);
      
      AppLogger.info('Token refreshed successfully');
      return Success(authResponse);
    } on AuthException catch (e) {
      AppLogger.error('Token refresh failed: Authentication error', e);
      await _clearAuthTokens(); // Clear invalid tokens
      return Error(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      AppLogger.error('Token refresh failed', e);
      await _clearAuthTokens(); // Clear potentially invalid tokens
      return Error(UnknownFailure(
        message: 'Failed to refresh token',
        code: 'REFRESH_ERROR',
      ));
    }
  }

  /// Get current user
  Future<ApiResult<UserModel>> getCurrentUser() async {
    try {
      final accessToken = await StorageService.getSecure(AppConstants.accessTokenKey);
      if (accessToken == null) {
        throw const AuthException(
          message: 'No access token found',
          code: 'NO_ACCESS_TOKEN',
        );
      }

      final response = await _httpService.get(
        'auth/me',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      final user = UserModel.fromJson(response);
      AppLogger.info('Current user retrieved successfully');
      return Success(user);
    } on AuthException catch (e) {
      AppLogger.error('Get current user failed: Authentication error', e);
      return Error(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      AppLogger.error('Get current user failed', e);
      return Error(UnknownFailure(
        message: 'Failed to get current user',
        code: 'GET_USER_ERROR',
      ));
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await StorageService.getSecure(AppConstants.accessTokenKey);
      return accessToken != null;
    } catch (e) {
      AppLogger.error('Failed to check login status', e);
      return false;
    }
  }

  /// Store authentication tokens
  Future<void> _storeAuthTokens(AuthResponseModel authResponse) async {
    await StorageService.storeSecure(
      AppConstants.accessTokenKey,
      authResponse.accessToken,
    );
    await StorageService.storeSecure(
      AppConstants.refreshTokenKey,
      authResponse.refreshToken,
    );
    await StorageService.store(
      AppConstants.userDataKey,
      authResponse.user.toJson(),
    );
  }

  /// Clear authentication tokens
  Future<void> _clearAuthTokens() async {
    await StorageService.removeSecure(AppConstants.accessTokenKey);
    await StorageService.removeSecure(AppConstants.refreshTokenKey);
    await StorageService.remove(AppConstants.userDataKey);
  }
}
