import '../storage/storage_service.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'google_sign_in_service.dart';

/// Service for handling complete logout process
class LogoutService {
  static final GoogleSignInService _googleSignInService = GoogleSignInService();

  /// Perform complete logout
  /// Clears all stored data, tokens, and signs out from all services
  static Future<void> performCompleteLogout() async {
    try {
      AppLogger.info('Starting complete logout process');

      // 1. Sign out from Google
      try {
        await _googleSignInService.signOut();
        AppLogger.info('Google sign out completed');
      } catch (e) {
        AppLogger.warning('Google sign out failed, continuing with logout', e);
      }

      // 2. Clear all secure storage (tokens)
      await _clearSecureStorage();

      // 3. Clear all regular storage (user data, preferences)
      await _clearRegularStorage();

      // 4. Clear any cached data
      await _clearCachedData();

      AppLogger.info('Complete logout process finished successfully');

    } catch (e) {
      AppLogger.error('Error during complete logout', e);
      // Even if some steps fail, try to clear as much as possible
      await _forceCleanup();
      rethrow;
    }
  }

  /// Clear all secure storage data
  static Future<void> _clearSecureStorage() async {
    try {
      await StorageService.removeSecure(AppConstants.accessTokenKey);
      await StorageService.removeSecure(AppConstants.refreshTokenKey);
      AppLogger.info('Secure storage cleared');
    } catch (e) {
      AppLogger.error('Failed to clear secure storage', e);
    }
  }

  /// Clear all regular storage data
  static Future<void> _clearRegularStorage() async {
    try {
      await StorageService.remove(AppConstants.userDataKey);
      await StorageService.remove(AppConstants.themeKey);
      // Keep isFirstLaunchKey to preserve onboarding state
      AppLogger.info('Regular storage cleared');
    } catch (e) {
      AppLogger.error('Failed to clear regular storage', e);
    }
  }

  /// Clear any cached data
  static Future<void> _clearCachedData() async {
    try {
      // Clear any other cached data here
      // For example: image cache, analysis history cache, etc.
      AppLogger.info('Cached data cleared');
    } catch (e) {
      AppLogger.error('Failed to clear cached data', e);
    }
  }

  /// Force cleanup - try to clear everything even if individual steps fail
  static Future<void> _forceCleanup() async {
    final futures = <Future>[];

    // Add all cleanup operations
    futures.add(_clearSecureStorage());
    futures.add(_clearRegularStorage());
    futures.add(_clearCachedData());

    // Wait for all to complete, ignoring individual failures
    await Future.wait(futures, eagerError: false);
    
    AppLogger.info('Force cleanup completed');
  }

  /// Check if user has any stored authentication data
  static Future<bool> hasStoredAuthData() async {
    try {
      final accessToken = await StorageService.getSecure(AppConstants.accessTokenKey);
      final userData = StorageService.get<String>(AppConstants.userDataKey);
      return accessToken != null || userData != null;
    } catch (e) {
      AppLogger.error('Failed to check stored auth data', e);
      return false;
    }
  }

  /// Clear only authentication related data (partial logout)
  static Future<void> clearAuthDataOnly() async {
    try {
      AppLogger.info('Clearing authentication data only');
      
      await StorageService.removeSecure(AppConstants.accessTokenKey);
      await StorageService.removeSecure(AppConstants.refreshTokenKey);
      await StorageService.remove(AppConstants.userDataKey);
      
      AppLogger.info('Authentication data cleared');
    } catch (e) {
      AppLogger.error('Failed to clear authentication data', e);
      rethrow;
    }
  }
}
