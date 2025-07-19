import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../face_scan/presentation/pages/analysis_results_page.dart';
import '../../data/models/history_item_model.dart';
import '../providers/history_provider.dart';

/// Detail page for face analysis history item
class FaceAnalysisHistoryDetailPage extends StatefulWidget {
  final String historyId;

  const FaceAnalysisHistoryDetailPage({
    super.key,
    required this.historyId,
  });

  @override
  State<FaceAnalysisHistoryDetailPage> createState() => _FaceAnalysisHistoryDetailPageState();
}

class _FaceAnalysisHistoryDetailPageState extends State<FaceAnalysisHistoryDetailPage> {
  FaceAnalysisHistoryModel? _historyItem;

  @override
  void initState() {
    super.initState();
    _loadHistoryItem();
  }

  void _loadHistoryItem() {
    final provider = context.read<HistoryProvider>();
    final item = provider.getHistoryItemById(widget.historyId);
    
    if (item is FaceAnalysisHistoryModel) {
      setState(() {
        _historyItem = item;
      });
    } else {
      AppLogger.error('History item not found or wrong type: ${widget.historyId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_historyItem == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          ),
          title: const Text(
            'Chi tiết phân tích',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'Không tìm thấy mục lịch sử',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 16),
                    _buildImageSection(),
                    const SizedBox(height: 16),
                    _buildAnalysisSection(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chi tiết phân tích khuôn mặt',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _historyItem!.formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Favorite button
          Consumer<HistoryProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: () => provider.toggleFavorite(_historyItem!.id),
                icon: Icon(
                  _historyItem!.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _historyItem!.isFavorite ? AppColors.accent : AppColors.textSecondary,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: _historyItem!.isFavorite 
                      ? AppColors.accent.withValues(alpha: 0.1)
                      : AppColors.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
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
                  child: Text('👤', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _historyItem!.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _historyItem!.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (_historyItem!.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _historyItem!.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageSection() {
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
            'Hình ảnh phân tích',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          if (_historyItem!.annotatedImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              child: CachedNetworkImage(
                imageUrl: _historyItem!.annotatedImageUrl!,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 300,
                  color: AppColors.surfaceVariant,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 300,
                  color: AppColors.surfaceVariant,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
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
                      'Không có hình ảnh',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection() {
    final analysis = _historyItem!.analysisResult.analysis;
    
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
            'Kết quả phân tích',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          if (analysis?.analysisResult?.face?.shape != null) ...[
            _buildAnalysisItem(
              'Dạng khuôn mặt',
              analysis!.analysisResult!.face!.shape!.primary ?? 'Không xác định',
              'Phân tích dạng khuôn mặt từ hình ảnh',
            ),
            const SizedBox(height: 8),
          ],

          if (analysis?.analysisResult?.face?.proportionality != null) ...[
            _buildAnalysisItem(
              'Điểm hài hòa',
              '${((analysis!.analysisResult!.face!.proportionality!.overallHarmonyScore ?? 0) * 100).toStringAsFixed(1)}/100',
              'Đánh giá tổng thể về tỷ lệ khuôn mặt',
            ),
            const SizedBox(height: 8),
          ],

          if (analysis?.result != null) ...[
            _buildAnalysisItem(
              'Kết quả phân tích',
              analysis!.result ?? 'Không có kết quả',
              'Tóm tắt kết quả phân tích',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String title, String value, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // View full analysis button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _viewFullAnalysis,
            icon: const Icon(Icons.analytics),
            label: const Text('Xem phân tích đầy đủ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Download report button
        if (_historyItem!.reportUrl != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _downloadReport,
              icon: const Icon(Icons.download),
              label: const Text('Tải báo cáo PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _viewFullAnalysis() {
    // Navigate to the full analysis results page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnalysisResultsPage(
          analysisResponse: _historyItem!.analysisResult,
          annotatedImagePath: _historyItem!.annotatedImageUrl,
          reportImagePath: _historyItem!.reportUrl,
        ),
      ),
    );
  }

  void _downloadReport() {
    // TODO: Implement report download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng tải báo cáo sẽ được triển khai sớm'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
