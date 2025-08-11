import '../../../../core/providers/base_provider.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/user_model.dart';
import '../../data/models/create_user_dto.dart';
import '../../data/models/auth_models.dart' show User, Gender;
import '../../data/repositories/auth_repository.dart';

/// Authentication provider
class AuthProvider extends BaseProvider {
  final AuthRepository _authRepository;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  User? _currentUser;
  bool _isAuthenticated = false;

  /// Current authenticated user
  User? get currentUser => _currentUser;

  /// Current user ID
  int? get userId => _currentUser?.id;

  /// Authentication status
  bool get isAuthenticated => _isAuthenticated;

  /// Initialize authentication state
  Future<void> initialize() async {
    await executeOperation(
      () async {
        AppLogger.info('AuthProvider: Initializing authentication state...');
        final isLoggedIn = await _authRepository.isLoggedIn();
        AppLogger.info('AuthProvider: Is logged in: $isLoggedIn');

        if (isLoggedIn) {
          final result = await _authRepository.getCurrentUser();
          AppLogger.info('AuthProvider: Get current user result: ${result.runtimeType}');

          if (result is Success<User>) {
            _currentUser = result.data;
            _isAuthenticated = true;
            AppLogger.info('AuthProvider: User authentication restored: ${result.data.displayName}');
          } else if (result is Error<User>) {
            AppLogger.warning('AuthProvider: Failed to restore user session: ${result.failure.message}');
            _clearAuthState();
          }
        } else {
          AppLogger.info('AuthProvider: User not logged in');
        }
      },
      operationName: 'initialize',
      showLoading: false,
    );
  }

  /// Login with username and password
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final authResult = await executeApiOperation(
      () => _authRepository.login(email: username, password: password),
      operationName: 'login',
    );

    if (authResult != null) {
      // Login successful, now get user data
      final userResult = await executeApiOperation(
        () => _authRepository.getCurrentUser(),
        operationName: 'get_current_user',
      );

      if (userResult != null) {
        _currentUser = userResult;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Sign up new user
  Future<bool> signup({
    required CreateUserDTO createUserDto,
  }) async {
    final result = await executeApiOperation(
      () => _authRepository.register(
        email: createUserDto.email,
        password: createUserDto.password,
        firstName: createUserDto.firstName,
        lastName: createUserDto.lastName,
        phoneNumber: createUserDto.phone,
      ),
      operationName: 'signup',
    );

    if (result != null) {
      // For new backend, signup doesn't return tokens
      // We need to login after successful signup to get tokens
      if (result.accessToken == null) {
        AppLogger.info('Signup successful, attempting auto-login...');
        final loginSuccess = await login(
          username: createUserDto.username,
          password: createUserDto.password,
        );
        return loginSuccess;
      } else {
        // Old backend behavior - signup returns tokens, get user data
        final userResult = await executeApiOperation(
          () => _authRepository.getCurrentUser(),
          operationName: 'get_current_user_after_signup',
        );

        if (userResult != null) {
          _currentUser = userResult;
          _isAuthenticated = true;
          notifyListeners();
          return true;
        }
      }
    }
    return false;
  }

  /// Login with Google
  Future<bool> loginWithGoogle({
    required String googleToken,
  }) async {
    final result = await executeApiOperation(
      () => _authRepository.loginWithGoogle(),
      operationName: 'loginWithGoogle',
    );

    if (result != null) {
      // Google login successful, get user data
      final userResult = await executeApiOperation(
        () => _authRepository.getCurrentUser(),
        operationName: 'get_current_user_after_google_login',
      );

      if (userResult != null) {
        _currentUser = userResult;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Sign out from Google if user was signed in with Google
      await _authRepository.signOutGoogle();
    } catch (e) {
      // Continue with logout even if Google sign out fails
      AppLogger.warning('Google sign out failed during logout', e);
    }

    await executeApiOperation(
      () => _authRepository.logout(),
      operationName: 'logout',
    );

    _clearAuthState();
    AppLogger.info('User logged out successfully');
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    final result = await executeApiOperation(
      () => _authRepository.refreshToken(),
      operationName: 'refreshToken',
      showLoading: false,
    );

    if (result != null) {
      // Refresh token successful, get updated user data
      final userResult = await executeApiOperation(
        () => _authRepository.getCurrentUser(),
        operationName: 'get_current_user_after_refresh',
      );

      if (userResult != null) {
        _currentUser = userResult;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    } else {
      _clearAuthState();
      return false;
    }
    return false;
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    int? age,
    Gender? gender,
  }) async {
    if (_currentUser == null) return false;

    // This would typically call an API endpoint to update the user
    // For now, we'll just create a new User instance with updated values
    _currentUser = User(
      id: _currentUser!.id,
      firstName: firstName ?? _currentUser!.firstName,
      lastName: lastName ?? _currentUser!.lastName,
      email: _currentUser!.email,
      phone: phone ?? _currentUser!.phone,
      age: age ?? _currentUser!.age,
      gender: gender ?? _currentUser!.gender,
      avatar: _currentUser!.avatar,
    );
    AppLogger.logStateChange(runtimeType.toString(), 'updateProfile', 'success');
    notifyListeners();
    return true;
  }

  /// Set authentication state


  /// Clear authentication state
  void _clearAuthState() {
    _currentUser = null;
    _isAuthenticated = false;
    AppLogger.logStateChange(runtimeType.toString(), 'clearAuthState', 'unauthenticated');
    notifyListeners();
  }

  /// Check if user has completed profile
  bool get hasCompletedProfile {
    if (_currentUser == null) return false;
    return _currentUser!.firstName.isNotEmpty &&
           _currentUser!.lastName.isNotEmpty &&
           _currentUser!.phone.isNotEmpty;
  }

  /// Get user display name
  String get userDisplayName {
    if (_currentUser == null) return 'Guest';
    return _currentUser!.displayName;
  }

  /// Get user initials for avatar
  String get userInitials {
    if (_currentUser == null) return 'G';
    final firstName = _currentUser!.firstName;
    final lastName = _currentUser!.lastName;

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (_currentUser!.email.isNotEmpty) {
      return _currentUser!.email[0].toUpperCase();
    }
    return 'U';
  }



  /// Register with Google
  Future<bool> registerWithGoogle() async {
    final result = await executeApiOperation(
      () => _authRepository.registerWithGoogle(),
      operationName: 'google_register',
    );

    if (result != null) {
      // Google register successful, get user data
      final userResult = await executeApiOperation(
        () => _authRepository.getCurrentUser(),
        operationName: 'get_current_user_after_google_register',
      );

      if (userResult != null) {
        _currentUser = userResult;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Silent Google Sign-In (for auto-login)
  Future<bool> silentGoogleSignIn() async {
    final result = await executeApiOperation(
      () => _authRepository.silentGoogleSignIn(),
      operationName: 'silent_google_signin',
      showLoading: false,
    );

    if (result != null) {
      // Silent Google sign-in successful, get user data
      final userResult = await executeApiOperation(
        () => _authRepository.getCurrentUser(),
        operationName: 'get_current_user_after_silent_google_signin',
      );

      if (userResult != null) {
        _currentUser = userResult;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    await executeApiOperation(
      () async {
        await _authRepository.signOutGoogle();
        return const Success(null); // Return Success for void operations
      },
      operationName: 'google_signout',
    );

    _clearAuthState();
  }
}
