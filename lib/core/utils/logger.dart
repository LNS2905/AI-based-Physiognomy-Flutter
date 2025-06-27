import 'package:logger/logger.dart';

/// Application logger utility
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log debug message
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info message
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning message
  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error message
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal error message
  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log network request
  static void logRequest(String method, String url, Map<String, dynamic>? data) {
    info('🌐 $method $url', data);
  }

  /// Log network response
  static void logResponse(String method, String url, int statusCode, dynamic data) {
    if (statusCode >= 200 && statusCode < 300) {
      info('✅ $method $url - $statusCode', data);
    } else {
      error('❌ $method $url - $statusCode', data);
    }
  }

  /// Log provider state change
  static void logStateChange(String providerName, String action, dynamic data) {
    debug('🔄 $providerName: $action', data);
  }

  /// Log navigation
  static void logNavigation(String from, String to) {
    info('🧭 Navigation: $from → $to');
  }
}
