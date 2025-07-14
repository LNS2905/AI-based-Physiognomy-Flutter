import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/palm_analysis_response_model.dart';

/// Page to display palm analysis results
class PalmAnalysisResultsPage extends StatefulWidget {
  final PalmAnalysisResponseModel palmResult;
  final String? annotatedImagePath;
  final String? comparisonImagePath;

  const PalmAnalysisResultsPage({
    super.key,
    required this.palmResult,
    this.annotatedImagePath,
    this.comparisonImagePath,
  });

  @override
  State<PalmAnalysisResultsPage> createState() => _PalmAnalysisResultsPageState();
}

class _PalmAnalysisResultsPageState extends State<PalmAnalysisResultsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    AppLogger.info('Palm analysis results page initialized');
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
            Tab(text: 'Tổng Quan'),
            Tab(text: 'Đường Chỉ Tay'),
            Tab(text: 'Hình Ảnh'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPalmLinesTab(),
          _buildImagesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildMeasurementsCard(),
          const SizedBox(height: 16),
          _buildFingersCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.back_hand,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Text(
                'Tóm Tắt Phân Tích',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryItem('Số bàn tay phát hiện', '${widget.palmResult.handsDetected}'),
          _buildSummaryItem('Thời gian xử lý', '${widget.palmResult.processingTime.toStringAsFixed(2)}s'),
          _buildSummaryItem('Trạng thái', widget.palmResult.status),
          _buildSummaryItem('Thời gian hoàn thành', _formatDateTime(widget.palmResult.processedAt)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsCard() {
    final measurementsSummary = widget.palmResult.measurementsSummary;

    if (measurementsSummary == null) {
      return _buildEmptyCard('Không có dữ liệu đo lường');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đo Lường Bàn Tay',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildMeasurementItem('Tổng số bàn tay', '${measurementsSummary.totalHands}'),
          _buildMeasurementItem('Bàn tay trái', '${measurementsSummary.leftHands}'),
          _buildMeasurementItem('Bàn tay phải', '${measurementsSummary.rightHands}'),
          if (measurementsSummary.averageHandLength > 0)
            _buildMeasurementItem('Chiều dài trung bình', '${measurementsSummary.averageHandLength.toStringAsFixed(1)} px'),
          if (measurementsSummary.averagePalmWidth > 0)
            _buildMeasurementItem('Chiều rộng trung bình', '${measurementsSummary.averagePalmWidth.toStringAsFixed(1)} px'),
        ],
      ),
    );
  }

  Widget _buildMeasurementItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFingersCard() {
    final palmDetection = widget.palmResult.analysis?.palmDetection;

    if (palmDetection == null || palmDetection.handsData == null || palmDetection.handsData!.isEmpty) {
      return _buildEmptyCard('Không có dữ liệu phân tích ngón tay');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân Tích Ngón Tay',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...palmDetection.handsData!.map((hand) => _buildHandItem(hand)),
        ],
      ),
    );
  }

  Widget _buildHandItem(HandDataModel hand) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bàn tay ${hand.handSide ?? 'không xác định'} (ID: ${hand.handId ?? 'N/A'})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (hand.keypoints != null && hand.keypoints!.isNotEmpty)
            Text(
              'Số điểm đặc trưng: ${hand.keypoints!.keys.length}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPalmLinesTab() {
    final palmLinesData = widget.palmResult.analysis?.palmLines;

    if (palmLinesData == null || palmLinesData.isEmpty) {
      return Center(
        child: _buildEmptyCard('Không có dữ liệu đường chỉ tay'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPalmLineCard('Thông tin đường chỉ tay', 'Dữ liệu có sẵn', Icons.info),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Dữ liệu đường chỉ tay: ${palmLinesData.toString()}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalmLineCard(String title, String? description, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description ?? 'Chưa có thông tin phân tích',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.annotatedImagePath != null)
            _buildImageCard('Ảnh Đã Phân Tích', widget.annotatedImagePath!),
          if (widget.annotatedImagePath != null && widget.comparisonImagePath != null)
            const SizedBox(height: 16),
          if (widget.comparisonImagePath != null)
            _buildImageCard('Ảnh So Sánh', widget.comparisonImagePath!),
          if (widget.annotatedImagePath == null && widget.comparisonImagePath == null)
            _buildEmptyCard('Không có hình ảnh kết quả'),
        ],
      ),
    );
  }

  Widget _buildImageCard(String title, String imagePath) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
              imageUrl: imagePath,
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

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
}
