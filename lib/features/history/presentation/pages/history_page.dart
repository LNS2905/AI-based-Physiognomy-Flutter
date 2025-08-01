import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/history_item_model.dart';
import '../../data/models/chat_history_model.dart';
import '../providers/history_provider.dart';
import '../widgets/history_item_card.dart';
import '../widgets/history_filter_bar.dart';
import '../widgets/history_empty_state.dart';

/// Main history page displaying all user history
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    
    // Initialize history provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            if (_showSearchBar) _buildSearchBar(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHistoryList(),
                  _buildStatisticsView(),
                ],
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
          // Back button
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
          
          // Title
          const Expanded(
            child: Text(
              'Lịch sử',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          // Search button
          IconButton(
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  context.read<HistoryProvider>().clearSearch();
                }
              });
            },
            icon: Icon(
              _showSearchBar ? Icons.search_off : Icons.search,
              color: AppColors.textPrimary,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: _showSearchBar 
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 8),
          
          // More options
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 8),
                    Text('Làm mới'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Xóa tất cả', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
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
          child: TextField(
            onChanged: provider.searchHistory,
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
              suffixIcon: provider.searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: provider.clearSearch,
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: 12,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: 'Tất cả'),
          Tab(text: 'Thống kê'),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const HistoryLoadingState();
        }

        if (provider.hasError) {
          return HistoryErrorState(
            message: provider.errorMessage ?? 'Có lỗi xảy ra khi tải lịch sử',
            onRetry: provider.refreshHistory,
          );
        }

        return Column(
          children: [
            // Filter bar
            HistoryFilterBar(
              filterConfig: provider.filterConfig,
              onFilterChanged: provider.setFilter,
              onSortChanged: provider.setSort,
              onClearFilters: provider.hasActiveFilters 
                  ? () {
                      provider.updateFilter(const HistoryFilterConfig());
                      provider.clearSearch();
                    }
                  : null,
            ),
            
            // History list
            Expanded(
              child: provider.hasFilteredItems
                  ? _buildHistoryListView(provider)
                  : HistoryEmptyState(
                      filterConfig: provider.filterConfig,
                      searchQuery: provider.searchQuery,
                      onClearFilters: provider.hasActiveFilters 
                          ? () {
                              provider.updateFilter(const HistoryFilterConfig());
                              provider.clearSearch();
                            }
                          : null,
                      onStartAnalysis: () => context.pop(),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryListView(HistoryProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.refreshHistory,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
        itemCount: provider.filteredHistoryItems.length,
        itemBuilder: (context, index) {
          final item = provider.filteredHistoryItems[index];
          return HistoryItemCard(
            item: item,
            onTap: () => _navigateToDetail(item),
            onFavoriteToggle: () => provider.toggleFavorite(item.id),
            onDelete: () => _showDeleteConfirmation(item),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsView() {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const HistoryLoadingState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticsCard(provider),
              const SizedBox(height: 16),
              _buildRecentActivity(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsCard(HistoryProvider provider) {
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
            'Thống kê tổng quan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Tổng cộng',
                  provider.totalItems.toString(),
                  Icons.history,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Yêu thích',
                  provider.favoriteCount.toString(),
                  Icons.favorite,
                  AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Khuôn mặt',
                  provider.faceAnalysisCount.toString(),
                  Icons.face_retouching_natural,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Vân tay',
                  provider.palmAnalysisCount.toString(),
                  Icons.back_hand,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildStatItem(
            'Trò chuyện',
            provider.chatConversationCount.toString(),
            Icons.chat_bubble_outline,
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(HistoryProvider provider) {
    final recentItems = provider.getRecentItems(limit: 5);
    
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
            'Hoạt động gần đây',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          if (recentItems.isEmpty)
            const Text(
              'Chưa có hoạt động nào',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            )
          else
            ...recentItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: HistoryItemCompactCard(
                item: item,
                onTap: () => _navigateToDetail(item),
                onFavoriteToggle: () => provider.toggleFavorite(item.id),
              ),
            )),
        ],
      ),
    );
  }

  void _navigateToDetail(HistoryItemModel item) {
    AppLogger.info('Navigating to detail for item: ${item.id}');
    
    switch (item.type) {
      case HistoryItemType.faceAnalysis:
        context.push('/history/face-analysis/${item.id}');
        break;
      case HistoryItemType.palmAnalysis:
        context.push('/history/palm-analysis/${item.id}');
        break;
      case HistoryItemType.chatConversation:
        context.push('/history/chat/${item.id}');
        break;
    }
  }

  void _handleMenuAction(String action) {
    final provider = context.read<HistoryProvider>();
    
    switch (action) {
      case 'refresh':
        provider.refreshHistory();
        break;
      case 'clear_all':
        _showClearAllConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation(HistoryItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mục lịch sử'),
        content: Text('Bạn có chắc chắn muốn xóa "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HistoryProvider>().deleteHistoryItem(item.id);
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả lịch sử'),
        content: const Text('Bạn có chắc chắn muốn xóa toàn bộ lịch sử? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HistoryProvider>().clearAllHistory();
            },
            child: const Text(
              'Xóa tất cả',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
