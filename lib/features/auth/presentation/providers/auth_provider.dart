import '../../../../core/providers/base_provider.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Authentication provider
class AuthProvider extends BaseProvider {
  final AuthRepository _authRepository;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  UserModel? _currentUser;
  bool _isAuthenticated = false;

  /// Current authenticated user
  UserModel? get currentUser => _currentUser;

  /// Authentication status
  bool get isAuthenticated => _isAuthenticated;

  /// Initialize authentication state
  Future<void> initialize() async {
    await executeOperation(
      () async {
        final isLoggedIn = await _authRepository.isLoggedIn();
        if (isLoggedIn) {
          final result = await _authRepository.getCurrentUser();
          if (result is Success<UserModel>) {
            _currentUser = result.data;
            _isAuthenticated = true;
            AppLogger.info('User authentication restored');
          } else if (result is Error<UserModel>) {
            AppLogger.warning('Failed to restore user session: ${result.failure.message}');
            _clearAuthState();
          }
        }
      },
      operationName: 'initialize',
      showLoading: false,
    );
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final result = await executeApiOperation(
      () => _authRepository.login(email: email, password: password),
      operationName: 'login',
    );

    if (result != null) {
      _setAuthState(result);
      return true;
    }
    return false;
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    final result = await executeApiOperation(
      () => _authRepository.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      ),
      operationName: 'register',
    );

    if (result != null) {
      _setAuthState(result);
      return true;
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
      _setAuthState(result);
      return true;
    } else {
      _clearAuthState();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    if (_currentUser == null) return false;

    // This would typically call an API endpoint to update the user
    // For now, we'll just update the local state
    final updatedUser = _currentUser!.copyWith(
      firstName: firstName ?? _currentUser!.firstName,
      lastName: lastName ?? _currentUser!.lastName,
      phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
      dateOfBirth: dateOfBirth ?? _currentUser!.dateOfBirth,
      gender: gender ?? _currentUser!.gender,
      updatedAt: DateTime.now(),
    );

    _currentUser = updatedUser;
    AppLogger.logStateChange(runtimeType.toString(), 'updateProfile', 'success');
    notifyListeners();
    return true;
  }

  /// Set authentication state
  void _setAuthState(AuthResponseModel authResponse) {
    _currentUser = authResponse.user;
    _isAuthenticated = true;
    AppLogger.logStateChange(
      runtimeType.toString(),
      'setAuthState',
      'authenticated: ${authResponse.user.email}',
    );
    notifyListeners();
  }

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
    return _currentUser!.firstName != null &&
           _currentUser!.lastName != null &&
           _currentUser!.dateOfBirth != null &&
           _currentUser!.gender != null;
  }

  /// Get user display name
  String get userDisplayName {
    if (_currentUser == null) return 'Guest';
    return _currentUser!.displayName;
  }

  /// Get user initials for avatar
  String get userInitials {
    if (_currentUser == null) return 'G';
    final firstName = _currentUser!.firstName ?? '';
    final lastName = _currentUser!.lastName ?? '';

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (_currentUser!.email.isNotEmpty) {
      return _currentUser!.email[0].toUpperCase();
    }
    return 'U';
  }

  /// Login with Google
  Future<bool> loginWithGoogle() async {
    final result = await executeApiOperation(
      () => _authRepository.loginWithGoogle(),
      operationName: 'google_login',
    );

    if (result != null) {
      _setAuthState(result);
      return true;
    }
    return false;
  }

  /// Register with Google
  Future<bool> registerWithGoogle() async {
    final result = await executeApiOperation(
      () => _authRepository.registerWithGoogle(),
      operationName: 'google_register',
    );

    if (result != null) {
      _setAuthState(result);
      return true;
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
      _setAuthState(result);
      return true;
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
