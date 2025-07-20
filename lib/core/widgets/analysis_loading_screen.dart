import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../enums/loading_state.dart';
import 'step_progress_indicator.dart';

/// A full-screen loading widget specifically designed for analysis processes
class AnalysisLoadingScreen extends StatefulWidget {
  final LoadingInfo loadingInfo;
  final bool isFaceAnalysis;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final String? customTitle;

  const AnalysisLoadingScreen({
    super.key,
    required this.loadingInfo,
    this.isFaceAnalysis = true,
    this.onCancel,
    this.onRetry,
    this.customTitle,
  });

  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    if (widget.loadingInfo.state.isLoading) {
      _pulseController.repeat(reverse: true);
    }
    
    _fadeController.forward();
  }

  @override
  void didUpdateWidget(AnalysisLoadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.loadingInfo.state.isLoading && !oldWidget.loadingInfo.state.isLoading) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.loadingInfo.state.isLoading && oldWidget.loadingInfo.state.isLoading) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.loadingInfo.state.isError) {
      return _buildErrorContent();
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _buildLoadingContent(),
        ),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (widget.onCancel != null)
            IconButton(
              onPressed: widget.onCancel,
              icon: const Icon(
                Icons.close,
                color: AppColors.textSecondary,
              ),
            ),
          Expanded(
            child: Text(
              widget.customTitle ?? 
              (widget.isFaceAnalysis ? 'Phân tích gương mặt' : 'Phân tích vân tay'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (widget.onCancel != null)
            const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedIcon(),
          const SizedBox(height: 40),
          _buildProgressSection(),
          const SizedBox(height: 40),
          _buildStepProgress(),
          const SizedBox(height: 20),
          _buildLoadingMessage(),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.withOpacity(AppColors.primary, 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.withOpacity(AppColors.primary, 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              widget.isFaceAnalysis ? Icons.face : Icons.fingerprint,
              size: 50,
              color: AppColors.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    final progress = widget.loadingInfo.getProgress();
    
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.withOpacity(AppColors.primary, 0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 6,
        ),
        const SizedBox(height: 12),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepProgress() {
    return StepProgressIndicator(
      currentState: widget.loadingInfo.state,
      isFaceAnalysis: widget.isFaceAnalysis,
      height: 60,
    );
  }

  Widget _buildLoadingMessage() {
    return Column(
      children: [
        Text(
          widget.loadingInfo.getMessage(isFaceAnalysis: widget.isFaceAnalysis),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Quá trình này có thể mất vài giây...',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Đang sử dụng AI để phân tích ${widget.isFaceAnalysis ? 'gương mặt' : 'vân tay'} của bạn',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildErrorContent() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.withOpacity(AppColors.error, 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 50,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            widget.loadingInfo.getMessage(isFaceAnalysis: widget.isFaceAnalysis),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.loadingInfo.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.loadingInfo.errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (widget.onCancel != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Đóng'),
                  ),
                ),
              if (widget.onCancel != null && widget.loadingInfo.canRetry && widget.onRetry != null)
                const SizedBox(width: 16),
              if (widget.loadingInfo.canRetry && widget.onRetry != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Thử lại'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
