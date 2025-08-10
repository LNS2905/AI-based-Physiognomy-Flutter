import '../../../../core/network/api_result.dart';
import '../../../../core/network/http_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/google_sign_in_service.dart';
import '../../../../core/services/logout_service.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Authentication repository
class AuthRepository {
  final HttpService _httpService;
  final GoogleSignInService _googleSignInService;

  AuthRepository({
    HttpService? httpService,
    GoogleSignInService? googleSignInService,
  })  : _httpService = httpService ?? HttpService(),
        _googleSignInService = googleSignInService ?? GoogleSignInService();

  /// Login with email and password
  Future<ApiResult<AuthResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpService.post(
        'auth/user',
        body: {
          'username': email,
          'password': password,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response['data']);

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

      // Perform complete logout using LogoutService
      await LogoutService.performCompleteLogout();

      AppLogger.info('User logged out successfully');
      return const Success(null);
    } catch (e) {
      AppLogger.error('Logout failed', e);
      // Even if logout fails, try to clear local data
      try {
        await LogoutService.clearAuthDataOnly();
      } catch (clearError) {
        AppLogger.error('Failed to clear auth data during logout error', clearError);
      }
      return Error(UnknownFailure(
        message: 'Đăng xuất hoàn tất với lỗi',
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

      // Debug: Log the response data structure
      AppLogger.info('API Response: $response');
      AppLogger.info('Response data: ${response['data']}');
      AppLogger.info('Response data type: ${response['data'].runtimeType}');
      if (response['data'] is Map<String, dynamic>) {
        final data = response['data'] as Map<String, dynamic>;
        AppLogger.info('ID field: ${data['id']} (type: ${data['id'].runtimeType})');
      }

      final user = UserModel.fromJson(response['data']);
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
    if (authResponse.accessToken != null) {
      await StorageService.storeSecure(
        AppConstants.accessTokenKey,
        authResponse.accessToken!,
      );
    }
    if (authResponse.refreshToken != null) {
      await StorageService.storeSecure(
        AppConstants.refreshTokenKey,
        authResponse.refreshToken!,
      );
    }
    // User data will be stored separately when getCurrentUser is called
  }

  /// Clear authentication tokens
  Future<void> _clearAuthTokens() async {
    await StorageService.removeSecure(AppConstants.accessTokenKey);
    await StorageService.removeSecure(AppConstants.refreshTokenKey);
    await StorageService.remove(AppConstants.userDataKey);
  }

  /// Login with Google
  Future<ApiResult<AuthResponseModel>> loginWithGoogle() async {
    try {
      AppLogger.info('Starting Google Sign-In authentication');

      // Sign in with Google
      final googleResult = await _googleSignInService.signInWithGoogle();

      // Send Google auth data to backend
      final response = await _httpService.post(
        'auth/google',
        body: googleResult.toApiMap(),
      );

      final authResponse = AuthResponseModel.fromJson(response);

      // Store tokens securely
      await _storeAuthTokens(authResponse);

      AppLogger.info('Google Sign-In completed successfully');
      return Success(authResponse);

    } on AuthException catch (e) {
      AppLogger.error('Google Sign-In failed: Authentication error', e);
      return Error(AuthFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      AppLogger.error('Google Sign-In failed: Network error', e);
      return Error(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      AppLogger.error('Google Sign-In failed: Server error', e);
      return Error(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        code: e.code,
      ));
    } catch (e) {
      AppLogger.error('Google Sign-In failed: Unknown error', e);
      return Error(UnknownFailure(
        message: 'Đã xảy ra lỗi không mong muốn trong quá trình đăng nhập Google',
        code: 'GOOGLE_SIGN_IN_ERROR',
      ));
    }
  }

  /// Register with Google (uses same endpoint as login)
  Future<ApiResult<AuthResponseModel>> registerWithGoogle() async {
    try {
      AppLogger.info('Starting Google Sign-Up authentication');

      // Sign in with Google
      final googleResult = await _googleSignInService.signInWithGoogle();

      // Send Google auth data to backend (same endpoint as login)
      final response = await _httpService.post(
        'auth/google',
        body: googleResult.toApiMap(),
      );

      final authResponse = AuthResponseModel.fromJson(response);

      // Store tokens securely
      await _storeAuthTokens(authResponse);

      AppLogger.info('Google Sign-Up completed successfully');
      return Success(authResponse);

    } on AuthException catch (e) {
      AppLogger.error('Google Sign-Up failed: Authentication error', e);
      return Error(AuthFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      AppLogger.error('Google Sign-Up failed: Network error', e);
      return Error(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      AppLogger.error('Google Sign-Up failed: Server error', e);
      return Error(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        code: e.code,
      ));
    } catch (e) {
      AppLogger.error('Google Sign-Up failed: Unknown error', e);
      return Error(UnknownFailure(
        message: 'Đã xảy ra lỗi không mong muốn trong quá trình đăng ký Google',
        code: 'GOOGLE_SIGN_UP_ERROR',
      ));
    }
  }

  /// Silent Google Sign-In (for auto-login)
  Future<ApiResult<AuthResponseModel?>> silentGoogleSignIn() async {
    try {
      AppLogger.info('Attempting silent Google Sign-In');

      final googleResult = await _googleSignInService.silentSignIn();

      if (googleResult == null) {
        AppLogger.info('No previous Google Sign-In found');
        return const Success(null);
      }

      // Authenticate with backend using same endpoint
      final response = await _httpService.post(
        'auth/google',
        body: googleResult.toApiMap(),
      );

      final authResponse = AuthResponseModel.fromJson(response);

      // Store tokens securely
      await _storeAuthTokens(authResponse);

      AppLogger.info('Silent Google Sign-In completed successfully');
      return Success(authResponse);

    } catch (e) {
      AppLogger.warning('Silent Google Sign-In failed', e);
      return const Success(null);
    }
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignInService.signOut();
      AppLogger.info('Google Sign-Out completed');
    } catch (e) {
      AppLogger.error('Google Sign-Out failed', e);
      throw AuthException(
        message: 'Đăng xuất Google thất bại: ${e.toString()}',
        code: 'GOOGLE_SIGN_OUT_ERROR',
      );
    }
  }


}
