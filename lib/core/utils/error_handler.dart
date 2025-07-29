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
          title: Text(title ?? 'Lỗi'),
          content: Text(errorMessage),
          actions: [
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Thử lại'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đồng ý'),
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
      title: 'Lỗi kết nối',
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
      title: 'Lỗi xác thực',
    );
  }

  /// Show photo quality error dialog with retry guidance
  static Future<bool> showPhotoQualityErrorDialog(
    BuildContext context, {
    int retryCount = 0,
    int maxRetries = 3,
  }) async {
    final shouldRetry = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ảnh chụp chưa chuẩn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Để có kết quả phân tích tốt nhất, vui lòng:'),
              const SizedBox(height: 12),
              const Text('• Đảm bảo khuôn mặt rõ ràng, không bị che'),
              const Text('• Chụp trong ánh sáng đủ sáng'),
              const Text('• Giữ camera thẳng và ổn định'),
              const Text('• Khuôn mặt nhìn thẳng vào camera'),
              const SizedBox(height: 12),
              if (retryCount >= maxRetries)
                const Text(
                  'Bạn đã thử nhiều lần. Có thể thử lại sau hoặc sử dụng ảnh khác.',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          actions: [
            if (retryCount < maxRetries) ...[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Chụp lại'),
              ),
            ] else ...[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Đóng'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Thử lại'),
              ),
            ],
          ],
        );
      },
    );

    return shouldRetry ?? false;
  }

  /// Show face detection error dialog with retry guidance
  static Future<bool> showFaceDetectionErrorDialog(
    BuildContext context, {
    int retryCount = 0,
    int maxRetries = 3,
  }) async {
    final shouldRetry = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Không phát hiện được khuôn mặt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Để phân tích chính xác, vui lòng:'),
              const SizedBox(height: 12),
              const Text('• Chụp chính diện gương mặt'),
              const Text('• Tháo kính mắt, cởi nón nếu có'),
              const Text('• Đảm bảo khuôn mặt không bị che'),
              const Text('• Chụp trong ánh sáng đủ sáng'),
              const Text('• Giữ camera thẳng và ổn định'),
              const SizedBox(height: 12),
              if (retryCount >= maxRetries)
                const Text(
                  'Bạn đã thử nhiều lần. Có thể thử lại sau hoặc sử dụng ảnh khác.',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          actions: [
            if (retryCount < maxRetries) ...[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Chụp lại'),
              ),
            ] else ...[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Đóng'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Thử lại'),
              ),
            ],
          ],
        );
      },
    );

    return shouldRetry ?? false;
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
      return 'Định dạng dữ liệu không hợp lệ';
    }

    if (error is TypeError) {
      return 'Đã xảy ra lỗi kiểu dữ liệu';
    }

    if (error is ArgumentError) {
      return 'Tham số không hợp lệ';
    }

    if (error is StateError) {
      return 'Lỗi trạng thái ứng dụng';
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
                label: 'Thử lại',
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
