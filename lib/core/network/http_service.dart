import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../utils/logger.dart';
import 'api_result.dart';

/// HTTP service for making API calls
class HttpService {
  final http.Client _client;
  final String _baseUrl;

  HttpService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConstants.baseUrl;

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final requestHeaders = _buildHeaders(headers);

      AppLogger.logRequest('GET', uri.toString(), queryParameters);

      final response = await _client
          .get(uri, headers: requestHeaders)
          .timeout(AppConstants.requestTimeout);

      return _handleResponse(response, 'GET', uri.toString());
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
      final requestHeaders = _buildHeaders(headers);
      final requestBody = body != null ? jsonEncode(body) : null;

      AppLogger.logRequest('POST', uri.toString(), body);

      final response = await _client
          .post(uri, headers: requestHeaders, body: requestBody)
          .timeout(AppConstants.requestTimeout);

      return _handleResponse(response, 'POST', uri.toString());
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
      final requestHeaders = _buildHeaders(headers);
      final requestBody = body != null ? jsonEncode(body) : null;

      AppLogger.logRequest('PUT', uri.toString(), body);

      final response = await _client
          .put(uri, headers: requestHeaders, body: requestBody)
          .timeout(AppConstants.requestTimeout);

      return _handleResponse(response, 'PUT', uri.toString());
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
      final requestHeaders = _buildHeaders(headers);

      AppLogger.logRequest('DELETE', uri.toString(), queryParameters);

      final response = await _client
          .delete(uri, headers: requestHeaders)
          .timeout(AppConstants.requestTimeout);

      return _handleResponse(response, 'DELETE', uri.toString());
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
      final requestHeaders = _buildHeaders(headers);
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
    // Don't add API version for full endpoints that already include version or are external
    final path = endpoint.startsWith('http') ||
                 endpoint.contains('analyze-face-from-cloudinary') ||
                 endpoint.contains('analyze-palm-cloudinary')
        ? endpoint.replaceFirst(_baseUrl, '') // Remove base URL if it's included
        : '${AppConstants.apiVersion}/$endpoint';

    return Uri.parse(_baseUrl).replace(
      path: path.startsWith('/') ? path : '/$path',
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  /// Build request headers
  Map<String, String> _buildHeaders(Map<String, String>? additionalHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

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
        return <String, dynamic>{};
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        // If API returns a List or other type, wrap it in a Map
        return {'data': decoded};
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

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
