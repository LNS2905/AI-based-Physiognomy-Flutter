import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../data/models/chart_data_models.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget for displaying face shape probabilities as horizontal bar chart
class FaceShapeProbabilityChart extends StatelessWidget {
  final List<FaceShapeProbabilityData> data;
  final String title;

  const FaceShapeProbabilityChart({
    super.key,
    required this.data,
    this.title = 'Nhận diện dạng khuôn mặt',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

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
          _buildChart(),
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
            Icons.face,
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
                'Điểm tin cậy (%)',
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

  Widget _buildChart() {
    return SizedBox(
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: const CategoryAxis(
          majorGridLines: MajorGridLines(width: 0),
          axisLine: AxisLine(width: 0),
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
        primaryYAxis: const NumericAxis(
          minimum: 0,
          maximum: 100,
          interval: 20,
          majorGridLines: MajorGridLines(
            width: 1,
            color: Color(0xFFE0E0E0),
            dashArray: [5, 5],
          ),
          axisLine: AxisLine(width: 1, color: Color(0xFFE0E0E0)),
          labelFormat: '{value}%',
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        plotAreaBorderWidth: 0,
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
        series: <CartesianSeries<FaceShapeProbabilityData, String>>[
          ColumnSeries<FaceShapeProbabilityData, String>(
            dataSource: data,
            xValueMapper: (FaceShapeProbabilityData data, _) => data.shapeName,
            yValueMapper: (FaceShapeProbabilityData data, _) => data.probability,
            pointColorMapper: (FaceShapeProbabilityData data, _) => data.color,
            width: 0.6,
            spacing: 0.2,
            animationDuration: 1500,
            enableTooltip: true,
          ),
        ],
      ),
    );
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
            Icons.face_retouching_off,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có dữ liệu dạng khuôn mặt',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dữ liệu phân tích dạng khuôn mặt sẽ hiển thị ở đây',
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
