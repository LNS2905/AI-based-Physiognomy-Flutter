import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/google_auth_result.dart';
import '../utils/logger.dart';
import '../errors/exceptions.dart';

/// Google Sign-In service for handling Google authentication
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  late GoogleSignIn _googleSignIn;
  late FirebaseAuth _firebaseAuth;
  bool _isInitialized = false;

  /// Initialize Google Sign-In service
  void initialize() {
    if (_isInitialized) return;

    try {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // Use the web client ID for cross-platform compatibility
        serverClientId: '353105233475-8a2d1sjj6o5lv5vokol8jaua879pnppk.apps.googleusercontent.com',
      );
      _firebaseAuth = FirebaseAuth.instance;
      _isInitialized = true;

      AppLogger.info('GoogleSignInService initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize GoogleSignInService', e);
      throw AuthException(
        message: 'Không thể khởi tạo Google Sign-In: ${e.toString()}',
        code: 'GOOGLE_INIT_ERROR',
      );
    }
  }

  /// Sign in with Google
  Future<GoogleAuthResult> signInWithGoogle() async {
    try {
      if (!_isInitialized) {
        initialize();
      }

      AppLogger.info('Starting Google Sign-In process');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException(
          message: 'Người dùng đã hủy đăng nhập Google',
          code: 'GOOGLE_SIGN_IN_CANCELLED',
        );
      }

      AppLogger.info('Google user signed in: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw AuthException(
          message: 'Không thể lấy ID token từ Google',
          code: 'GOOGLE_ID_TOKEN_NULL',
        );
      }

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw AuthException(
          message: 'Không thể xác thực với Firebase',
          code: 'FIREBASE_AUTH_FAILED',
        );
      }

      AppLogger.info('Firebase authentication successful');

      // Create GoogleAuthResult
      final result = GoogleAuthResult.fromGoogleAccount(
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
        id: googleUser.id,
      );

      AppLogger.info('Google Sign-In completed successfully');
      return result;

    } on AuthException {
      rethrow;
    } catch (e) {
      AppLogger.error('Google Sign-In failed', e);
      throw AuthException(
        message: 'Đăng nhập Google thất bại: ${e.toString()}',
        code: 'GOOGLE_SIGN_IN_ERROR',
      );
    }
  }

  /// Silent sign-in (for auto-login)
  Future<GoogleAuthResult?> silentSignIn() async {
    try {
      if (!_isInitialized) {
        initialize();
      }

      AppLogger.info('Attempting silent Google Sign-In');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();

      if (googleUser == null) {
        AppLogger.info('No previous Google Sign-In found');
        return null;
      }

      AppLogger.info('Silent Google Sign-In found user: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        AppLogger.warning('Silent sign-in: ID token is null');
        return null;
      }

      // Create GoogleAuthResult
      final result = GoogleAuthResult.fromGoogleAccount(
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
        id: googleUser.id,
      );

      AppLogger.info('Silent Google Sign-In completed successfully');
      return result;

    } catch (e) {
      AppLogger.warning('Silent Google Sign-In failed', e);
      return null;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      if (!_isInitialized) {
        initialize();
      }

      AppLogger.info('Starting Google Sign-Out');

      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      AppLogger.info('Google Sign-Out completed successfully');

    } catch (e) {
      AppLogger.error('Google Sign-Out failed', e);
      throw AuthException(
        message: 'Đăng xuất Google thất bại: ${e.toString()}',
        code: 'GOOGLE_SIGN_OUT_ERROR',
      );
    }
  }

  /// Check if user is currently signed in
  bool get isSignedIn {
    if (!_isInitialized) return false;
    return _googleSignIn.currentUser != null;
  }

  /// Get current Google user
  GoogleSignInAccount? get currentUser {
    if (!_isInitialized) return null;
    return _googleSignIn.currentUser;
  }
}
