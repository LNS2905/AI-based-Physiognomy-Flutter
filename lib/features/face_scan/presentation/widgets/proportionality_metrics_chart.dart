import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../data/models/chart_data_models.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget for displaying proportionality metrics as radar chart
class ProportionalityMetricsChart extends StatelessWidget {
  final List<ProportionalityMetricData> data;
  final String title;

  const ProportionalityMetricsChart({
    super.key,
    required this.data,
    this.title = 'Chỉ số tỷ lệ khuôn mặt',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    // Filter and prepare data for radar chart (limit to top 8 metrics for better visualization)
    final chartData = data.take(8).toList();

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
          _buildHeader(),
          const SizedBox(height: 24),
          _buildRadarChart(chartData),
          const SizedBox(height: 16),
          _buildLegend(chartData),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.radar,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Đo lường khuôn mặt (%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadarChart(List<ProportionalityMetricData> chartData) {
    return SizedBox(
      height: 300,
      child: SfCircularChart(
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x: point.y%',
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          color: Colors.black87,
        ),
        series: <CircularSeries>[
          RadialBarSeries<ProportionalityMetricData, String>(
            dataSource: chartData,
            xValueMapper: (ProportionalityMetricData data, _) => _getShortLabel(data.label),
            yValueMapper: (ProportionalityMetricData data, _) => data.percentage,
            pointColorMapper: (ProportionalityMetricData data, int index) => _getColorForIndex(index),
            cornerStyle: CornerStyle.bothCurve,
            gap: '10%',
            radius: '90%',
            innerRadius: '40%',
            maximumValue: 50, // Adjust based on your data range
            trackColor: Colors.grey[200]!,
            trackBorderWidth: 0,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            animationDuration: 1500,
            enableTooltip: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(List<ProportionalityMetricData> chartData) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: chartData.asMap().entries.map((entry) {
        final index = entry.key;
        final metric = entry.value;
        final color = _getColorForIndex(index);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${_getShortLabel(metric.label)}: ${metric.percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getShortLabel(String label) {
    // Shorten labels for better display
    if (label.length > 12) {
      return '${label.substring(0, 10)}..';
    }
    return label;
  }

  Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF9800), // Orange
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF795548), // Brown
    ];
    return colors[index % colors.length];
  }

  Widget _buildEmptyState() {
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
          Icon(
            Icons.radar_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có dữ liệu tỷ lệ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dữ liệu đo lường khuôn mặt sẽ hiển thị ở đây',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
