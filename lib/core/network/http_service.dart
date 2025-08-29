import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../utils/logger.dart';
import '../storage/secure_storage_service.dart';
import 'api_result.dart';

/// HTTP service for making API calls
class HttpService {
  final http.Client _client;
  final String _baseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();

  // Flag to prevent infinite refresh loops
  bool _isRefreshing = false;

  // Callback for auth expiry handling
  static void Function()? _onAuthExpired;

  HttpService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConstants.baseUrl;

  /// Register callback for auth expiry handling
  static void registerAuthExpiredCallback(void Function() callback) {
    _onAuthExpired = callback;
    AppLogger.info('HttpService: Auth expired callback registered');
  }

  /// Unregister auth expiry callback
  static void unregisterAuthExpiredCallback() {
    _onAuthExpired = null;
    AppLogger.info('HttpService: Auth expired callback unregistered');
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      AppLogger.logRequest('GET', uri.toString(), queryParameters);

      return await _executeWithRetry(
        () async {
          final requestHeaders = await _buildHeaders(headers);
          return _client
              .get(uri, headers: requestHeaders)
              .timeout(AppConstants.requestTimeout);
        },
        'GET',
        uri.toString(),
      );
    } on SocketException {
      throw const NetworkException(
        message: AppConstants.networkErrorMessage,
        code: 'NETWORK_ERROR',
      );
    } on HttpException catch (e) {
      throw NetworkException(
        message: e.message,
        code: 'HTTP_ERROR',
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      AppLogger.error('GET request failed', e);
      throw ServerException(
        message: AppConstants.unknownErrorMessage,
        code: 'UNKNOWN_ERROR',
        details: e.toString(),
      );
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      AppLogger.logRequest('POST', uri.toString(), body);

      return await _executeWithRetry(
        () async {
          final requestHeaders = await _buildHeaders(headers);
          final requestBody = body != null ? jsonEncode(body) : null;
          return _client
              .post(uri, headers: requestHeaders, body: requestBody)
              .timeout(AppConstants.requestTimeout);
        },
        'POST',
        uri.toString(),
      );
    } on SocketException {
      throw const NetworkException(
        message: AppConstants.networkErrorMessage,
        code: 'NETWORK_ERROR',
      );
    } on HttpException catch (e) {
      throw NetworkException(
        message: e.message,
        code: 'HTTP_ERROR',
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      AppLogger.error('POST request failed', e);
      throw ServerException(
        message: AppConstants.unknownErrorMessage,
        code: 'UNKNOWN_ERROR',
        details: e.toString(),
      );
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      AppLogger.logRequest('PUT', uri.toString(), body);

      return await _executeWithRetry(
        () async {
          final requestHeaders = await _buildHeaders(headers);
          final requestBody = body != null ? jsonEncode(body) : null;
          return _client
              .put(uri, headers: requestHeaders, body: requestBody)
              .timeout(AppConstants.requestTimeout);
        },
        'PUT',
        uri.toString(),
      );
    } on SocketException {
      throw const NetworkException(
        message: AppConstants.networkErrorMessage,
        code: 'NETWORK_ERROR',
      );
    } on HttpException catch (e) {
      throw NetworkException(
        message: e.message,
        code: 'HTTP_ERROR',
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      AppLogger.error('PUT request failed', e);
      throw ServerException(
        message: AppConstants.unknownErrorMessage,
        code: 'UNKNOWN_ERROR',
        details: e.toString(),
      );
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      AppLogger.logRequest('DELETE', uri.toString(), queryParameters);

      return await _executeWithRetry(
        () async {
          final requestHeaders = await _buildHeaders(headers);
          return _client
              .delete(uri, headers: requestHeaders)
              .timeout(AppConstants.requestTimeout);
        },
        'DELETE',
        uri.toString(),
      );
    } on SocketException {
      throw const NetworkException(
        message: AppConstants.networkErrorMessage,
        code: 'NETWORK_ERROR',
      );
    } on HttpException catch (e) {
      throw NetworkException(
        message: e.message,
        code: 'HTTP_ERROR',
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      AppLogger.error('DELETE request failed', e);
      throw ServerException(
        message: AppConstants.unknownErrorMessage,
        code: 'UNKNOWN_ERROR',
        details: e.toString(),
      );
    }
  }

  /// Upload file
  Future<ApiResult<Map<String, dynamic>>> uploadFile(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, String>? headers,
    Map<String, String>? fields,
  }) async {
    try {
      final uri = _buildUri(endpoint, null);
      final file = File(filePath);

      if (!file.existsSync()) {
        throw const ValidationException(
          message: 'File does not exist',
          code: 'FILE_NOT_FOUND',
        );
      }

      AppLogger.logRequest('UPLOAD', uri.toString(), {'filePath': filePath});

      final request = http.MultipartRequest('POST', uri);

      // Add headers
      final requestHeaders = await _buildHeaders(headers);
      request.headers.addAll(requestHeaders);

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add file
      final multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        filePath,
        filename: path.basename(filePath),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(AppConstants.requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      final result = _handleResponse(response, 'UPLOAD', uri.toString());
      return Success(result);
    } on SocketException {
      return const Error(NetworkFailure(
        message: AppConstants.networkErrorMessage,
        code: 'NETWORK_ERROR',
      ));
    } on HttpException catch (e) {
      return Error(NetworkFailure(
        message: e.message,
        code: 'HTTP_ERROR',
      ));
    } catch (e) {
      AppLogger.error('File upload failed', e);
      return Error(UnknownFailure(
        message: 'File upload failed: ${e.toString()}',
        code: 'UPLOAD_ERROR',
      ));
    }
  }

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    // Determine which backend to use based on endpoint
    String baseUrl;
    String path;

    if (endpoint.contains('analyze-face-from-cloudinary') ||
        endpoint.contains('analyze-palm-cloudinary') ||
        endpoint.startsWith('/api/chat')) {
      // Old Backend APIs (Face/Palm Analysis, Chat)
      baseUrl = AppConstants.oldBackendBaseUrl;
      path = endpoint.startsWith('http')
          ? endpoint.replaceFirst(baseUrl, '')
          : endpoint;
    } else {
      // New Backend APIs (Auth, User Management from OpenAPI docs)
      baseUrl = AppConstants.baseUrl;
      path = endpoint.startsWith('http')
          ? endpoint.replaceFirst(baseUrl, '')
          : endpoint; // Don't add version prefix for new backend
    }

    return Uri.parse(baseUrl).replace(
      path: path.startsWith('/') ? path : '/$path',
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  /// Build request headers with automatic authorization
  Future<Map<String, String>> _buildHeaders(Map<String, String>? additionalHeaders) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add authorization header if available
    try {
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
    } catch (e) {
      AppLogger.warning('HttpService: Failed to get access token for headers', e);
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(
    http.Response response,
    String method,
    String url,
  ) {
    AppLogger.logResponse(method, url, response.statusCode, response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        AppLogger.info('Empty response body for $method $url');
        return <String, dynamic>{};
      }

      try {
        AppLogger.info('Parsing response body for $method $url: ${response.body}');
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          AppLogger.info('Successfully parsed JSON response');
          return decoded;
        } else {
          AppLogger.info('Response is not a Map, wrapping in data field');
          // If API returns a List or other type, wrap it in a Map
          return {'data': decoded};
        }
      } catch (e) {
        AppLogger.error('Failed to parse JSON response: $e');
        AppLogger.error('Response body: ${response.body}');
        throw ServerException(
          message: 'Invalid JSON response from server',
          statusCode: response.statusCode,
          code: 'INVALID_JSON',
        );
      }
    }

    // Handle error responses
    Map<String, dynamic>? errorBody;
    try {
      errorBody = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      // Response body is not valid JSON
    }

    final errorMessage = errorBody?['message'] as String? ??
        errorBody?['error'] as String? ??
        'Request failed with status ${response.statusCode}';

    if (response.statusCode == 401) {
      throw AuthException(
        message: errorMessage,
        code: 'UNAUTHORIZED',
        details: errorBody,
      );
    }

    if (response.statusCode >= 400 && response.statusCode < 500) {
      throw ValidationException(
        message: errorMessage,
        code: 'CLIENT_ERROR',
        details: errorBody,
      );
    }

    throw ServerException(
      message: errorMessage,
      statusCode: response.statusCode,
      code: 'SERVER_ERROR',
      details: errorBody,
    );
  }

  /// Attempt to refresh access token
  Future<bool> _attemptTokenRefresh() async {
    if (_isRefreshing) {
      AppLogger.info('HttpService: Token refresh already in progress');
      return false;
    }

    try {
      _isRefreshing = true;
      AppLogger.info('HttpService: Attempting to refresh access token');

      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        AppLogger.warning('HttpService: No refresh token available');
        return false;
      }

      // Call refresh token endpoint
      final response = await _client.post(
        Uri.parse('$_baseUrl/auth/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(AppConstants.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          final data = responseData['data'];
          final newAccessToken = data['accessToken'] as String;
          final newRefreshToken = data['refreshToken'] as String;

          // Store new tokens
          await _secureStorage.storeAccessToken(newAccessToken);
          await _secureStorage.storeRefreshToken(newRefreshToken);

          AppLogger.info('HttpService: Token refreshed successfully');
          return true;
        }
      }

      AppLogger.warning('HttpService: Token refresh failed with status ${response.statusCode}');
      return false;
    } catch (e) {
      AppLogger.error('HttpService: Token refresh error', e);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Execute request with automatic token refresh on 401
  Future<Map<String, dynamic>> _executeWithRetry(
    Future<http.Response> Function() request,
    String method,
    String url,
  ) async {
    try {
      final response = await request();
      return _handleResponse(response, method, url);
    } on AuthException catch (e) {
      if (e.code == 'UNAUTHORIZED' && !_isRefreshing) {
        AppLogger.info('HttpService: Received 401, attempting token refresh');

        final refreshSuccess = await _attemptTokenRefresh();
        if (refreshSuccess) {
          AppLogger.info('HttpService: Retrying request after token refresh');
          // Retry the original request with new token
          final retryResponse = await request();
          return _handleResponse(retryResponse, method, url);
        } else {
          AppLogger.warning('HttpService: Token refresh failed, clearing auth state');
          // Clear tokens if refresh failed
          await _secureStorage.clearAccessToken();
          await _secureStorage.clearRefreshToken();
          
          // Trigger auto logout if callback is registered
          if (_onAuthExpired != null) {
            AppLogger.info('HttpService: Triggering auto logout due to auth expiry');
            _onAuthExpired!();
          }
        }
      }
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
