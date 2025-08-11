import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/palm_analysis_server_model.dart';

/// Page to display palm analysis results from history (server data)
/// This is a separate page from the current analysis results to avoid interference
class PalmAnalysisHistoryResultsPage extends StatefulWidget {
  final PalmAnalysisServerModel analysisData;

  const PalmAnalysisHistoryResultsPage({
    super.key,
    required this.analysisData,
  });

  @override
  State<PalmAnalysisHistoryResultsPage> createState() => _PalmAnalysisHistoryResultsPageState();
}

class _PalmAnalysisHistoryResultsPageState extends State<PalmAnalysisHistoryResultsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    AppLogger.info('Palm analysis history results page initialized');
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
          'Kết Quả Phân Tích Vân Tay',
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
            Tab(text: 'Giải Nghĩa'),
            Tab(text: 'Hình Ảnh'),
          ],
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildInterpretationTab(),
            _buildImagesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildInterpretationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildPalmLinesSection(),
          const SizedBox(height: 16),
          _buildLifeAspectsSection(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('✋', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tóm tắt phân tích',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Phân tích vào ${_formatDate(widget.analysisData.createdAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.analysisData.summaryText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalysisStats(),
        ],
      ),
    );
  }

  Widget _buildAnalysisStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Đường tim',
            widget.analysisData.detectedHeartLine == 1 ? 'Có' : 'Không',
            widget.analysisData.detectedHeartLine == 1 ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            'Đường trí',
            widget.analysisData.detectedHeadLine == 1 ? 'Có' : 'Không',
            widget.analysisData.detectedHeadLine == 1 ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            'Đường đời',
            widget.analysisData.detectedLifeLine == 1 ? 'Có' : 'Không',
            widget.analysisData.detectedLifeLine == 1 ? AppColors.success : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            'Đường số phận',
            widget.analysisData.detectedFateLine == 1 ? 'Có' : 'Không',
            widget.analysisData.detectedFateLine == 1 ? AppColors.warning : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPalmLinesSection() {
    if (widget.analysisData.interpretations.isEmpty) {
      return _buildEmptyCard('Không có dữ liệu giải nghĩa đường vân tay');
    }

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
            'Giải nghĩa đường vân tay',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.analysisData.interpretations.map((interpretation) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLineInterpretationCard(interpretation),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLineInterpretationCard(InterpretationServerModel interpretation) {
    final lineInfo = _getLineInfo(interpretation.lineType);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: lineInfo['color'].withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                lineInfo['icon'],
                color: lineInfo['color'],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lineInfo['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: lineInfo['color'],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(interpretation.confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hình dạng: ${interpretation.pattern}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            interpretation.meaning,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeAspectsSection() {
    if (widget.analysisData.lifeAspects.isEmpty) {
      return _buildEmptyCard('Không có dữ liệu về các khía cạnh cuộc sống');
    }

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
            'Các khía cạnh cuộc sống',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.analysisData.lifeAspects.map((aspect) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLifeAspectCard(aspect),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLifeAspectCard(LifeAspectServerModel aspect) {
    final aspectInfo = _getAspectInfo(aspect.aspect);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: aspectInfo['color'].withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                aspectInfo['icon'],
                color: aspectInfo['color'],
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                aspectInfo['name'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: aspectInfo['color'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            aspect.content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hình ảnh phân tích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildAnnotatedImage(),
        ],
      ),
    );
  }

  Widget _buildAnnotatedImage() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: CachedNetworkImage(
          imageUrl: widget.analysisData.annotatedImage,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 400,
            color: AppColors.surfaceVariant,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 400,
            color: AppColors.surfaceVariant,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Không thể tải hình ảnh',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.info_outline,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getLineInfo(String lineType) {
    switch (lineType.toLowerCase()) {
      case 'heart':
        return {
          'name': 'Đường Tim',
          'icon': Icons.favorite,
          'color': AppColors.accent,
        };
      case 'head':
        return {
          'name': 'Đường Trí',
          'icon': Icons.psychology,
          'color': AppColors.primary,
        };
      case 'life':
        return {
          'name': 'Đường Đời',
          'icon': Icons.timeline,
          'color': AppColors.success,
        };
      case 'fate':
        return {
          'name': 'Đường Số Phận',
          'icon': Icons.star,
          'color': AppColors.warning,
        };
      default:
        return {
          'name': lineType.toUpperCase(),
          'icon': Icons.linear_scale,
          'color': AppColors.textSecondary,
        };
    }
  }

  Map<String, dynamic> _getAspectInfo(String aspect) {
    switch (aspect.toLowerCase()) {
      case 'health':
        return {
          'name': 'Sức khỏe',
          'icon': Icons.health_and_safety,
          'color': AppColors.success,
        };
      case 'career':
        return {
          'name': 'Sự nghiệp',
          'icon': Icons.work,
          'color': AppColors.primary,
        };
      case 'relationships':
        return {
          'name': 'Mối quan hệ',
          'icon': Icons.people,
          'color': AppColors.accent,
        };
      case 'personality':
        return {
          'name': 'Tính cách',
          'icon': Icons.person,
          'color': AppColors.secondary,
        };
      default:
        return {
          'name': aspect.toUpperCase(),
          'icon': Icons.info,
          'color': AppColors.textSecondary,
        };
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
