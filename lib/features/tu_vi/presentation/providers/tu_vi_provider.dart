import '../../../../core/providers/base_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/tu_vi_chart_request.dart';
import '../../data/models/tu_vi_chart_response.dart';
import '../../data/repositories/tu_vi_repository.dart';

/// Provider for Tu Vi chart management
class TuViProvider extends BaseProvider {
  final TuViRepository _repository;

  TuViChartResponse? _currentChart;
  List<TuViChartResponse>? _chartHistory;

  TuViProvider({TuViRepository? repository})
      : _repository = repository ?? TuViRepository();

  /// Get current chart
  TuViChartResponse? get currentChart => _currentChart;

  /// Get chart history
  List<TuViChartResponse>? get chartHistory => _chartHistory;

  /// Create a new Tu Vi chart
  Future<TuViChartResponse?> createChart(TuViChartRequest request) async {
    AppLogger.info('TuViProvider: Creating chart for ${request.name}');

    final result = await executeApiOperation(
      () => _repository.createChart(request),
      operationName: 'createChart',
    );

    if (result != null) {
      _currentChart = result;
      notifyListeners();
      AppLogger.info('TuViProvider: Chart created successfully with ID: ${result.id}');
    }

    return result;
  }

  /// Get chart by ID
  Future<TuViChartResponse?> getChart(int id) async {
    AppLogger.info('TuViProvider: Fetching chart $id');

    final result = await executeApiOperation(
      () => _repository.getChart(id),
      operationName: 'getChart',
    );

    if (result != null) {
      _currentChart = result;
      notifyListeners();
      AppLogger.info('TuViProvider: Chart fetched successfully');
    }

    return result;
  }

  /// List recent charts
  Future<List<TuViChartResponse>?> listCharts({int limit = 20}) async {
    AppLogger.info('TuViProvider: Fetching chart list');

    final result = await executeApiOperation(
      () => _repository.listCharts(limit: limit),
      operationName: 'listCharts',
    );

    if (result != null) {
      _chartHistory = result;
      notifyListeners();
      AppLogger.info('TuViProvider: Fetched ${result.length} charts');
    }

    return result;
  }

  /// Set current chart (for navigation from history)
  void setCurrentChart(TuViChartResponse chart) {
    _currentChart = chart;
    notifyListeners();
    AppLogger.info('TuViProvider: Current chart set to ID: ${chart.id}');
  }

  /// Clear current chart
  void clearCurrentChart() {
    _currentChart = null;
    notifyListeners();
    AppLogger.info('TuViProvider: Current chart cleared');
  }

  /// Validate request before submission
  String? validateRequest(TuViChartRequest request) {
    if (request.day < 1 || request.day > 31) {
      return 'Ngày không hợp lệ';
    }
    if (request.month < 1 || request.month > 12) {
      return 'Tháng không hợp lệ';
    }
    if (request.year < 1900 || request.year > 2100) {
      return 'Năm không hợp lệ';
    }
    if (request.hourBranch < 1 || request.hourBranch > 12) {
      return 'Giờ không hợp lệ';
    }
    if (request.gender != 1 && request.gender != -1) {
      return 'Giới tính không hợp lệ';
    }
    if (request.name != null && request.name!.trim().isEmpty) {
      return 'Tên không được để trống';
    }
    return null;
  }

  @override
  void dispose() {
    _currentChart = null;
    _chartHistory = null;
    super.dispose();
  }
}
