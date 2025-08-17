import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../palm_scan/presentation/pages/palm_analysis_results_page.dart';
import '../../../palm_scan/presentation/pages/palm_analysis_history_results_page.dart';

import '../../../palm_scan/data/models/palm_analysis_server_model.dart';
import '../../../palm_scan/data/models/palm_analysis_response_model.dart';
import '../../data/models/history_item_model.dart';
import '../providers/history_provider.dart';

/// Detail page for palm analysis history item
class PalmAnalysisHistoryDetailPage extends StatefulWidget {
  final String historyId;

  const PalmAnalysisHistoryDetailPage({
    super.key,
    required this.historyId,
  });

  @override
  State<PalmAnalysisHistoryDetailPage> createState() => _PalmAnalysisHistoryDetailPageState();
}

class _PalmAnalysisHistoryDetailPageState extends State<PalmAnalysisHistoryDetailPage> {
  PalmAnalysisHistoryModel? _historyItem;

  @override
  void initState() {
    super.initState();
    _loadHistoryItem();
  }

  void _loadHistoryItem() {
    final provider = context.read<HistoryProvider>();
    final item = provider.getHistoryItemById(widget.historyId);
    
    if (item is PalmAnalysisHistoryModel) {
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
                  'Chi tiết phân tích vân tay',
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
                  color: AppColors.secondary.withValues(alpha: 0.1),
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
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.secondary,
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
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
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
    final analysis = _historyItem!.analysisResult;
    
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
          
          _buildAnalysisItem(
            'Bàn tay phân tích',
            '1 bàn tay',
            'Phân tích được thực hiện trên 1 bàn tay',
          ),
          const SizedBox(height: 8),
          
          _buildAnalysisItem(
            'Thời gian xử lý',
            '${analysis.processingTime.toStringAsFixed(1)}s',
            'Thời gian để hoàn thành phân tích',
          ),
          const SizedBox(height: 8),
          
          if (analysis.measurementsSummary != null) ...[
            _buildAnalysisItem(
              'Tổng số bàn tay',
              '${analysis.measurementsSummary!.totalHands}',
              'Tổng số bàn tay được phát hiện',
            ),
            const SizedBox(height: 8),

            _buildAnalysisItem(
              'Chiều dài trung bình',
              '${analysis.measurementsSummary!.averageHandLength.toStringAsFixed(1)}mm',
              'Chiều dài trung bình của bàn tay',
            ),
            const SizedBox(height: 8),

            _buildAnalysisItem(
              'Độ tin cậy tổng thể',
              '${((analysis.measurementsSummary!.confidenceScores['overall'] ?? 0) * 100).toStringAsFixed(1)}%',
              'Độ tin cậy của phân tích',
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
              color: AppColors.secondary,
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
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // View comparison button
        if (_historyItem!.comparisonImageUrl != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _viewComparison,
              icon: const Icon(Icons.compare),
              label: const Text('Xem so sánh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary),
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
    // Check if this is a server-based analysis (has metadata with server_id)
    final metadata = _historyItem!.metadata;
    if (metadata != null && metadata.containsKey('server_id')) {
      // This is from server API, navigate to the new detailed page
      _navigateToServerAnalysisDetail();
    } else {
      // This is from the old analysis flow, use the original page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PalmAnalysisResultsPage(
            palmResult: _historyItem!.analysisResult,
            annotatedImagePath: _historyItem!.annotatedImageUrl,
          ),
        ),
      );
    }
  }

  void _navigateToServerAnalysisDetail() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get the server analysis data from the provider
      final provider = context.read<HistoryProvider>();
      final serverId = _historyItem!.metadata?['server_id'];

      if (serverId == null) {
        Navigator.of(context).pop(); // Close loading dialog
        _showError('Không thể tải chi tiết phân tích');
        return;
      }

      // Get all palm analysis history from server
      final allAnalyses = await provider.getPalmAnalysisHistory();

      Navigator.of(context).pop(); // Close loading dialog

      if (allAnalyses.isNotEmpty) {
        try {
          // Find the specific analysis by server ID
          final targetAnalysis = allAnalyses.firstWhere(
            (analysis) => analysis.id == int.parse(serverId.toString()),
          );

          // Use the new dedicated history results page with the specific analysis
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PalmAnalysisHistoryResultsPage(
                analysisData: targetAnalysis,
              ),
            ),
          );
        } catch (e) {
          // Analysis not found in server data, use fallback
          AppLogger.warning('Analysis with ID $serverId not found in server data');
          _showError('Không tìm thấy dữ liệu phân tích trên server');
        }
      } else {
        // No server data available, use fallback
        AppLogger.warning('No server data available, using local data');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PalmAnalysisResultsPage(
              palmResult: _historyItem!.analysisResult,
              annotatedImagePath: _historyItem!.annotatedImageUrl,
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog if still open
      AppLogger.error('Error navigating to server analysis detail', e);
      _showError('Có lỗi xảy ra khi tải chi tiết phân tích');
    }
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

  PalmAnalysisServerModel _createServerModelFromHistoryItem(PalmAnalysisHistoryModel historyItem) {
    // Create a server model from the history item data
    // This is a temporary solution - ideally you'd fetch from the server
    return PalmAnalysisServerModel(
      id: int.tryParse(historyItem.metadata?['server_id']?.toString() ?? '0') ?? 0,
      userId: 18, // Default user ID - should be from auth provider
      annotatedImage: historyItem.annotatedImageUrl ?? '',
      palmLinesDetected: historyItem.analysisResult.handsDetected,
      detectedHeartLine: historyItem.analysisResult.analysis?.palmLines['heart']?.round() ?? 0,
      detectedHeadLine: historyItem.analysisResult.analysis?.palmLines['head']?.round() ?? 0,
      detectedLifeLine: historyItem.analysisResult.analysis?.palmLines['life']?.round() ?? 0,
      detectedFateLine: historyItem.analysisResult.analysis?.palmLines['fate']?.round() ?? 0,
      targetLines: 'heart,head,life,fate',
      imageHeight: historyItem.analysisResult.measurementsSummary?.averageHandLength ?? 480.0,
      imageWidth: historyItem.analysisResult.measurementsSummary?.averagePalmWidth ?? 640.0,
      imageChannels: 3.0,
      summaryText: 'Palm analysis completed successfully. Analysis provides insights into personality traits and life patterns based on traditional palmistry principles.',
      createdAt: historyItem.createdAt.toIso8601String(),
      updatedAt: historyItem.updatedAt.toIso8601String(),
      interpretations: [], // Empty for now - would be populated from server
      lifeAspects: [], // Empty for now - would be populated from server
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _viewComparison() {
    // TODO: Implement comparison view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng xem so sánh sẽ được triển khai sớm'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
