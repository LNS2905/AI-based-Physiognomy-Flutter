import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/tu_vi_provider.dart';
import '../../data/models/tu_vi_chart_response.dart';
import '../../data/models/tu_vi_house.dart';
import '../widgets/element_widgets.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../ai_conversation/presentation/providers/chat_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Result page displaying Tu Vi chart
class TuViResultPage extends StatefulWidget {
  final String chartId;

  const TuViResultPage({
    super.key,
    required this.chartId,
  });

  @override
  State<TuViResultPage> createState() => _TuViResultPageState();
}

class _TuViResultPageState extends State<TuViResultPage> {
  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  Future<void> _loadChart() async {
    final provider = Provider.of<TuViProvider>(context, listen: false);
    final chartId = int.tryParse(widget.chartId);
    if (chartId != null) {
      await provider.getChart(chartId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TuViProvider>(context);
    final chart = provider.currentChart;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        title: const Text('Lá Số Tử Vi'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.share),
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //         content: Text('Tính năng chia sẻ sẽ sớm ra mắt'),
          //         backgroundColor: AppColors.info,
          //         behavior: SnackBarBehavior.floating,
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : provider.hasError
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          provider.errorMessage ?? 'Đã xảy ra lỗi',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadChart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : chart == null
                  ? const Center(child: Text('Không tìm thấy lá số'))
                  : _buildChartContent(chart),
      floatingActionButton: chart != null && !provider.isLoading && !provider.hasError
          ? _buildChatbotFAB(chart)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildChartContent(TuViChartResponse chart) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section
          _buildHeaderSection(chart),
          const SizedBox(height: 16),

          // Main info card
          _buildMainInfoCard(chart),
          const SizedBox(height: 16),

          // 12 Houses section
          _buildHousesSection(chart),
          const SizedBox(height: 16),

          // Stars by category
          _buildStarsCategorySection(chart),
          const SizedBox(height: 16),

          // Additional info
          _buildAdditionalInfo(chart),
          const SizedBox(height: 80), // Space for floating button
        ],
      ),
    );
  }

  Widget _buildHeaderSection(TuViChartResponse chart) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowYellow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (chart.extra.name != null) ...[
            Text(
              chart.extra.name!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                chart.extra.genderValue == 1 ? Icons.male : Icons.female,
                color: AppColors.textOnPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                chart.extra.gender,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'Dương lịch',
                    style: TextStyle(fontSize: 12, color: AppColors.textOnPrimary.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chart.extra.solarDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                height: 40,
                width: 1,
                color: AppColors.textOnPrimary.withOpacity(0.3),
              ),
              Column(
                children: [
                  Text(
                    'Âm lịch',
                    style: TextStyle(fontSize: 12, color: AppColors.textOnPrimary.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chart.extra.lunarDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Giờ: ${chart.extra.hour}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard(TuViChartResponse chart) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.iconBgYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.primaryDark, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Thông tin chính',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              'Mệnh chủ',
              chart.extra.menhChu,
              Icons.star,
              Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Thân chủ',
              chart.extra.thanChu,
              Icons.star_half,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Bản mệnh',
              '${chart.extra.menh} (${chart.extra.menhElementName})',
              Icons.filter_vintage,
              _getElementColorByName(chart.extra.menhElementName),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Cục',
              '${chart.extra.cuc} (${chart.extra.cucElementName})',
              Icons.hub,
              _getElementColorByName(chart.extra.cucElementName),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.iconBgYellow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderYellow),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.balance, color: AppColors.primaryDark, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      chart.extra.menhVsCuc,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.iconBgTeal,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.circle_outlined, color: AppColors.secondary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      chart.extra.amDuongMenh,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
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

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHousesSection(TuViChartResponse chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.iconBgYellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home_rounded, color: AppColors.primaryDark, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              '12 Cung',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...chart.sortedHouses.map((house) => _buildHouseCard(house)),
      ],
    );
  }

  Widget _buildHouseCard(TuViHouse house) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: house.isMainHouse
              ? Colors.purple.withOpacity(0.5)
              : house.isBodyHouse
                  ? Colors.blue.withOpacity(0.5)
                  : AppColors.border.withOpacity(0.5),
          width: house.isMainHouse || house.isBodyHouse ? 2 : 1,
        ),
        boxShadow: house.isMainHouse || house.isBodyHouse
            ? [
                BoxShadow(
                  color: house.isMainHouse
                      ? Colors.purple.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getElementColorByName(house.element).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getElementColorByName(house.element),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    house.houseNumber.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getElementColorByName(house.element),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          house.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      if (house.isMainHouse) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Cung Mệnh',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ] else if (house.isBodyHouse) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Cung Thân',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${house.branch} - ',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      ElementChip(element: house.element, isSmall: true),
                      const SizedBox(width: 8),
                      Text(
                        house.amDuongName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                house.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (house.majorPeriod != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Đại hạn: ${house.majorPeriod} tuổi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        children: [
          if (house.stars.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (house.mainStars.isNotEmpty) ...[
                    const Text(
                      'Chính tinh:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      children: house.mainStars
                          .map((star) => StarChipWidget(star: star))
                          .toList(),
                    ),
                    if (house.supportingStars.isNotEmpty)
                      const SizedBox(height: 12),
                  ],
                  if (house.supportingStars.isNotEmpty) ...[
                    const Text(
                      'Phụ tinh:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      children: house.supportingStars
                          .map((star) => StarChipWidget(star: star))
                          .toList(),
                    ),
                  ],
                  if (house.tuanTrung || house.trietLo) ...[
                    const SizedBox(height: 12),
                    if (house.tuanTrung)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              'Có Tuần Triệt - Cung bị yếu',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    if (house.trietLo) ...[
                      if (house.tuanTrung) const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.error_outline, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Có Triệt Lộ - Cung bị gián đoạn',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Không có sao trong cung này',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildStarsCategorySection(TuViChartResponse chart) {
    // Get all stars from all houses
    final allStars = chart.houses.expand((house) => house.stars).toList();
    final mainStars = allStars.where((star) => star.category == 1).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.iconBgYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.stars_rounded, color: AppColors.primaryDark, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  '14 Chính Tinh',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mainStars.map((star) => StarChipWidget(star: star)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(TuViChartResponse chart) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.iconBgTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Thông tin bổ sung',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildAdditionalInfoRow('Năm Can Chi', chart.extra.stemBranch['year'] ?? ''),
            _buildAdditionalInfoRow('Tháng Can Chi', chart.extra.stemBranch['month'] ?? ''),
            _buildAdditionalInfoRow('Ngày Can Chi', chart.extra.stemBranch['day'] ?? ''),
            _buildAdditionalInfoRow('Giờ Can Chi', chart.extra.stemBranch['hour'] ?? ''),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.border.withOpacity(0),
                    AppColors.border,
                    AppColors.border.withOpacity(0),
                  ],
                ),
              ),
            ),
            _buildAdditionalInfoRow('Âm dương năm sinh', chart.extra.amDuongNamSinh),
            _buildAdditionalInfoRow('Múi giờ', 'UTC+${chart.extra.timezone}'),
            _buildAdditionalInfoRow('Ngày lập', chart.extra.today),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getElementColorByName(String element) {
    switch (element) {
      case 'Kim':
        return const Color(0xFFFFD700);
      case 'Mộc':
        return const Color(0xFF4CAF50);
      case 'Thủy':
        return const Color(0xFF2196F3);
      case 'Hỏa':
        return const Color(0xFFF44336);
      case 'Thổ':
        return const Color(0xFF795548);
      default:
        return Colors.grey;
    }
  }

  Widget _buildChatbotFAB(TuViChartResponse chart) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: FloatingActionButton.extended(
        onPressed: () => _onChatbotPressed(chart),
        backgroundColor: AppColors.primary,
        elevation: 6,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
        label: const Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Gặp Chatbot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Hỏi AI về lá số của bạn',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onChatbotPressed(TuViChartResponse chart) async {
    // Get chat provider
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Get auth provider
    final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để sử dụng chatbot'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    final user = authProvider.currentUser!;

    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      // Set user in chat provider
      chatProvider.setUser(user);

      // Convert chart to JSON for fast Tu Vi analysis
      final chartJson = chart.toJson();

      // Create new conversation with chart_id AND full chart data JSON
      final success = await chatProvider.createNewConversation(
        chartId: chart.id,
        chartData: chartJson, // ✅ Pass full JSON data for fast analysis
      );

      // Hide loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (success && chatProvider.currentConversationId != null) {
        // Navigate to chatbot screen
        if (mounted) {
          context.push('/ai-conversation?id=${chatProvider.currentConversationId}');
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể khởi tạo cuộc trò chuyện. Vui lòng thử lại.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
