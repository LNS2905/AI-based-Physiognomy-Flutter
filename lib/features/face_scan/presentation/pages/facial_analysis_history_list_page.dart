import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../data/models/facial_analysis_server_model.dart';
import 'facial_analysis_history_results_page.dart';

/// Page to display list of facial analysis history from server
class FacialAnalysisHistoryListPage extends StatefulWidget {
  const FacialAnalysisHistoryListPage({super.key});

  @override
  State<FacialAnalysisHistoryListPage> createState() => _FacialAnalysisHistoryListPageState();
}

class _FacialAnalysisHistoryListPageState extends State<FacialAnalysisHistoryListPage> {
  List<FacialAnalysisServerModel> _historyItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<HistoryProvider>();
      final history = await provider.getFacialAnalysisHistory();
      
      setState(() {
        _historyItems = history;
        _isLoading = false;
      });
      
      AppLogger.info('Loaded ${history.length} facial analysis history items');
    } catch (e) {
      setState(() {
        _errorMessage = 'Có lỗi xảy ra khi tải lịch sử: ${e.toString()}';
        _isLoading = false;
      });
      AppLogger.error('Error loading facial analysis history', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Lịch Sử Phân Tích Gương Mặt',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_historyItems.isEmpty) {
      return _buildEmptyState();
    }

    return _buildHistoryList();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có lịch sử phân tích gương mặt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy thực hiện phân tích gương mặt đầu tiên của bạn',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.face),
              label: const Text('Bắt đầu phân tích'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: _historyItems.length,
        itemBuilder: (context, index) {
          final item = _historyItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildHistoryCard(item),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(FacialAnalysisServerModel item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(item),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              // Thumbnail image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item.annotatedImage,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: AppColors.surfaceVariant,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: AppColors.surfaceVariant,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phân tích gương mặt #${item.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(item.createdAt ?? item.processedAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFaceInfoRow(item),
                  ],
                ),
              ),
              
              // Arrow icon
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaceInfoRow(FacialAnalysisServerModel item) {
    return Row(
      children: [
        // Face shape badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.face,
                size: 12,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                item.faceShape,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        
        // Harmony score badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getHarmonyColor(item.harmonyScore).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getHarmonyColor(item.harmonyScore).withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 12,
                color: AppColors.accent,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.harmonyScore.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _getHarmonyColor(item.harmonyScore),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getHarmonyColor(double score) {
    if (score >= 70) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  void _navigateToDetail(FacialAnalysisServerModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FacialAnalysisHistoryResultsPage(
          analysisData: item,
        ),
      ),
    );
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