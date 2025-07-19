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
    _tabController = TabController(length: 2, vsync: this);
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
            Tab(text: 'Giải Nghĩa'),
            Tab(text: 'Hình Ảnh'),
          ],
        ),
      ),
      body: SafeArea(
        bottom: true, // Đảm bảo có safe area ở bottom
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
    // Try to get interpretation data from the analysis response
    final analysisData = widget.palmResult.analysis;

    Map<String, dynamic>? interpretationData;

    if (analysisData != null) {
      // First try to get from palmDetection.palmLinesData with interpretation
      if (analysisData.palmDetection?.handsData != null &&
          analysisData.palmDetection!.handsData!.isNotEmpty) {
        for (var handData in analysisData.palmDetection!.handsData!) {
          final handJson = handData.toJson();
          if (handJson.containsKey('palm_interpretation')) {
            interpretationData = handJson['palm_interpretation'] as Map<String, dynamic>?;
            break;
          }
        }
      }
    }

    if (interpretationData == null) {
      return Center(
        child: _buildEmptyCard('Không có dữ liệu giải nghĩa'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Thêm padding bottom lớn hơn
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInterpretationHeader(),
          const SizedBox(height: 16),
          if (interpretationData.containsKey('summary_text'))
            _buildSummarySection(interpretationData['summary_text'] as String),
          const SizedBox(height: 16),
          if (interpretationData.containsKey('detailed_analysis'))
            _buildDetailedAnalysisSection(interpretationData['detailed_analysis'] as Map<String, dynamic>),
          const SizedBox(height: 16),
          if (interpretationData.containsKey('life_aspects'))
            _buildLifeAspectsSection(interpretationData['life_aspects'] as Map<String, dynamic>),
          const SizedBox(height: 32), // Thêm space cuối
        ],
      ),
    );
  }

  Widget _buildInterpretationHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary.withOpacity(0.1), AppColors.primary.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_stories,
            color: AppColors.secondary,
            size: 32,
          ),
          const SizedBox(width: 12),
          const Text(
            'Giải Nghĩa Vân Tay',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(String summaryText) {
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
              Icon(Icons.summarize, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Tóm Tắt Phân Tích',
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
            summaryText,
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

  Widget _buildDetailedAnalysisSection(Map<String, dynamic> detailedAnalysis) {
    final palmLineNames = {
      'life_line': {'name': 'Đường Sinh Mệnh', 'icon': Icons.favorite, 'color': Colors.red},
      'head_line': {'name': 'Đường Trí Tuệ', 'icon': Icons.psychology, 'color': Colors.blue},
      'heart_line': {'name': 'Đường Tình Cảm', 'icon': Icons.favorite_border, 'color': Colors.pink},
      'fate_line': {'name': 'Đường Vận Mệnh', 'icon': Icons.star, 'color': Colors.purple},
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phân Tích Chi Tiết',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...palmLineNames.keys.map((lineKey) {
          if (detailedAnalysis.containsKey(lineKey)) {
            final lineAnalysis = detailedAnalysis[lineKey] as Map<String, dynamic>;
            return Column(
              children: [
                _buildLineAnalysisCard(
                  palmLineNames[lineKey]!['name'] as String,
                  lineAnalysis,
                  palmLineNames[lineKey]!['icon'] as IconData,
                  palmLineNames[lineKey]!['color'] as Color,
                ),
                const SizedBox(height: 12),
              ],
            );
          }
          return const SizedBox.shrink();
        }).toList(),
      ],
    );
  }

  Widget _buildLineAnalysisCard(String title, Map<String, dynamic> analysis, IconData icon, Color color) {
    // Try to get confidence from confidence_scores first, then fall back to analysis confidence
    double? confidence;

    // Get the line key from title
    String lineKey = '';
    switch (title) {
      case 'Đường Sinh Mệnh':
        lineKey = 'life_line';
        break;
      case 'Đường Trí Tuệ':
        lineKey = 'head_line';
        break;
      case 'Đường Tình Cảm':
        lineKey = 'heart_line';
        break;
      case 'Đường Vận Mệnh':
        lineKey = 'fate_line';
        break;
    }

    // Try to get confidence from the parent interpretation data
    final analysisData = widget.palmResult.analysis;
    if (analysisData?.palmDetection?.handsData != null &&
        analysisData!.palmDetection!.handsData!.isNotEmpty) {
      for (var handData in analysisData.palmDetection!.handsData!) {
        final handJson = handData.toJson();
        if (handJson.containsKey('confidence_scores')) {
          final confidenceScores = handJson['confidence_scores'] as Map<String, dynamic>?;
          if (confidenceScores != null && confidenceScores.containsKey(lineKey)) {
            confidence = (confidenceScores[lineKey] as num?)?.toDouble();
            break;
          }
        }
      }
    }

    // Fall back to analysis confidence if not found
    confidence ??= (analysis['confidence'] as num?)?.toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (analysis.containsKey('pattern'))
            _buildAnalysisItem('Đặc điểm', analysis['pattern'] as String, Icons.pattern),
          if (analysis.containsKey('meaning'))
            _buildAnalysisItem('Ý nghĩa', analysis['meaning'] as String, Icons.lightbulb),
          if (confidence != null)
            _buildAnalysisItem('Độ tin cậy', '${(confidence * 100).toStringAsFixed(1)}%', Icons.verified),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeAspectsSection(Map<String, dynamic> lifeAspects) {
    final aspectNames = {
      'health': {'name': 'Sức Khỏe', 'icon': Icons.health_and_safety, 'color': Colors.green},
      'career': {'name': 'Sự Nghiệp', 'icon': Icons.work, 'color': Colors.orange},
      'relationships': {'name': 'Tình Cảm', 'icon': Icons.favorite, 'color': Colors.red},
      'personality': {'name': 'Tính Cách', 'icon': Icons.psychology, 'color': Colors.blue},
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Các Khía Cạnh Cuộc Sống',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...aspectNames.keys.map((aspectKey) {
          if (lifeAspects.containsKey(aspectKey)) {
            final aspectData = lifeAspects[aspectKey] as List<dynamic>;
            if (aspectData.isNotEmpty) {
              return Column(
                children: [
                  _buildLifeAspectCard(
                    aspectNames[aspectKey]!['name'] as String,
                    aspectData,
                    aspectNames[aspectKey]!['icon'] as IconData,
                    aspectNames[aspectKey]!['color'] as Color,
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }
          }
          return const SizedBox.shrink();
        }).toList(),
      ],
    );
  }

  Widget _buildLifeAspectCard(String title, List<dynamic> aspects, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...aspects.map((aspect) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    aspect.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildImagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Thêm padding bottom lớn hơn
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
          const SizedBox(height: 32), // Thêm space cuối
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


}
