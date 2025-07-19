import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/chat_history_model.dart';

/// Filter bar widget for history page
class HistoryFilterBar extends StatelessWidget {
  final HistoryFilterConfig filterConfig;
  final Function(HistoryFilter) onFilterChanged;
  final Function(HistorySort) onSortChanged;
  final VoidCallback? onClearFilters;

  const HistoryFilterBar({
    super.key,
    required this.filterConfig,
    required this.onFilterChanged,
    required this.onSortChanged,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          _buildFilterChips(),
          const SizedBox(height: 8),
          
          // Sort and clear actions
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Tất cả',
              isSelected: filterConfig.filter == HistoryFilter.all,
              onTap: () => onFilterChanged(HistoryFilter.all),
            ),
            const SizedBox(width: 6),
            _buildFilterChip(
              label: 'Khuôn mặt',
              isSelected: filterConfig.filter == HistoryFilter.faceAnalysis,
              onTap: () => onFilterChanged(HistoryFilter.faceAnalysis),
              icon: Icons.face_retouching_natural,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            _buildFilterChip(
              label: 'Vân tay',
              isSelected: filterConfig.filter == HistoryFilter.palmAnalysis,
              onTap: () => onFilterChanged(HistoryFilter.palmAnalysis),
              icon: Icons.back_hand,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 6),
            _buildFilterChip(
              label: 'Trò chuyện',
              isSelected: filterConfig.filter == HistoryFilter.chatConversation,
              onTap: () => onFilterChanged(HistoryFilter.chatConversation),
              icon: Icons.chat_bubble_outline,
              color: AppColors.success,
            ),
            const SizedBox(width: 6),
            _buildFilterChip(
              label: 'Yêu thích',
              isSelected: filterConfig.filter == HistoryFilter.favorites,
              onTap: () => onFilterChanged(HistoryFilter.favorites),
              icon: Icons.favorite,
              color: AppColors.accent,
            ),
            const SizedBox(width: 6),
            _buildFilterChip(
              label: 'Gần đây',
              isSelected: filterConfig.filter == HistoryFilter.recent,
              onTap: () => onFilterChanged(HistoryFilter.recent),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        // Sort dropdown
        _buildSortDropdown(),
        
        const Spacer(),
        
        // Clear filters button
        if (filterConfig.hasActiveFilters && onClearFilters != null)
          TextButton.icon(
            onPressed: onClearFilters,
            icon: const Icon(
              Icons.clear,
              size: 16,
              color: AppColors.textSecondary,
            ),
            label: const Text(
              'Xóa bộ lọc',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? (color ?? AppColors.primary)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? (color ?? AppColors.primary)
                : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected 
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected 
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return PopupMenuButton<HistorySort>(
      onSelected: onSortChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sort,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              filterConfig.sortDisplayName,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildSortMenuItem(HistorySort.newest, 'Mới nhất'),
        _buildSortMenuItem(HistorySort.oldest, 'Cũ nhất'),
        _buildSortMenuItem(HistorySort.alphabetical, 'Theo tên'),
        _buildSortMenuItem(HistorySort.favorites, 'Yêu thích'),
      ],
    );
  }

  PopupMenuItem<HistorySort> _buildSortMenuItem(HistorySort sort, String label) {
    final isSelected = filterConfig.sort == sort;
    
    return PopupMenuItem<HistorySort>(
      value: sort,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            size: 16,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Search bar widget for history
class HistorySearchBar extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback? onClearSearch;
  final bool isSearching;

  const HistorySearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    this.onClearSearch,
    this.isSearching = false,
  });

  @override
  State<HistorySearchBar> createState() => _HistorySearchBarState();
}

class _HistorySearchBarState extends State<HistorySearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: _focusNode.hasFocus ? AppColors.primary : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm trong lịch sử...',
          hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: widget.searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onClearSearch?.call();
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 12,
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
