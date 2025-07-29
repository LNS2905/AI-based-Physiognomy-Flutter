import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/chart_data_models.dart';
import '../../data/models/cloudinary_analysis_response_model.dart';
import '../widgets/face_shape_probability_chart.dart';
import '../widgets/proportionality_metrics_chart.dart';

/// Page to display face analysis results
class AnalysisResultsPage extends StatelessWidget {
  final CloudinaryAnalysisResponseModel? analysisResponse;
  final Map<String, dynamic>? legacyAnalysisData; // For backward compatibility
  final String? annotatedImagePath;
  final String? reportImagePath; // Deprecated: Không còn sử dụng, chỉ giữ lại để tương thích ngược

  const AnalysisResultsPage({
    super.key,
    this.analysisResponse,
    this.legacyAnalysisData,
    this.annotatedImagePath,
    this.reportImagePath, // Deprecated parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildHeader(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Main Results Card
                    _buildMainResultsCard(),

                    const SizedBox(height: 20),

                    // Analysis Details
                    _buildAnalysisDetails(),

                    const SizedBox(height: 20),

                    // Face Shape Probability Chart
                    if (_getFaceShapeProbabilities().isNotEmpty) ...[
                      FaceShapeProbabilityChart(
                        data: _getFaceShapeProbabilities(),
                      ),
                      const SizedBox(height: 20),
                    ],



                    // Proportionality Metrics Chart
                    if (_getProportionalityMetrics().isNotEmpty) ...[
                      ProportionalityMetricsChart(
                        data: _getProportionalityMetrics(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Images Section - chỉ hiển thị khi có ảnh đánh dấu đặc điểm
                    if (annotatedImagePath != null)
                      _buildImagesSection(),

                    const SizedBox(height: 20),

                    // Action Buttons
                    _buildActionButtons(context),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
              const Expanded(
                child: Text(
                  'Kết quả phân tích',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () => _shareResults(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🎯 Phân tích tướng học AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildMainResultsCard() {
    final faceShape = _getPrimaryFaceShape();
    final harmonyScore = _getHarmonyScoreForDisplay();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Quality Rating based on harmony score
          if (harmonyScore != null)
            _buildQualityRating(harmonyScore),

          if (harmonyScore != null)
            const SizedBox(height: 20),

          // Face Shape if available
          if (faceShape != null && faceShape != 'Unknown')
            _buildFaceShapeChip(faceShape),

          if (faceShape != null && faceShape != 'Unknown')
            const SizedBox(height: 20),

          // Quick Stats
          _buildQuickStats(),
        ],
      ),
    );
  }



  Widget _buildFaceShapeChip(String faceShape) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.face_outlined,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            _translateFaceShape(faceShape),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.analytics_outlined,
            label: 'Độ chính xác',
            value: '95%',
            color: Colors.green,
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: AppColors.surfaceVariant,
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.timer_outlined,
            label: 'Thời gian',
            value: '< 1 phút',
            color: Colors.blue,
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: AppColors.surfaceVariant,
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.psychology_outlined,
            label: 'Phân tích',
            value: 'AI',
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }



  Widget _buildAnalysisDetails() {
    final result = _getAnalysisResult();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phân tích tướng học',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Dựa trên AI và khoa học tướng học',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.surfaceVariant,
                width: 1,
              ),
            ),
            child: Text(
              result,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hình ảnh phân tích',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          if (annotatedImagePath != null) ...[
            _buildImageCard(
              'Ảnh đánh dấu đặc điểm',
              annotatedImagePath!,
              Icons.auto_fix_high,
              Colors.blue,
            ),
          ],

          // Đã xóa phần hiển thị "Báo cáo chi tiết" vì đã có ảnh đánh dấu đặc điểm
        ],
      ),
    );
  }

  Widget _buildImageCard(String title, String imageUrl, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(
                      Icons.download_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => _downloadImage(context, imageUrl),
                  ),
                ),
              ],
            ),
          ),
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: _buildImageWidget(imageUrl),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 400,
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading image...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          AppLogger.error('Failed to load image from URL: $imageUrl', error);
          return Container(
            height: 200,
            color: AppColors.surfaceVariant,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unable to load image',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please check your internet connection',
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _downloadImage(BuildContext context, String imageUrl) {
    // TODO: Implement image download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng tải xuống sẽ được cập nhật sớm'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _analyzeAgain(BuildContext context) {
    context.pop();
    context.pop(); // Go back to face scan page
  }





  String _translateFaceShape(String faceShape) {
    switch (faceShape.toLowerCase()) {
      case 'oblong':
        return 'Mặt dài';
      case 'oval':
        return 'Mặt trái xoan';
      case 'round':
        return 'Mặt tròn';
      case 'square':
        return 'Mặt vuông';
      case 'heart':
        return 'Mặt trái tim';
      case 'diamond':
        return 'Mặt kim cương';
      default:
        return faceShape;
    }
  }



  Widget _buildDataRow(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _formatKey(key),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              _formatValue(value),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    // Convert snake_case to Title Case
    return key
        .split('_')
        .map((word) => word.isNotEmpty 
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word)
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is Map || value is List) {
      return value.toString();
    }
    return value.toString();
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Primary Action - Save Results
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _saveResults(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.save_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Lưu kết quả',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        

          const SizedBox(height: 16),

          // Secondary Actions
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: OutlinedButton(
                    onPressed: () => _shareResults(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Chia sẻ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: OutlinedButton(
                    onPressed: () => _analyzeAgain(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh_outlined,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Phân tích lại',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveResults(BuildContext context) {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng lưu kết quả sẽ được cập nhật sớm'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _shareResults(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng chia sẻ sẽ được cập nhật sớm'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // Helper methods for data processing

  /// Get harmony score for display purposes
  double? _getHarmonyScoreForDisplay() {
    if (analysisResponse?.analysis?.analysisResult?.face?.proportionality?.overallHarmonyScore != null) {
      final score = analysisResponse!.analysis!.analysisResult!.face!.proportionality!.overallHarmonyScore!;
      // Convert to 0-100 scale if needed
      return score > 1 ? score : score * 100;
    }
    return legacyAnalysisData?['total_harmony_score'] as double? ?? null;
  }

  /// Build quality rating widget
  Widget _buildQualityRating(double score) {
    String rating;
    Color color;
    IconData icon;

    if (score >= 70) {
      rating = 'Cao';
      color = const Color(0xFF4CAF50);
      icon = Icons.star;
    } else if (score >= 50) {
      rating = 'Khá';
      color = const Color(0xFF8BC34A);
      icon = Icons.star_half;
    } else {
      rating = 'Trung bình';
      color = const Color(0xFFFF9800);
      icon = Icons.star_border;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            'Chất lượng phân tích: $rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String? _getPrimaryFaceShape() {
    if (analysisResponse?.analysis?.analysisResult?.face?.shape?.primary != null) {
      return analysisResponse!.analysis!.analysisResult!.face!.shape!.primary;
    }
    return legacyAnalysisData?['face_shape'] as String?;
  }

  List<FaceShapeProbabilityData> _getFaceShapeProbabilities() {
    final probabilities = analysisResponse?.analysis?.analysisResult?.face?.shape?.probabilities;
    if (probabilities != null) {
      return ChartDataProcessor.processFaceShapeProbabilities(probabilities);
    }
    return [];
  }



  List<ProportionalityMetricData> _getProportionalityMetrics() {
    final metrics = analysisResponse?.analysis?.analysisResult?.face?.proportionality?.metrics;
    if (metrics != null) {
      return ChartDataProcessor.processProportionalityMetrics(
        metrics.map((m) => m.toJson()).toList(),
      );
    }
    return [];
  }

  String _getAnalysisResult() {
    if (analysisResponse?.analysis?.result != null) {
      return analysisResponse!.analysis!.result!;
    }
    return legacyAnalysisData?['result'] as String? ?? 'Không có kết quả phân tích';
  }
}
