import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/chat_history_model.dart';

/// Empty state widget for history page
class HistoryEmptyState extends StatelessWidget {
  final HistoryFilterConfig filterConfig;
  final String searchQuery;
  final VoidCallback? onClearFilters;
  final VoidCallback? onStartAnalysis;

  const HistoryEmptyState({
    super.key,
    required this.filterConfig,
    this.searchQuery = '',
    this.onClearFilters,
    this.onStartAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = filterConfig.hasActiveFilters || searchQuery.isNotEmpty;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                hasActiveFilters ? Icons.search_off : Icons.history,
                size: 60,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              _getTitle(hasActiveFilters),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              _getDescription(hasActiveFilters),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Actions
            _buildActions(hasActiveFilters),
          ],
        ),
      ),
    );
  }

  String _getTitle(bool hasActiveFilters) {
    if (hasActiveFilters) {
      if (searchQuery.isNotEmpty) {
        return 'Không tìm thấy kết quả';
      }
      return 'Không có mục nào phù hợp';
    }
    return 'Chưa có lịch sử';
  }

  String _getDescription(bool hasActiveFilters) {
    if (hasActiveFilters) {
      if (searchQuery.isNotEmpty) {
        return 'Không tìm thấy kết quả nào cho từ khóa "$searchQuery". Hãy thử tìm kiếm với từ khóa khác.';
      }
      
      switch (filterConfig.filter) {
        case HistoryFilter.faceAnalysis:
          return 'Bạn chưa có lịch sử phân tích khuôn mặt nào. Hãy thử phân tích khuôn mặt để tạo lịch sử.';
        case HistoryFilter.palmAnalysis:
          return 'Bạn chưa có lịch sử phân tích vân tay nào. Hãy thử phân tích vân tay để tạo lịch sử.';
        case HistoryFilter.chatConversation:
          return 'Bạn chưa có cuộc trò chuyện nào với AI. Hãy bắt đầu trò chuyện để tạo lịch sử.';
        case HistoryFilter.favorites:
          return 'Bạn chưa đánh dấu mục nào là yêu thích. Nhấn vào biểu tượng trái tim để thêm vào yêu thích.';
        case HistoryFilter.recent:
          return 'Không có hoạt động nào trong 7 ngày qua.';
        case HistoryFilter.thisWeek:
          return 'Không có hoạt động nào trong tuần này.';
        case HistoryFilter.thisMonth:
          return 'Không có hoạt động nào trong tháng này.';
        case HistoryFilter.all:
          return 'Không có mục nào phù hợp với bộ lọc hiện tại.';
      }
    }
    
    return 'Bạn chưa có lịch sử nào. Hãy bắt đầu phân tích khuôn mặt, vân tay hoặc trò chuyện với AI để tạo lịch sử.';
  }

  Widget _buildActions(bool hasActiveFilters) {
    if (hasActiveFilters) {
      return Column(
        children: [
          // Clear filters button
          if (onClearFilters != null)
            ElevatedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear_all),
              label: const Text('Xóa bộ lọc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
            ),
          
          if (onStartAnalysis != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onStartAnalysis,
              child: const Text(
                'Bắt đầu phân tích mới',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      );
    }
    
    // No history state actions
    return Column(
      children: [
        // Start analysis button
        if (onStartAnalysis != null)
          ElevatedButton.icon(
            onPressed: onStartAnalysis,
            icon: const Icon(Icons.analytics),
            label: const Text('Bắt đầu phân tích'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Feature suggestions
        _buildFeatureSuggestions(),
      ],
    );
  }

  Widget _buildFeatureSuggestions() {
    return Column(
      children: [
        const Text(
          'Bạn có thể thử:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildSuggestionChip(
              icon: Icons.face_retouching_natural,
              label: 'Phân tích khuôn mặt',
              color: AppColors.primary,
            ),
            _buildSuggestionChip(
              icon: Icons.back_hand,
              label: 'Phân tích vân tay',
              color: AppColors.secondary,
            ),
            _buildSuggestionChip(
              icon: Icons.chat_bubble_outline,
              label: 'Trò chuyện AI',
              color: AppColors.success,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestionChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading state widget for history
class HistoryLoadingState extends StatelessWidget {
  const HistoryLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Đang tải lịch sử...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state widget for history
class HistoryErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const HistoryErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
