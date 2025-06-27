import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';

/// Storage service for managing app data persistence
class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static SharedPreferences? _prefs;

  /// Initialize storage service
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info('Storage service initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize storage service', e);
      throw CacheException(
        message: 'Failed to initialize storage',
        details: e.toString(),
      );
    }
  }

  /// Store sensitive data securely (tokens, passwords, etc.)
  static Future<void> storeSecure(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      AppLogger.debug('Stored secure data for key: $key');
    } catch (e) {
      AppLogger.error('Failed to store secure data for key: $key', e);
      throw CacheException(
        message: 'Failed to store secure data',
        details: e.toString(),
      );
    }
  }

  /// Retrieve sensitive data securely
  static Future<String?> getSecure(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      AppLogger.debug('Retrieved secure data for key: $key');
      return value;
    } catch (e) {
      AppLogger.error('Failed to retrieve secure data for key: $key', e);
      throw CacheException(
        message: 'Failed to retrieve secure data',
        details: e.toString(),
      );
    }
  }

  /// Remove sensitive data
  static Future<void> removeSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
      AppLogger.debug('Removed secure data for key: $key');
    } catch (e) {
      AppLogger.error('Failed to remove secure data for key: $key', e);
      throw CacheException(
        message: 'Failed to remove secure data',
        details: e.toString(),
      );
    }
  }

  /// Clear all secure storage
  static Future<void> clearSecure() async {
    try {
      await _secureStorage.deleteAll();
      AppLogger.info('Cleared all secure storage');
    } catch (e) {
      AppLogger.error('Failed to clear secure storage', e);
      throw CacheException(
        message: 'Failed to clear secure storage',
        details: e.toString(),
      );
    }
  }

  /// Store regular data (preferences, settings, etc.)
  static Future<void> store(String key, dynamic value) async {
    try {
      if (_prefs == null) {
        throw const CacheException(message: 'Storage not initialized');
      }

      if (value is String) {
        await _prefs!.setString(key, value);
      } else if (value is int) {
        await _prefs!.setInt(key, value);
      } else if (value is double) {
        await _prefs!.setDouble(key, value);
      } else if (value is bool) {
        await _prefs!.setBool(key, value);
      } else if (value is List<String>) {
        await _prefs!.setStringList(key, value);
      } else {
        // Store as JSON string for complex objects
        await _prefs!.setString(key, jsonEncode(value));
      }

      AppLogger.debug('Stored data for key: $key');
    } catch (e) {
      AppLogger.error('Failed to store data for key: $key', e);
      throw CacheException(
        message: 'Failed to store data',
        details: e.toString(),
      );
    }
  }

  /// Retrieve regular data
  static T? get<T>(String key) {
    try {
      if (_prefs == null) {
        throw const CacheException(message: 'Storage not initialized');
      }

      final value = _prefs!.get(key);
      AppLogger.debug('Retrieved data for key: $key');
      return value as T?;
    } catch (e) {
      AppLogger.error('Failed to retrieve data for key: $key', e);
      return null;
    }
  }

  /// Retrieve JSON object
  static Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = get<String>(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to retrieve JSON for key: $key', e);
      return null;
    }
  }

  /// Remove regular data
  static Future<void> remove(String key) async {
    try {
      if (_prefs == null) {
        throw const CacheException(message: 'Storage not initialized');
      }

      await _prefs!.remove(key);
      AppLogger.debug('Removed data for key: $key');
    } catch (e) {
      AppLogger.error('Failed to remove data for key: $key', e);
      throw CacheException(
        message: 'Failed to remove data',
        details: e.toString(),
      );
    }
  }

  /// Clear all regular storage
  static Future<void> clear() async {
    try {
      if (_prefs == null) {
        throw const CacheException(message: 'Storage not initialized');
      }

      await _prefs!.clear();
      AppLogger.info('Cleared all regular storage');
    } catch (e) {
      AppLogger.error('Failed to clear regular storage', e);
      throw CacheException(
        message: 'Failed to clear storage',
        details: e.toString(),
      );
    }
  }

  /// Check if key exists
  static bool containsKey(String key) {
    if (_prefs == null) return false;
    return _prefs!.containsKey(key);
  }

  /// Get all keys
  static Set<String> getAllKeys() {
    if (_prefs == null) return <String>{};
    return _prefs!.getKeys();
  }
}
