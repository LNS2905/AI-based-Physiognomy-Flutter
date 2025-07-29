import 'package:flutter/foundation.dart';
import '../network/api_result.dart';
import '../errors/failures.dart';
import '../errors/exceptions.dart';
import '../enums/loading_state.dart';
import '../utils/logger.dart';

/// Base provider class with common functionality
abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  Failure? _failure;
  bool _isDisposed = false;
  LoadingInfo _loadingInfo = LoadingInfo.idle;

  /// Current loading state
  bool get isLoading => _isLoading;

  /// Current failure state
  Failure? get failure => _failure;

  /// Check if provider has error
  bool get hasError => _failure != null;

  /// Current detailed loading information
  LoadingInfo get loadingInfo => _loadingInfo;

  /// Set loading state
  void setLoading(bool loading) {
    if (_isDisposed) return;

    if (_isLoading != loading) {
      _isLoading = loading;
      if (loading) {
        _failure = null; // Clear previous errors when starting new operation
        if (_loadingInfo.state == LoadingState.idle) {
          _loadingInfo = const LoadingInfo(state: LoadingState.analyzing);
        }
      } else {
        if (_loadingInfo.state.isLoading) {
          _loadingInfo = LoadingInfo.completed;
        }
      }
      AppLogger.logStateChange(runtimeType.toString(), 'setLoading', loading);
      notifyListeners();
    }
  }

  /// Set detailed loading information
  void setLoadingInfo(LoadingInfo loadingInfo) {
    if (_isDisposed) return;

    if (_loadingInfo != loadingInfo) {
      _loadingInfo = loadingInfo;
      _isLoading = loadingInfo.state.isLoading;

      if (loadingInfo.state.isError) {
        _failure = UnknownFailure(
          message: loadingInfo.errorMessage ?? 'Unknown error occurred',
          code: 'LOADING_ERROR',
        );
      } else if (loadingInfo.state.isLoading) {
        _failure = null; // Clear previous errors when starting new operation
      }

      AppLogger.logStateChange(
        runtimeType.toString(),
        'setLoadingInfo',
        '${loadingInfo.state.name}: ${loadingInfo.getMessage()}',
      );
      notifyListeners();
    }
  }

  /// Set loading state with specific LoadingState
  void setLoadingState(LoadingState state, {String? customMessage, String? errorMessage}) {
    if (_isDisposed) return;

    final newLoadingInfo = LoadingInfo(
      state: state,
      customMessage: customMessage,
      errorMessage: errorMessage,
      canRetry: state.isError,
    );

    setLoadingInfo(newLoadingInfo);
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

  /// Execute analysis operation with step-by-step loading states
  Future<T?> executeAnalysisOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    bool isFaceAnalysis = true,
    LoadingState initialState = LoadingState.analyzing,
    String? customMessage,
  }) async {
    if (_isDisposed) return null;

    try {
      // Set initial loading state
      setLoadingState(initialState, customMessage: customMessage);

      final result = await operation();

      // Set completed state
      setLoadingState(LoadingState.completed);

      AppLogger.logStateChange(
        runtimeType.toString(),
        operationName ?? 'analysisOperation',
        'success',
      );

      return result;
    } catch (e) {
      // Set error state
      setLoadingState(
        LoadingState.error,
        errorMessage: e.toString(),
      );

      AppLogger.error(
        'Analysis operation failed: ${operationName ?? 'unknown'}',
        e,
      );

      return null;
    }
  }

  /// Execute multi-step analysis operation
  Future<T?> executeMultiStepAnalysis<T>({
    required Future<void> Function() initializeStep,
    required Future<void> Function() uploadStep,
    required Future<T> Function() analyzeStep,
    required Future<T> Function(T) processStep,
    String? operationName,
    bool isFaceAnalysis = true,
  }) async {
    if (_isDisposed) return null;

    try {
      // Step 1: Initialize
      setLoadingState(LoadingState.initializing);
      await initializeStep();

      // Step 2: Upload
      setLoadingState(LoadingState.uploading);
      await uploadStep();

      // Step 3: Analyze
      setLoadingState(LoadingState.analyzing);
      final analysisResult = await analyzeStep();

      // Step 4: Process
      setLoadingState(LoadingState.processing);
      final finalResult = await processStep(analysisResult);

      // Completed
      setLoadingState(LoadingState.completed);

      AppLogger.logStateChange(
        runtimeType.toString(),
        operationName ?? 'multiStepAnalysis',
        'success',
      );

      return finalResult;
    } on ValidationException catch (e) {
      setLoadingState(
        LoadingState.error,
        errorMessage: e.message,
      );

      AppLogger.error(
        'Multi-step analysis validation failed: ${operationName ?? 'unknown'}',
        e,
      );

      // Re-throw ValidationException to preserve it
      rethrow;
    } catch (e) {
      setLoadingState(
        LoadingState.error,
        errorMessage: e.toString(),
      );

      AppLogger.error(
        'Multi-step analysis failed: ${operationName ?? 'unknown'}',
        e,
      );

      return null;
    }
  }

  /// Reset loading state to idle
  void resetLoadingState() {
    if (_isDisposed) return;
    setLoadingInfo(LoadingInfo.idle);
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
