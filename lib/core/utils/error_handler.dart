import 'package:flutter/material.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../constants/app_constants.dart';
import 'logger.dart';

/// Global error handler for the application
class ErrorHandler {
  /// Handle and display error to user
  static void handleError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    bool showSnackBar = true,
    VoidCallback? onRetry,
  }) {
    final errorMessage = _getErrorMessage(error, customMessage);
    
    AppLogger.error('Error handled', error);

    if (showSnackBar && context.mounted) {
      _showErrorSnackBar(context, errorMessage, onRetry);
    }
  }

  /// Handle failure and display to user
  static void handleFailure(
    BuildContext context,
    Failure failure, {
    String? customMessage,
    bool showSnackBar = true,
    VoidCallback? onRetry,
  }) {
    final errorMessage = customMessage ?? failure.message;
    
    AppLogger.error('Failure handled: ${failure.code}', failure.message);

    if (showSnackBar && context.mounted) {
      _showErrorSnackBar(context, errorMessage, onRetry);
    }
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    String? customMessage,
    VoidCallback? onRetry,
  }) async {
    if (!context.mounted) return;

    final errorMessage = _getErrorMessage(error, customMessage);
    
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? 'Error'),
          content: Text(errorMessage),
          actions: [
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Retry'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show network error dialog with retry option
  static Future<void> showNetworkErrorDialog(
    BuildContext context, {
    VoidCallback? onRetry,
  }) async {
    await showErrorDialog(
      context,
      const NetworkException(message: AppConstants.networkErrorMessage),
      title: 'Connection Error',
      onRetry: onRetry,
    );
  }

  /// Show validation error dialog
  static Future<void> showValidationErrorDialog(
    BuildContext context,
    String message,
  ) async {
    await showErrorDialog(
      context,
      ValidationException(message: message),
      title: 'Validation Error',
    );
  }

  /// Get user-friendly error message
  static String _getErrorMessage(dynamic error, String? customMessage) {
    if (customMessage != null) return customMessage;

    if (error is AppException) {
      return error.message;
    }

    if (error is Failure) {
      return error.message;
    }

    // Handle common Flutter/Dart exceptions
    if (error is FormatException) {
      return 'Invalid data format';
    }

    if (error is TypeError) {
      return 'Data type error occurred';
    }

    if (error is ArgumentError) {
      return 'Invalid argument provided';
    }

    if (error is StateError) {
      return 'Application state error';
    }

    // Default message for unknown errors
    return AppConstants.unknownErrorMessage;
  }

  /// Show error snack bar
  static void _showErrorSnackBar(
    BuildContext context,
    String message,
    VoidCallback? onRetry,
  ) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show success snack bar
  static void showSuccess(
    BuildContext context,
    String message,
  ) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show info snack bar
  static void showInfo(
    BuildContext context,
    String message,
  ) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning snack bar
  static void showWarning(
    BuildContext context,
    String message,
  ) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Map exception to failure
  static Failure mapExceptionToFailure(dynamic exception) {
    if (exception is NetworkException) {
      return NetworkFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    if (exception is ServerException) {
      return ServerFailure(
        message: exception.message,
        statusCode: exception.statusCode,
        code: exception.code,
      );
    }

    if (exception is AuthException) {
      return AuthFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    if (exception is CacheException) {
      return CacheFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    if (exception is PermissionException) {
      return PermissionFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    if (exception is TimeoutException) {
      return TimeoutFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    return UnknownFailure(
      message: exception.toString(),
      code: 'UNKNOWN_ERROR',
    );
  }
}
