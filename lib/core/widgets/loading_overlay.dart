import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../enums/loading_state.dart';

/// A customizable loading overlay widget that can be used throughout the app
class LoadingOverlay extends StatelessWidget {
  final bool isVisible;
  final LoadingInfo loadingInfo;
  final bool isFaceAnalysis;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;
  final Widget? child;

  const LoadingOverlay({
    super.key,
    required this.isVisible,
    required this.loadingInfo,
    this.isFaceAnalysis = true,
    this.onRetry,
    this.onCancel,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null) child!,
        if (isVisible)
          Container(
            color: AppColors.withOpacity(Colors.black, 0.7),
            child: Center(
              child: _buildLoadingContent(context),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    if (loadingInfo.state.isError) {
      return _buildErrorContent(context);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.withOpacity(Colors.black, 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLoadingIndicator(),
          const SizedBox(height: 20),
          _buildProgressIndicator(),
          const SizedBox(height: 16),
          _buildLoadingMessage(),
          if (onCancel != null) ...[
            const SizedBox(height: 20),
            _buildCancelButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.withOpacity(AppColors.primary, 0.1),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = loadingInfo.getProgress();
    
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.withOpacity(AppColors.primary, 0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 4,
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingMessage() {
    return Column(
      children: [
        Text(
          loadingInfo.getMessage(isFaceAnalysis: isFaceAnalysis),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Vui lòng đợi trong giây lát...',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: onCancel,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: const Text(
        'Hủy',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.withOpacity(Colors.black, 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.withOpacity(AppColors.error, 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            loadingInfo.getMessage(isFaceAnalysis: isFaceAnalysis),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (loadingInfo.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              loadingInfo.errorMessage!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (onCancel != null)
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Đóng'),
                ),
              if (loadingInfo.canRetry && onRetry != null)
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Thử lại'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A simplified loading overlay for quick use
class SimpleLoadingOverlay extends StatelessWidget {
  final bool isVisible;
  final String? message;
  final Widget? child;

  const SimpleLoadingOverlay({
    super.key,
    required this.isVisible,
    this.message,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isVisible: isVisible,
      loadingInfo: LoadingInfo(
        state: LoadingState.analyzing,
        customMessage: message,
      ),
      child: child,
    );
  }
}
