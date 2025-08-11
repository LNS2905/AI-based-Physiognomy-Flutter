import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Profile statistics widget displaying user analysis stats
class ProfileStats extends StatelessWidget {
  final Map<String, dynamic> stats;
  final String memberSinceText;
  final String lastAnalysisText;

  const ProfileStats({
    super.key,
    required this.stats,
    required this.memberSinceText,
    required this.lastAnalysisText,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppColors.primary,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                'Thống kê',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: isTablet ? 20 : 16),
          
          // Stats grid
          if (isTablet)
            _buildTabletStatsGrid()
          else
            _buildMobileStatsGrid(),
          
          SizedBox(height: isTablet ? 20 : 16),
          
          // Additional info
          _buildAdditionalInfo(isTablet),
        ],
      ),
    );
  }

  /// Build stats grid for tablet
  Widget _buildTabletStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.analytics,
            title: 'Tổng phân tích',
            value: '${stats['totalAnalyses'] ?? 0}',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.face_retouching_natural,
            title: 'Phân tích mặt',
            value: '${stats['faceAnalyses'] ?? 0}',
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.back_hand,
            title: 'Phân tích tay',
            value: '${stats['palmAnalyses'] ?? 0}',
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  /// Build stats grid for mobile
  Widget _buildMobileStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.analytics,
                title: 'Tổng phân tích',
                value: '${stats['totalAnalyses'] ?? 0}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.face_retouching_natural,
                title: 'Phân tích mặt',
                value: '${stats['faceAnalyses'] ?? 0}',
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.back_hand,
                title: 'Phân tích tay',
                value: '${stats['palmAnalyses'] ?? 0}',
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                title: 'Độ chính xác',
                value: '${stats['accuracyScore']?.toStringAsFixed(1) ?? '0'}%',
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual stat card
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build additional info section
  Widget _buildAdditionalInfo(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Thành viên từ',
            value: memberSinceText,
            isTablet: isTablet,
          ),
          SizedBox(height: isTablet ? 12 : 8),
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Phân tích gần nhất',
            value: lastAnalysisText,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isTablet,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: isTablet ? 18 : 16,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: isTablet ? 12 : 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
