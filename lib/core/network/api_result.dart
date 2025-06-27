import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Generic result wrapper for API calls
sealed class ApiResult<T> extends Equatable {
  const ApiResult();
}

/// Success result
class Success<T> extends ApiResult<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

/// Error result
class Error<T> extends ApiResult<T> {
  final Failure failure;

  const Error(this.failure);

  @override
  List<Object?> get props => [failure];
}

/// Loading result
class Loading<T> extends ApiResult<T> {
  const Loading();

  @override
  List<Object?> get props => [];
}

/// Extension methods for ApiResult
extension ApiResultExtension<T> on ApiResult<T> {
  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is error
  bool get isError => this is Error<T>;

  /// Check if result is loading
  bool get isLoading => this is Loading<T>;

  /// Get data if success, null otherwise
  T? get data => switch (this) {
    Success<T> success => success.data,
    _ => null,
  };

  /// Get failure if error, null otherwise
  Failure? get failure => switch (this) {
    Error<T> error => error.failure,
    _ => null,
  };

  /// Execute callback when success
  ApiResult<T> onSuccess(void Function(T data) callback) {
    if (this is Success<T>) {
      callback((this as Success<T>).data);
    }
    return this;
  }

  /// Execute callback when error
  ApiResult<T> onError(void Function(Failure failure) callback) {
    if (this is Error<T>) {
      callback((this as Error<T>).failure);
    }
    return this;
  }

  /// Execute callback when loading
  ApiResult<T> onLoading(void Function() callback) {
    if (this is Loading<T>) {
      callback();
    }
    return this;
  }

  /// Transform success data
  ApiResult<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T> success => Success(transform(success.data)),
      Error<T> error => Error(error.failure),
      Loading<T> _ => const Loading(),
    };
  }

  /// Transform to another type
  ApiResult<R> flatMap<R>(ApiResult<R> Function(T data) transform) {
    return switch (this) {
      Success<T> success => transform(success.data),
      Error<T> error => Error(error.failure),
      Loading<T> _ => const Loading(),
    };
  }
}
