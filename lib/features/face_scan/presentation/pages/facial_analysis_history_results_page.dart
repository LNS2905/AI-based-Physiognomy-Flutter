import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/facial_analysis_server_model.dart';

/// Page to display facial analysis results from history (server data)
class FacialAnalysisHistoryResultsPage extends StatefulWidget {
  final FacialAnalysisServerModel analysisData;

  const FacialAnalysisHistoryResultsPage({
    super.key,
    required this.analysisData,
  });

  @override
  State<FacialAnalysisHistoryResultsPage> createState() => _FacialAnalysisHistoryResultsPageState();
}

class _FacialAnalysisHistoryResultsPageState extends State<FacialAnalysisHistoryResultsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    AppLogger.info('Facial analysis history results page initialized');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Kết Quả Phân Tích Gương Mặt',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Phân Tích'),
            Tab(text: 'Chi Tiết'),
            Tab(text: 'Hình Ảnh'),
          ],
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAnalysisTab(),
            _buildDetailsTab(),
            _buildImagesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultTextCard(),
          const SizedBox(height: 16),
          _buildFaceShapeCard(),
          const SizedBox(height: 16),
          _buildHarmonyScoreCard(),
        ],
      ),
    );
  }

  Widget _buildResultTextCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Phân Tích Tướng Mạo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.analysisData.resultText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceShapeCard() {
    final probabilities = widget.analysisData.probabilities;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.face,
                color: AppColors.secondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Dạng Khuôn Mặt',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Primary face shape
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.analysisData.faceShape,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Probabilities
          const Text(
            'Tỷ Lệ Các Dạng:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...probabilities.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildProbabilityBar(entry.key, entry.value),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildProbabilityBar(String label, double value) {
    final bool isPrimary = label == widget.analysisData.faceShape;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                color: isPrimary ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                color: isPrimary ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: AppColors.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            isPrimary ? AppColors.primary : AppColors.textSecondary,
          ),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildHarmonyScoreCard() {
    final harmonyScore = widget.analysisData.harmonyScore;
    final harmonyColor = _getHarmonyColor(harmonyScore);
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: harmonyColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: harmonyColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Điểm Hài Hòa Tổng Thể',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: harmonyScore / 100,
                    strokeWidth: 12,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(harmonyColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      harmonyScore.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: harmonyColor,
                      ),
                    ),
                    Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Center(
            child: Text(
              _getHarmonyDescription(harmonyScore),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: harmonyColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHarmonyDetailsCard(),
          const SizedBox(height: 16),
          _buildMetricsCard(),
        ],
      ),
    );
  }

  Widget _buildHarmonyDetailsCard() {
    final harmonyDetails = widget.analysisData.harmonyDetails;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi Tiết Điểm Hài Hòa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...harmonyDetails.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDetailItem(entry.key, entry.value),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, double value) {
    final color = _getScoreColor(value);
    
    return Row(
      children: [
        Expanded(
          child: Text(
            _translateLabel(label),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            '${value.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsCard() {
    final metrics = widget.analysisData.metrics;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Các Số Đo Khuôn Mặt',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...metrics.map((metric) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildMetricItem(metric),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildMetricItem(FacialMetricServerModel metric) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          metric.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              metric.orientation == 'horizontal' 
                ? Icons.swap_horiz 
                : Icons.swap_vert,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              '${metric.pixels.toStringAsFixed(1)} px',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${metric.percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          _buildImageCard('Ảnh Đã Phân Tích', widget.analysisData.annotatedImage),
        ],
      ),
    );
  }

  Widget _buildImageCard(String title, String imageUrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: AppColors.background,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: AppColors.background,
                child: const Center(
                  child: Icon(
                    Icons.error,
                    color: AppColors.error,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getHarmonyColor(double score) {
    if (score >= 70) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.primary;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String _getHarmonyDescription(double score) {
    if (score >= 70) return 'Rất Hài Hòa';
    if (score >= 50) return 'Khá Hài Hòa';
    if (score >= 30) return 'Trung Bình';
    return 'Cần Cải Thiện';
  }

  String _translateLabel(String label) {
    final translations = {
      'Face Golden Ratio': 'Tỷ Lệ Vàng Khuôn Mặt',
      'Outer Face Balance': 'Cân Đối Mặt Ngoài',
      'Eye Width Balance': 'Cân Đối Chiều Rộng Mắt',
      'Inter-Eye Gap': 'Khoảng Cách Giữa Hai Mắt',
      'Nose Width': 'Chiều Rộng Mũi',
      'Eye Symmetry': 'Đối Xứng Mắt',
      'Eyebrow Symmetry': 'Đối Xứng Lông Mày',
      'Forehead Height': 'Chiều Cao Trán',
      'Midface Height': 'Chiều Cao Giữa Mặt',
      'Lower Face Height': 'Chiều Cao Mặt Dưới',
      'Lower Face Balance': 'Cân Đối Mặt Dưới',
    };
    return translations[label] ?? label;
  }
}