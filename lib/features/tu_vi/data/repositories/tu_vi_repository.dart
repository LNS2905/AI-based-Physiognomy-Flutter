import '../../../../core/network/http_service.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/tu_vi_chart_request.dart';
import '../models/tu_vi_chart_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Repository for handling Tu Vi API operations
class TuViRepository {
  final String baseUrl;

  TuViRepository({String? baseUrl})
      : baseUrl = baseUrl ?? 'http://10.0.2.2:8000';

  /// Create a new Tu Vi chart
  Future<ApiResult<TuViChartResponse>> createChart(
    TuViChartRequest request,
  ) async {
    try {
      AppLogger.info('Creating Tu Vi chart for: ${request.name}');

      final uri = Uri.parse('$baseUrl/charts');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final chart = TuViChartResponse.fromJson(data);

        AppLogger.info('Created Tu Vi chart with ID: ${chart.id}');
        return Success(chart);
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        AppLogger.error('Failed to create Tu Vi chart: ${response.statusCode}', error);
        return Error(
          ServerFailure(
            message: error['detail']?.toString() ?? 'Failed to create chart',
            code: response.statusCode.toString(),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error creating Tu Vi chart', e);
      return Error(_mapErrorToFailure(e));
    }
  }

  /// Get an existing Tu Vi chart by ID
  Future<ApiResult<TuViChartResponse>> getChart(int id) async {
    try {
      AppLogger.info('Fetching Tu Vi chart: $id');

      final uri = Uri.parse('$baseUrl/charts/$id');
      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final chart = TuViChartResponse.fromJson(data);

        AppLogger.info('Fetched Tu Vi chart: ${chart.id}');
        return Success(chart);
      } else if (response.statusCode == 404) {
        return Error(
          ServerFailure(
            message: 'Không tìm thấy lá số',
            code: '404',
          ),
        );
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        AppLogger.error('Failed to fetch Tu Vi chart: ${response.statusCode}', error);
        return Error(
          ServerFailure(
            message: error['detail']?.toString() ?? 'Failed to fetch chart',
            code: response.statusCode.toString(),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error fetching Tu Vi chart', e);
      return Error(_mapErrorToFailure(e));
    }
  }

  /// List recent Tu Vi charts
  Future<ApiResult<List<TuViChartResponse>>> listCharts({
    int limit = 20,
  }) async {
    try {
      AppLogger.info('Fetching Tu Vi charts list (limit: $limit)');

      final uri = Uri.parse('$baseUrl/charts').replace(
        queryParameters: {'limit': limit.toString()},
      );
      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final charts = data
            .map((json) => TuViChartResponse.fromJson(json))
            .toList();

        AppLogger.info('Fetched ${charts.length} Tu Vi charts');
        return Success(charts);
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        AppLogger.error('Failed to fetch Tu Vi charts: ${response.statusCode}', error);
        return Error(
          ServerFailure(
            message: error['detail']?.toString() ?? 'Failed to fetch charts',
            code: response.statusCode.toString(),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error fetching Tu Vi charts list', e);
      return Error(_mapErrorToFailure(e));
    }
  }

  /// Map errors to appropriate failures
  Failure _mapErrorToFailure(dynamic error) {
    if (error is NetworkException) {
      return NetworkFailure(
        message: error.message,
        code: error.code,
      );
    } else if (error is ServerException) {
      return ServerFailure(
        message: error.message,
        code: error.code,
      );
    } else if (error.toString().contains('TimeoutException')) {
      return NetworkFailure(
        message: 'Hết thời gian chờ. Vui lòng kiểm tra kết nối.',
        code: 'TIMEOUT',
      );
    } else if (error.toString().contains('SocketException')) {
      return NetworkFailure(
        message: 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối.',
        code: 'CONNECTION_ERROR',
      );
    } else {
      return UnknownFailure(
        message: error.toString(),
        code: 'TU_VI_ERROR',
      );
    }
  }
}
