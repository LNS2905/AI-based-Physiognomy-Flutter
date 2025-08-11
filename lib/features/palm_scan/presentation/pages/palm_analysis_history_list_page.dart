import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../data/models/palm_analysis_server_model.dart';
import 'palm_analysis_results_page.dart';
import '../../data/models/palm_analysis_response_model.dart';

/// Page to display list of palm analysis history from server
class PalmAnalysisHistoryListPage extends StatefulWidget {
  const PalmAnalysisHistoryListPage({super.key});

  @override
  State<PalmAnalysisHistoryListPage> createState() => _PalmAnalysisHistoryListPageState();
}

class _PalmAnalysisHistoryListPageState extends State<PalmAnalysisHistoryListPage> {
  List<PalmAnalysisServerModel> _historyItems = [];
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
      final history = await provider.getPalmAnalysisHistory();
      
      setState(() {
        _historyItems = history;
        _isLoading = false;
      });
      
      AppLogger.info('Loaded ${history.length} palm analysis history items');
    } catch (e) {
      setState(() {
        _errorMessage = 'Có lỗi xảy ra khi tải lịch sử: ${e.toString()}';
        _isLoading = false;
      });
      AppLogger.error('Error loading palm analysis history', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Lịch Sử Phân Tích Vân Tay',
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
              'Chưa có lịch sử phân tích vân tay',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy thực hiện phân tích vân tay đầu tiên của bạn',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.back_hand),
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

  Widget _buildHistoryCard(PalmAnalysisServerModel item) {
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
                      'Phân tích vân tay #${item.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(item.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLineIndicators(item),
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

  Widget _buildLineIndicators(PalmAnalysisServerModel item) {
    final lines = [
      {'name': 'Tim', 'detected': item.detectedHeartLine == 1, 'color': AppColors.accent},
      {'name': 'Trí', 'detected': item.detectedHeadLine == 1, 'color': AppColors.primary},
      {'name': 'Đời', 'detected': item.detectedLifeLine == 1, 'color': AppColors.success},
      {'name': 'Số phận', 'detected': item.detectedFateLine == 1, 'color': AppColors.warning},
    ];

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: lines.map((line) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: line['detected'] as bool
                ? (line['color'] as Color).withValues(alpha: 0.1)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: line['detected'] as bool
                  ? (line['color'] as Color).withValues(alpha: 0.3)
                  : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          child: Text(
            line['name'] as String,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: line['detected'] as bool
                  ? line['color'] as Color
                  : AppColors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToDetail(PalmAnalysisServerModel item) {
    // Convert server model to response model for compatibility with existing results page
    final responseModel = _convertServerModelToResponseModel(item);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PalmAnalysisResultsPage(
          palmResult: responseModel,
          annotatedImagePath: item.annotatedImage,
        ),
      ),
    );
  }

  /// Convert PalmAnalysisServerModel to PalmAnalysisResponseModel for display
  PalmAnalysisResponseModel _convertServerModelToResponseModel(PalmAnalysisServerModel serverModel) {
    return PalmAnalysisResponseModel(
      status: 'success',
      message: 'Palm analysis completed',
      userId: serverModel.userId.toString(),
      processedAt: serverModel.createdAt,
      handsDetected: serverModel.palmLinesDetected,
      processingTime: 0.0,
      analysisType: 'palm_analysis',
      annotatedImageUrl: serverModel.annotatedImage,
      comparisonImageUrl: null,
      analysis: PalmAnalysisDataModel(
        handsDetected: serverModel.palmLinesDetected,
        handsData: [],
        measurements: {},
        palmLines: {
          'heart': serverModel.detectedHeartLine.toDouble(),
          'head': serverModel.detectedHeadLine.toDouble(),
          'life': serverModel.detectedLifeLine.toDouble(),
          'fate': serverModel.detectedFateLine.toDouble(),
        },
        fingerAnalysis: {},
      ),
      measurementsSummary: MeasurementsSummaryModel(
        averagePalmWidth: serverModel.imageWidth,
        averageHandLength: serverModel.imageHeight,
        totalHands: serverModel.palmLinesDetected,
        leftHands: 0,
        rightHands: 0,
        palmTypes: [],
        confidenceScores: {
          'overall': 0.8,
        },
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
