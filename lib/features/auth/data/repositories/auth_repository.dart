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
import '../models/auth_request_model.dart';
import '../models/create_user_dto.dart';
import '../models/google_login_request.dart';
import '../models/general_response_model.dart';

/// Authentication repository
class AuthRepository {
  final HttpService _httpService;
  final GoogleSignInService _googleSignInService;

  AuthRepository({
    HttpService? httpService,
    GoogleSignInService? googleSignInService,
  })  : _httpService = httpService ?? HttpService(),
        _googleSignInService = googleSignInService ?? GoogleSignInService();

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

      // For login, backend returns tokens but no user data
      // We need to get user data separately
      final tokenData = generalResponse.data;

      // Create AuthResponseModel with tokens but no user initially
      final authResponse = AuthResponseModel(
        accessToken: tokenData['accessToken'] as String?,
        refreshToken: tokenData['refreshToken'] as String?,
        user: UserModel(
          id: 'temp', // Temporary ID, will be updated when we get user data
          email: username, // Use login username as email
          firstName: '',
          lastName: '',
          phone: '',
          age: 0,
          gender: Gender.male,
        ),
        expiresIn: tokenData['expiresIn'] as int?,
      );

      // Store tokens securely
      await _storeAuthTokens(authResponse);

      // Get current user data to complete the auth response
      try {
        final currentUserResult = await getCurrentUser();
        if (currentUserResult is Success<UserModel>) {
          final completeAuthResponse = authResponse.copyWith(
            user: currentUserResult.data,
          );
          // Update stored user data
          await StorageService.store(
            AppConstants.userDataKey,
            currentUserResult.data.toJson(),
          );
          AppLogger.info('User logged in successfully with complete user data');
          return Success(completeAuthResponse);
        }
      } catch (e) {
        AppLogger.warning('Failed to get user data after login, but login was successful: $e');
      }

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

      // For signup, backend returns user data directly, not auth tokens
      // Create AuthResponseModel with user data but no tokens
      final userData = generalResponse.data;
      final user = UserModel.fromJson(userData);
      final authResponse = AuthResponseModel(
        user: user,
        accessToken: null, // No token from signup endpoint
        refreshToken: null,
        expiresIn: null,
      );

      // Store user data (no tokens from signup)
      await _storeAuthTokens(authResponse);

      AppLogger.info('User signed up successfully');

      // Note: For new backend, signup doesn't return tokens
      // User will need to login separately to get access tokens
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
    } catch (e, stackTrace) {
      AppLogger.error('Signup failed: Unknown error - ${e.toString()}', e);
      AppLogger.error('Stack trace: $stackTrace');
      return Error(UnknownFailure(
        message: 'Đã xảy ra lỗi không mong muốn trong quá trình đăng ký: ${e.toString()}',
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
    // Only store tokens if they exist
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
    // Always store user data
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
