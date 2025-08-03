import '../../../../core/providers/base_provider.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/create_user_dto.dart';
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

  /// Login with username and password
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final result = await executeApiOperation(
      () => _authRepository.login(username: username, password: password),
      operationName: 'login',
    );

    if (result != null) {
      _setAuthState(result);
      return true;
    }
    return false;
  }

  /// Sign up new user
  Future<bool> signup({
    required CreateUserDTO createUserDto,
  }) async {
    final result = await executeApiOperation(
      () => _authRepository.signup(createUserDto: createUserDto),
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
        // Old backend behavior - signup returns tokens
        _setAuthState(result);
        return true;
      }
    }
    return false;
  }

  /// Login with Google
  Future<bool> loginWithGoogle({
    required String googleToken,
  }) async {
    final result = await executeApiOperation(
      () => _authRepository.loginWithGoogle(googleToken: googleToken),
      operationName: 'loginWithGoogle',
    );

    if (result != null) {
      _setAuthState(result);
      return true;
    }
    return false;
  }

  /// Logout user
  Future<void> logout() async {
    await executeApiOperation(
      () => _authRepository.logout(),
      operationName: 'logout',
    );
    
    _clearAuthState();
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
    String? phone,
    double? age,
    Gender? gender,
  }) async {
    if (_currentUser == null) return false;

    // This would typically call an API endpoint to update the user
    // For now, we'll just update the local state
    final updatedUser = _currentUser!.copyWith(
      firstName: firstName ?? _currentUser!.firstName,
      lastName: lastName ?? _currentUser!.lastName,
      phone: phone ?? _currentUser!.phone,
      age: age ?? _currentUser!.age,
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
}
