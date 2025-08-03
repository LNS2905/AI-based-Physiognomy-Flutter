import '../../../../core/network/api_result.dart';
import '../../../../core/network/http_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../models/auth_request_model.dart';
import '../models/create_user_dto.dart';
import '../models/google_login_request.dart';
import '../models/general_response_model.dart';

/// Authentication repository
class AuthRepository {
  final HttpService _httpService;

  AuthRepository({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  /// Login with username and password
  Future<ApiResult<AuthResponseModel>> login({
    required String username,
    required String password,
  }) async {
    try {
      final authRequest = AuthRequest(
        username: username,
        password: password,
      );

      final response = await _httpService.post(
        AppConstants.loginEndpoint,
        body: authRequest.toJson(),
      );

      final generalResponse = GeneralResponse<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      final authResponse = AuthResponseModel.fromJson(generalResponse.data);

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
        message: 'Đã xảy ra lỗi không mong muốn trong quá trình đăng nhập',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  /// Sign up new user
  Future<ApiResult<AuthResponseModel>> signup({
    required CreateUserDTO createUserDto,
  }) async {
    try {
      final response = await _httpService.post(
        AppConstants.signupEndpoint,
        body: createUserDto.toJson(),
      );

      final generalResponse = GeneralResponse<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      final authResponse = AuthResponseModel.fromJson(generalResponse.data);

      // Store tokens securely
      await _storeAuthTokens(authResponse);

      AppLogger.info('User signed up successfully');
      return Success(authResponse);
    } on ValidationException catch (e) {
      AppLogger.error('Signup failed: Validation error', e);
      return Error(ValidationFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      AppLogger.error('Signup failed: Network error', e);
      return Error(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      AppLogger.error('Signup failed: Server error', e);
      return Error(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        code: e.code,
      ));
    } catch (e) {
      AppLogger.error('Signup failed: Unknown error', e);
      return Error(UnknownFailure(
        message: 'Đã xảy ra lỗi không mong muốn trong quá trình đăng ký',
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
        message: 'Đăng xuất hoàn tất với lỗi',
        code: 'LOGOUT_ERROR',
      ));
    }
  }

  /// Login with Google
  Future<ApiResult<AuthResponseModel>> loginWithGoogle({
    required String googleToken,
  }) async {
    try {
      final googleLoginRequest = GoogleLoginRequest(token: googleToken);

      final response = await _httpService.post(
        AppConstants.googleLoginEndpoint,
        body: googleLoginRequest.toJson(),
      );

      final generalResponse = GeneralResponse<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      final authResponse = AuthResponseModel.fromJson(generalResponse.data);

      // Store tokens securely
      await _storeAuthTokens(authResponse);

      AppLogger.info('User logged in with Google successfully');
      return Success(authResponse);
    } on AuthException catch (e) {
      AppLogger.error('Google login failed: Authentication error', e);
      return Error(AuthFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      AppLogger.error('Google login failed: Network error', e);
      return Error(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      AppLogger.error('Google login failed: Server error', e);
      return Error(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        code: e.code,
      ));
    } catch (e) {
      AppLogger.error('Google login failed: Unknown error', e);
      return Error(UnknownFailure(
        message: 'Đã xảy ra lỗi không mong muốn trong quá trình đăng nhập với Google',
        code: 'UNKNOWN_ERROR',
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
        AppConstants.getCurrentUserEndpoint,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      final generalResponse = GeneralResponse<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      final user = UserModel.fromJson(generalResponse.data);
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
