import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Palm analysis demo widget with animated hand outline and scanning effects
/// Matches the design pattern of FaceAnalysisDemo for consistency
class PalmAnalysisDemo extends StatefulWidget {
  /// Callback when the demo is tapped to start analysis
  final VoidCallback? onTap;

  const PalmAnalysisDemo({super.key, this.onTap});

  @override
  State<PalmAnalysisDemo> createState() => _PalmAnalysisDemoState();
}

class _PalmAnalysisDemoState extends State<PalmAnalysisDemo>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _pointsController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;
  late Animation<double> _pointsAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the main hand outline
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Scanning line animation
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    ));

    // Analysis points animation
    _pointsController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _pointsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pointsController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _pulseController.repeat(reverse: true);
    _scanController.repeat();
    _pointsController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 320,
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
        children: [
          // Main hand outline with pulse animation - oval shape like a pill
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 120,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.7),
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(60), // More oval/pill-like shape
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Scanning line effect
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Positioned(
                left: 30,
                right: 30,
                top: 20 + (_scanAnimation.value * 200),
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primary.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Analysis points
          AnimatedBuilder(
            animation: _pointsAnimation,
            builder: (context, child) {
              return Stack(
                children: _buildAnalysisPoints(),
              );
            },
          ),

          // Center hand with circular frame - synchronized pulse animation
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity((0.2 * _pulseAnimation.value).clamp(0.0, 1.0)),
                          blurRadius: 10 * _pulseAnimation.value,
                          spreadRadius: 2 * _pulseAnimation.value,
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity((0.1 * _pulseAnimation.value).clamp(0.0, 1.0)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.back_hand,
                        color: AppColors.primary.withOpacity(_pulseAnimation.value.clamp(0.0, 1.0)),
                        size: 32,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Center demo text with glassmorphism effect - căn giữa hoàn toàn
          Positioned(
            left: 0,
            right: 0,
            top: 180, // Điều chỉnh để không đè lên palm outline
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'PHÂN TÍCH AI',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Nhấn để bắt đầu\nphân tích đường chỉ tay',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  List<Widget> _buildAnalysisPoints() {
    // Căn giữa các points trong vùng palm outline
    final containerWidth = 320.0;
    final containerHeight = 280.0;
    final pointsAreaWidth = 160.0; // Vùng hiển thị points rộng hơn palm outline một chút
    final pointsAreaHeight = 200.0;
    final pointsLeft = (containerWidth - pointsAreaWidth) / 2;
    final pointsTop = (containerHeight - pointsAreaHeight) / 2 - 10;

    final points = [
      {'x': 0.3, 'y': 0.2, 'delay': 0.0},
      {'x': 0.7, 'y': 0.25, 'delay': 0.2},
      {'x': 0.5, 'y': 0.4, 'delay': 0.4},
      {'x': 0.2, 'y': 0.6, 'delay': 0.6},
      {'x': 0.8, 'y': 0.65, 'delay': 0.8},
      {'x': 0.4, 'y': 0.8, 'delay': 1.0},
    ];

    return points.map((point) {
      final delay = point['delay'] as double;
      final progress = (_pointsAnimation.value - delay).clamp(0.0, 1.0);

      return Positioned(
        left: pointsLeft + (point['x'] as double) * pointsAreaWidth,
        top: pointsTop + (point['y'] as double) * pointsAreaHeight,
        child: AnimatedOpacity(
          opacity: progress > 0 ? (1.0 - progress).clamp(0.0, 1.0) : 0.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// Custom painter for hand outline (simplified without palm lines)
class HandOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // No palm lines needed - keeping it clean and simple
    // The hand icon in the center circle will be the main visual element
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
