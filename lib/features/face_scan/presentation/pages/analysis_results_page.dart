import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../data/models/chart_data_models.dart';
import '../../data/models/cloudinary_analysis_response_model.dart';
import '../widgets/face_shape_probability_chart.dart';
import '../providers/face_scan_provider.dart';

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
      body: Stack(
        children: [
          SafeArea(
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

                          // Images Section - chỉ hiển thị khi có ảnh đánh dấu đặc điểm
                          if (annotatedImagePath != null)
                            _buildImagesSection(),

                          const SizedBox(height: 20),

                          // Action Buttons
                          _buildActionButtons(context),

                          const SizedBox(height: 20),

                          // AI Disclaimer
                          _buildAIDisclaimer(),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
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
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: StandardBackButton(
                  isWhiteVariant: true,
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
    // final faceShape = _getPrimaryFaceShape(); // Currently unused
    // final harmonyScore = _getHarmonyScoreForDisplay(); // Currently unused

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
          // Modern Stats Grid
          _buildModernStatsGrid(),
        ],
      ),
    );
  }



  Widget _buildFaceShapeChip(String faceShape) {
    final translatedShape = _translateFaceShape(faceShape);
    final probability = _getFaceShapePrimaryProbability(faceShape);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.face_outlined,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dạng khuôn mặt',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    translatedShape,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (probability != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Độ tương đồng: ${probability.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }





  Widget _buildModernStatsGrid() {
    final harmonyScore = _getHarmonyScoreForDisplay();
    final faceGoldenRatio = _getFaceGoldenRatio();
    final faceShape = _getPrimaryFaceShape();
    final faceShapeProbabilities = _getFaceShapeProbabilities();
    final topProbability = faceShapeProbabilities.isNotEmpty
        ? faceShapeProbabilities.first.probability
        : null;

    return Column(
      children: [
        // Top Row - Main Metrics
        Row(
          children: [
            // Harmony Score
            if (harmonyScore != null)
              Expanded(
                child: _buildStatCard(
                  title: 'Điểm hài hòa',
                  subtitle: 'Tổng thể',
                  value: '${harmonyScore.toStringAsFixed(1)}',
                  unit: '/100',
                  icon: Icons.balance_outlined,
                  color: _getScoreColor(harmonyScore),
                  gradient: [
                    const Color(0xFFE8F5E8),
                    const Color(0xFFD4F1D4),
                  ],
                ),
              ),

            if (harmonyScore != null && faceGoldenRatio != null)
              const SizedBox(width: 16),

            // Golden Ratio
            if (faceGoldenRatio != null)
              Expanded(
                child: _buildStatCard(
                  title: 'Tỷ lệ vàng',
                  subtitle: 'Khuôn mặt',
                  value: '${faceGoldenRatio.toStringAsFixed(1)}',
                  unit: '/100',
                  icon: Icons.crop_portrait_outlined,
                  color: _getScoreColor(faceGoldenRatio),
                  gradient: [
                    const Color(0xFFFFF8E1),
                    const Color(0xFFFFF3C4),
                  ],
                ),
              ),
          ],
        ),

        // Bottom Row - Face Shape Info
        if (faceShape != null && faceShape != 'Unknown') ...[
          const SizedBox(height: 16),
          _buildFaceShapeCard(faceShape, topProbability),
        ],
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String subtitle,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(height: 16),

          // Title & Subtitle
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          // Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaceShapeCard(String faceShape, double? probability) {
    final translatedShape = _translateFaceShape(faceShape);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF4E6),
            const Color(0xFFFFE8CC),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF9800).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.face_retouching_natural,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dạng khuôn mặt',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  translatedShape,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (probability != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Độ tương đồng: ${probability.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildKeyMetricsSection() {
    final harmonyScore = _getHarmonyScoreForDisplay();
    final faceGoldenRatio = _getFaceGoldenRatio();

    // Only show if we have at least one metric
    if (harmonyScore == null && faceGoldenRatio == null) {
      return const SizedBox.shrink();
    }

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
                  Icons.analytics_outlined,
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
                      'Chỉ số quan trọng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Các chỉ số chính từ phân tích AI',
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

          // Metrics Grid
          if (harmonyScore != null || faceGoldenRatio != null)
            Row(
              children: [
                if (harmonyScore != null) ...[
                  Expanded(
                    child: _buildMetricCard(
                      'Điểm hài hòa tổng thể',
                      '${harmonyScore.toStringAsFixed(1)}/100',
                      _getScoreColor(harmonyScore),
                      Icons.balance_outlined,
                    ),
                  ),
                ],
                if (harmonyScore != null && faceGoldenRatio != null)
                  const SizedBox(width: 16),
                if (faceGoldenRatio != null) ...[
                  Expanded(
                    child: _buildMetricCard(
                      'Tỷ lệ vàng khuôn mặt',
                      '${faceGoldenRatio.toStringAsFixed(1)}/100',
                      _getScoreColor(faceGoldenRatio),
                      Icons.crop_portrait_outlined,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.surfaceVariant,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kết quả phân tích chi tiết',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  result,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Hình ảnh phân tích',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (annotatedImagePath != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildImageCard(
              'Ảnh đánh dấu đặc điểm',
              annotatedImagePath!,
              Icons.auto_fix_high,
              Colors.blue,
            ),
          ),
        ],

        // Đã xóa phần hiển thị "Báo cáo chi tiết" vì đã có ảnh đánh dấu đặc điểm
      ],
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
    if (imageUrl.startsWith('data:image')) {
      final base64String = imageUrl.split(',')[1];
      final bytes = base64Decode(base64String);
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 200,
          maxHeight: 400,
        ),
        child: Image.memory(
          bytes,
          fit: BoxFit.fitWidth,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            AppLogger.error('Failed to decode base64 image', error);
            return Container(
              height: 200,
              color: AppColors.surfaceVariant,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Không thể hiển thị hình ảnh',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
    
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 400,
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.fitWidth,
        width: double.infinity,
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
                    'Đang tải hình ảnh...',
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
                    'Không thể tải hình ảnh',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vui lòng kiểm tra kết nối internet của bạn',
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

  void _saveResults(BuildContext context) async {
    final provider = context.read<FaceScanProvider>();
    
    // Check if there's data to save
    if (analysisResponse == null && provider.currentCloudinaryResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có dữ liệu để lưu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get the analysis data to save
      final dataToSave = analysisResponse ?? provider.currentCloudinaryResult!;
      
      // Perform save using existing method
      await provider.saveFacialAnalysis(dataToSave);
      final success = true;

      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show result
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? '✅ Đã lưu kết quả phân tích thành công'
                : '❌ Không thể lưu kết quả. Vui lòng thử lại',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Hide loading and show error
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi khi lưu: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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

    if (score >= 80) {
      rating = 'Xuất sắc';
      color = const Color(0xFF4CAF50);
      icon = Icons.star;
    } else if (score >= 70) {
      rating = 'Tốt';
      color = const Color(0xFF8BC34A);
      icon = Icons.star;
    } else if (score >= 50) {
      rating = 'Khá';
      color = const Color(0xFFFF9800);
      icon = Icons.star_half;
    } else {
      rating = 'Trung bình';
      color = const Color(0xFFFF5722);
      icon = Icons.star_border;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Điểm hài hòa tổng thể',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    '${score.toStringAsFixed(1)}/100',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      rating,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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

  double? _getFaceShapePrimaryProbability(String faceShape) {
    final probabilities = analysisResponse?.analysis?.analysisResult?.face?.shape?.probabilities;
    if (probabilities != null && probabilities.containsKey(faceShape)) {
      return probabilities[faceShape];
    }
    return null;
  }

  double? _getFaceGoldenRatio() {
    final harmonyScores = analysisResponse?.analysis?.analysisResult?.face?.proportionality?.harmonyScores;
    if (harmonyScores != null && harmonyScores.containsKey('Face Golden Ratio')) {
      return harmonyScores['Face Golden Ratio'];
    }
    return null;
  }

  Color _getScoreColor(double score) {
    if (score >= 80) {
      return const Color(0xFF4CAF50); // Green
    } else if (score >= 70) {
      return const Color(0xFF8BC34A); // Light Green
    } else if (score >= 50) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFFF5722); // Red
    }
  }

  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
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

  Widget _buildAIDisclaimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.withOpacity(0.1),
              Colors.orange.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LƯU Ý QUAN TRỌNG',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kết quả phân tích khuôn mặt này được tạo bởi trí tuệ nhân tạo (AI) và chỉ mang tính chất giải trí, tham khảo. Các thông tin được cung cấp không có cơ sở khoa học chứng minh và không nên được dùng làm căn cứ để đưa ra các quyết định quan trọng trong cuộc sống.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vui lòng kiểm tra kỹ và tham khảo ý kiến chuyên gia nếu cần thiết.',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
