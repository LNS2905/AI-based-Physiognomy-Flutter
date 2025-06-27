import 'package:flutter/foundation.dart';
import '../network/api_result.dart';
import '../errors/failures.dart';
import '../utils/logger.dart';

/// Base provider class with common functionality
abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  Failure? _failure;
  bool _isDisposed = false;

  /// Current loading state
  bool get isLoading => _isLoading;

  /// Current failure state
  Failure? get failure => _failure;

  /// Check if provider has error
  bool get hasError => _failure != null;

  /// Set loading state
  void setLoading(bool loading) {
    if (_isDisposed) return;
    
    if (_isLoading != loading) {
      _isLoading = loading;
      if (loading) {
        _failure = null; // Clear previous errors when starting new operation
      }
      AppLogger.logStateChange(runtimeType.toString(), 'setLoading', loading);
      notifyListeners();
    }
  }

  /// Set failure state
  void setFailure(Failure? failure) {
    if (_isDisposed) return;
    
    _failure = failure;
    _isLoading = false;
    AppLogger.logStateChange(runtimeType.toString(), 'setFailure', failure?.message);
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    if (_isDisposed) return;
    
    if (_failure != null) {
      _failure = null;
      AppLogger.logStateChange(runtimeType.toString(), 'clearError', null);
      notifyListeners();
    }
  }

  /// Execute async operation with loading and error handling
  Future<T?> executeOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    bool showLoading = true,
  }) async {
    if (_isDisposed) return null;

    try {
      if (showLoading) {
        setLoading(true);
      }

      final result = await operation();
      
      if (showLoading) {
        setLoading(false);
      }
      
      AppLogger.logStateChange(
        runtimeType.toString(),
        operationName ?? 'operation',
        'success',
      );
      
      return result;
    } catch (e) {
      if (showLoading) {
        setLoading(false);
      }

      Failure failure;
      if (e is Exception) {
        failure = _mapExceptionToFailure(e);
      } else {
        failure = UnknownFailure(
          message: e.toString(),
          code: 'UNKNOWN_ERROR',
        );
      }

      setFailure(failure);
      AppLogger.error(
        'Operation failed: ${operationName ?? 'unknown'}',
        e,
      );
      
      return null;
    }
  }

  /// Execute API operation with ApiResult handling
  Future<T?> executeApiOperation<T>(
    Future<ApiResult<T>> Function() operation, {
    String? operationName,
    bool showLoading = true,
  }) async {
    if (_isDisposed) return null;

    try {
      if (showLoading) {
        setLoading(true);
      }

      final result = await operation();
      
      if (showLoading) {
        setLoading(false);
      }

      return result.when(
        success: (data) {
          AppLogger.logStateChange(
            runtimeType.toString(),
            operationName ?? 'apiOperation',
            'success',
          );
          return data;
        },
        error: (failure) {
          setFailure(failure);
          AppLogger.error(
            'API operation failed: ${operationName ?? 'unknown'}',
            failure.message,
          );
          return null;
        },
        loading: () {
          // This shouldn't happen in this context
          return null;
        },
      );
    } catch (e) {
      if (showLoading) {
        setLoading(false);
      }

      final failure = _mapExceptionToFailure(e);
      setFailure(failure);
      AppLogger.error(
        'API operation failed: ${operationName ?? 'unknown'}',
        e,
      );
      
      return null;
    }
  }

  /// Map exceptions to failures
  Failure _mapExceptionToFailure(dynamic exception) {
    // This will be implemented based on your exception types
    return UnknownFailure(
      message: exception.toString(),
      code: 'UNKNOWN_ERROR',
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    AppLogger.logStateChange(runtimeType.toString(), 'dispose', null);
    super.dispose();
  }
}

/// Extension for ApiResult pattern matching
extension ApiResultWhen<T> on ApiResult<T> {
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
    required R Function() loading,
  }) {
    return switch (this) {
      Success<T> s => success(s.data),
      Error<T> e => error(e.failure),
      Loading<T> _ => loading(),
    };
  }
}
