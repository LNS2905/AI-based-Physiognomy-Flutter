// Secure Storage Service for sensitive data
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ai_physiognomy_app/core/utils/logger.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for secure storage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Store access token securely
  Future<void> storeAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      AppLogger.info('SecureStorageService: Access token stored successfully');
    } catch (e) {
      AppLogger.error('SecureStorageService: Failed to store access token', e);
      rethrow;
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      AppLogger.info('SecureStorageService: Access token retrieved');
      return token;
    } catch (e) {
      AppLogger.error('SecureStorageService: Failed to get access token', e);
      return null;
    }
  }

  /// Store refresh token securely
  Future<void> storeRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      AppLogger.info('SecureStorageService: Refresh token stored successfully');
    } catch (e) {
      AppLogger.error('SecureStorageService: Failed to store refresh token', e);
      rethrow;
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      AppLogger.info('SecureStorageService: Refresh token retrieved');
      return token;
    } catch (e) {
      AppLogger.error('SecureStorageService: Failed to get refresh token', e);
      return null;
    }
  }

  /// Clear access token
  Future<void> clearAccessToken() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      AppLogger.info('SecureStorageService: Access token cleared');
    } catch (e) {
      AppLogger.error('SecureStorageService: Failed to clear access token', e);
    }
  }

  /// Clear refresh token
  Future<void> clearRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
      AppLogger.info('SecureStorageService: Refresh token cleared');
    } catch (e) {
      AppLogger.error('SecureStorageService: Failed to clear refresh token', e);
    }
  }

  /// Clear all tokens
  Future<void> clearAllTokens() async {
    try {
      await clearAccessToken();
      await clearRefreshToken();
      AppLogger.info('SecureStorageService: All tokens cleared');
    } catch (e) {
      AppLogger.error('SecureStorageService: Failed to clear all tokens', e);
    }
  }

  /// Check if access token exists
  Future<bool> hasAccessToken() async {
    try {
      final token = await getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      AppLogger.error('SecureStorageService: Failed to check access token', e);
      return false;
    }
  }

  /// Store any secure value
  Future<void> storeSecureValue(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      AppLogger.info('SecureStorageService: Secure value stored for key: $key');
    } catch (e) {
      AppLogger.error('SecureStorageService: Failed to store secure value for key: $key', e);
      rethrow;
    }
  }

  /// Get any secure value
  Future<String?> getSecureValue(String key) async {
    try {
      final value = await _storage.read(key: key);
      AppLogger.info('SecureStorageService: Secure value retrieved for key: $key');
      return value;
    } catch (e) {
      AppLogger.error('SecureStorageService: Failed to get secure value for key: $key', e);
      return null;
    }
  }

  /// Delete any secure value
  Future<void> deleteSecureValue(String key) async {
    try {
      await _storage.delete(key: key);
      AppLogger.info('SecureStorageService: Secure value deleted for key: $key');
    } catch (e) {
      AppLogger.error('SecureStorageService: Failed to delete secure value for key: $key', e);
    }
  }

  /// Clear all secure storage
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.info('SecureStorageService: All secure storage cleared');
    } catch (e) {
      AppLogger.error('SecureStorageService: Failed to clear all secure storage', e);
    }
  }

  /// Get all keys
  Future<Map<String, String>> getAllSecureValues() async {
    try {
      final values = await _storage.readAll();
      AppLogger.info('SecureStorageService: Retrieved all secure values');
      return values;
    } catch (e) {
      AppLogger.error('SecureStorageService: Failed to get all secure values', e);
      return {};
    }
  }
}
