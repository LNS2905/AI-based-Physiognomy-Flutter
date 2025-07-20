import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../enums/loading_state.dart';

/// A step progress indicator widget for showing multi-step processes
class StepProgressIndicator extends StatelessWidget {
  final LoadingState currentState;
  final bool isFaceAnalysis;
  final bool isVertical;
  final double? height;
  final double? width;

  const StepProgressIndicator({
    super.key,
    required this.currentState,
    this.isFaceAnalysis = true,
    this.isVertical = false,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final steps = _getSteps();
    final currentStep = currentState.stepNumber;

    if (isVertical) {
      return _buildVerticalIndicator(steps, currentStep);
    } else {
      return _buildHorizontalIndicator(steps, currentStep);
    }
  }

  List<StepInfo> _getSteps() {
    if (isFaceAnalysis) {
      return [
        StepInfo(
          title: 'Khởi tạo',
          description: 'Chuẩn bị camera',
          icon: Icons.camera_alt,
          state: LoadingState.initializing,
        ),
        StepInfo(
          title: 'Tải lên',
          description: 'Đang tải ảnh',
          icon: Icons.cloud_upload,
          state: LoadingState.uploading,
        ),
        StepInfo(
          title: 'Phân tích',
          description: 'Phân tích gương mặt',
          icon: Icons.face,
          state: LoadingState.analyzing,
        ),
        StepInfo(
          title: 'Hoàn thành',
          description: 'Xử lý kết quả',
          icon: Icons.check_circle,
          state: LoadingState.processing,
        ),
      ];
    } else {
      return [
        StepInfo(
          title: 'Khởi tạo',
          description: 'Chuẩn bị camera',
          icon: Icons.camera_alt,
          state: LoadingState.initializing,
        ),
        StepInfo(
          title: 'Tải lên',
          description: 'Đang tải ảnh',
          icon: Icons.cloud_upload,
          state: LoadingState.uploading,
        ),
        StepInfo(
          title: 'Phân tích',
          description: 'Phân tích vân tay',
          icon: Icons.fingerprint,
          state: LoadingState.analyzing,
        ),
        StepInfo(
          title: 'Hoàn thành',
          description: 'Xử lý kết quả',
          icon: Icons.check_circle,
          state: LoadingState.processing,
        ),
      ];
    }
  }

  Widget _buildHorizontalIndicator(List<StepInfo> steps, int currentStep) {
    return Container(
      height: height ?? 80,
      width: width,
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            Expanded(
              child: _buildStepItem(
                steps[i],
                i + 1,
                currentStep,
                isLast: i == steps.length - 1,
              ),
            ),
            if (i < steps.length - 1)
              _buildConnector(i + 1 < currentStep),
          ],
        ],
      ),
    );
  }

  Widget _buildVerticalIndicator(List<StepInfo> steps, int currentStep) {
    return Container(
      height: height,
      width: width ?? 200,
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _buildVerticalStepItem(
              steps[i],
              i + 1,
              currentStep,
            ),
            if (i < steps.length - 1)
              _buildVerticalConnector(i + 1 < currentStep),
          ],
        ],
      ),
    );
  }

  Widget _buildStepItem(StepInfo step, int stepNumber, int currentStep, {bool isLast = false}) {
    final isActive = stepNumber == currentStep;
    final isCompleted = stepNumber < currentStep;

    Color circleColor;
    Color iconColor;
    Color textColor;

    if (isCompleted) {
      circleColor = AppColors.success;
      iconColor = AppColors.surface;
      textColor = AppColors.textPrimary;
    } else if (isActive) {
      circleColor = AppColors.primary;
      iconColor = AppColors.surface;
      textColor = AppColors.textPrimary;
    } else {
      circleColor = AppColors.withOpacity(AppColors.textSecondary, 0.3);
      iconColor = AppColors.textSecondary;
      textColor = AppColors.textSecondary;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    color: iconColor,
                    size: 16,
                  )
                : Icon(
                    step.icon,
                    color: iconColor,
                    size: 16,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step.title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVerticalStepItem(StepInfo step, int stepNumber, int currentStep) {
    final isActive = stepNumber == currentStep;
    final isCompleted = stepNumber < currentStep;

    Color circleColor;
    Color iconColor;
    Color textColor;

    if (isCompleted) {
      circleColor = AppColors.success;
      iconColor = AppColors.surface;
      textColor = AppColors.textPrimary;
    } else if (isActive) {
      circleColor = AppColors.primary;
      iconColor = AppColors.surface;
      textColor = AppColors.textPrimary;
    } else {
      circleColor = AppColors.withOpacity(AppColors.textSecondary, 0.3);
      iconColor = AppColors.textSecondary;
      textColor = AppColors.textSecondary;
    }

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    color: iconColor,
                    size: 16,
                  )
                : Icon(
                    step.icon,
                    color: iconColor,
                    size: 16,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
              Text(
                step.description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.withOpacity(textColor, 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(bool isCompleted) {
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(bottom: 40),
      color: isCompleted ? AppColors.success : AppColors.withOpacity(AppColors.textSecondary, 0.3),
    );
  }

  Widget _buildVerticalConnector(bool isCompleted) {
    return Container(
      width: 2,
      height: 20,
      margin: const EdgeInsets.only(left: 15),
      color: isCompleted ? AppColors.success : AppColors.withOpacity(AppColors.textSecondary, 0.3),
    );
  }
}

/// Information for each step in the progress indicator
class StepInfo {
  final String title;
  final String description;
  final IconData icon;
  final LoadingState state;

  const StepInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.state,
  });
}
