import '../../../../core/network/api_result.dart';
import '../../../../core/network/new_backend_http_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../models/auth_response_model.dart';
import '../models/auth_request.dart';
import '../models/create_user_dto.dart';
import '../models/user_model.dart';
import '../models/general_response_model.dart';

/// Authentication repository for new backend APIs (OpenAPI docs)
/// Base URL: https://ai-based-physiognomy-backend.onrender.com
class NewBackendAuthRepository {
  final NewBackendHttpService _httpService;

  NewBackendAuthRepository({NewBackendHttpService? httpService})
      : _httpService = httpService ?? NewBackendHttpService();

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

      AppLogger.info('Attempting login with new backend: $username');

      final response = await _httpService.post(
        AppConstants.newLoginEndpoint,
        body: authRequest.toJson(),
      );

      final generalResponse = GeneralResponse<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      final authResponse = AuthResponseModel.fromJson(generalResponse.data);

      // Store tokens securely
      await _storeAuthTokens(authResponse);

      AppLogger.info('User logged in successfully with new backend');
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
      AppLogger.info('Attempting signup with new backend: ${createUserDto.username}');

      final response = await _httpService.post(
        AppConstants.newSignupEndpoint,
        body: createUserDto.toJson(),
      );

      final generalResponse = GeneralResponse<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      final authResponse = AuthResponseModel.fromJson(generalResponse.data);

      // Store tokens securely
      await _storeAuthTokens(authResponse);

      AppLogger.info('User signed up successfully with new backend');
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

  /// Login with Google
  Future<ApiResult<AuthResponseModel>> loginWithGoogle({
    required String token,
  }) async {
    try {
      AppLogger.info('Attempting Google login with new backend');

      final response = await _httpService.post(
        AppConstants.newGoogleLoginEndpoint,
        body: {
          'token': token,
        },
      );

      final generalResponse = GeneralResponse<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      final authResponse = AuthResponseModel.fromJson(generalResponse.data);

      // Store tokens securely
      await _storeAuthTokens(authResponse);

      AppLogger.info('Google login successful with new backend');
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

      AppLogger.info('Getting current user from new backend');

      final response = await _httpService.get(
        AppConstants.newGetCurrentUserEndpoint,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      final generalResponse = GeneralResponse<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      final user = UserModel.fromJson(generalResponse.data);

      AppLogger.info('Current user retrieved successfully from new backend');
      return Success(user);
    } on AuthException catch (e) {
      AppLogger.error('Get current user failed: Authentication error', e);
      return Error(AuthFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      AppLogger.error('Get current user failed: Network error', e);
      return Error(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      AppLogger.error('Get current user failed: Server error', e);
      return Error(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        code: e.code,
      ));
    } catch (e) {
      AppLogger.error('Get current user failed: Unknown error', e);
      return Error(UnknownFailure(
        message: 'Đã xảy ra lỗi không mong muốn khi lấy thông tin người dùng',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final accessToken = await StorageService.getSecure(AppConstants.accessTokenKey);
    return accessToken != null;
  }

  /// Logout user
  Future<void> logout() async {
    await StorageService.deleteSecure(AppConstants.accessTokenKey);
    await StorageService.deleteSecure(AppConstants.refreshTokenKey);
    await StorageService.delete(AppConstants.userDataKey);
    AppLogger.info('User logged out from new backend');
  }

  /// Store authentication tokens securely
  Future<void> _storeAuthTokens(AuthResponseModel authResponse) async {
    await StorageService.storeSecure(
      AppConstants.accessTokenKey,
      authResponse.accessToken,
    );
    
    if (authResponse.refreshToken != null) {
      await StorageService.storeSecure(
        AppConstants.refreshTokenKey,
        authResponse.refreshToken!,
      );
    }

    if (authResponse.user != null) {
      await StorageService.store(
        AppConstants.userDataKey,
        authResponse.user!.toJson(),
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _httpService.dispose();
  }
}
