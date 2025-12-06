import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/fixed_bottom_navigation.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../data/models/history_item_model.dart';
import '../../data/models/chat_history_model.dart';
import '../providers/history_provider.dart';
import '../widgets/history_item_card.dart';
import '../widgets/history_filter_bar.dart';
import '../widgets/history_empty_state.dart';
import '../../../face_scan/presentation/pages/facial_analysis_history_results_page.dart';
import '../../../face_scan/data/models/facial_analysis_server_model.dart';
import '../../../palm_scan/presentation/pages/palm_analysis_history_results_page.dart';
import '../../../palm_scan/data/models/palm_analysis_server_model.dart';

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

    // Initialize history provider - but it will wait for auth to be ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historyProvider = context.read<HistoryProvider>();
      // The provider will automatically handle auth state changes
      // No need to call initialize() immediately
      AppLogger.info('HistoryPage: Initialized, waiting for auth state');
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
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                _buildAppBar(),
                if (_showSearchBar) _buildSearchBar(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: _buildHistoryList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: _buildStatisticsView(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Fixed Bottom Navigation
            FixedBottomNavigation(currentRoute: '/history'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primarySoft,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowYellow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          const Padding(
            padding: EdgeInsets.all(4.0),
            child: StandardBackButton(),
          ),
          const SizedBox(width: 12),
          
          // Title with icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.iconBgYellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              color: AppColors.primaryDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Lịch sử',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          
          // Search button
          Container(
            decoration: BoxDecoration(
              color: _showSearchBar 
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _showSearchBar ? AppColors.primary : AppColors.borderLight,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _showSearchBar = !_showSearchBar;
                  if (!_showSearchBar) {
                    context.read<HistoryProvider>().clearSearch();
                  }
                });
              },
              icon: Icon(
                _showSearchBar ? Icons.search_off_rounded : Icons.search_rounded,
                color: _showSearchBar ? AppColors.primary : AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // More options
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: AppColors.surface,
              elevation: 8,
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.iconBgTeal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded, 
                          size: 18,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Làm mới',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            onChanged: provider.searchHistory,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm trong lịch sử...',
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.iconBgYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primaryDark,
                  size: 20,
                ),
              ),
              suffixIcon: provider.searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: provider.clearSearch,
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.error,
                          size: 16,
                        ),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          labelColor: AppColors.textOnPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowYellow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.list_alt_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Tất cả'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.bar_chart_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Thống kê'),
                ],
              ),
            ),
          ],
        ),
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
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
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
              const SizedBox(height: 20),
              _buildRecentActivity(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsCard(HistoryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowYellow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: AppColors.textOnPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thống kê tổng quan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tổng hợp hoạt động của bạn',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Tổng cộng',
                  provider.totalItems.toString(),
                  Icons.history_rounded,
                  AppColors.primary,
                  AppColors.iconBgYellow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Yêu thích',
                  provider.favoriteCount.toString(),
                  Icons.favorite_rounded,
                  AppColors.accent,
                  AppColors.iconBgPeach,
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
                  Icons.face_retouching_natural_rounded,
                  AppColors.primaryDark,
                  AppColors.iconBgYellow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Vân tay',
                  provider.palmAnalysisCount.toString(),
                  Icons.back_hand_rounded,
                  AppColors.secondary,
                  AppColors.iconBgTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildStatItem(
            'Trò chuyện',
            provider.chatConversationCount.toString(),
            Icons.chat_bubble_rounded,
            AppColors.success,
            AppColors.iconBgGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.tealGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoạt động gần đây',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '5 hoạt động mới nhất',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (recentItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.iconBgYellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_empty_rounded,
                      color: AppColors.primaryDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Chưa có hoạt động nào',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
        // Navigate directly to facial analysis results page
        if (item is FaceAnalysisHistoryModel) {
          // Convert CloudinaryAnalysisResponseModel to FacialAnalysisServerModel
          final analysisData = _convertToFacialAnalysisServerModel(item);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FacialAnalysisHistoryResultsPage(
                analysisData: analysisData,
              ),
            ),
          );
        }
        break;
      case HistoryItemType.palmAnalysis:
        // Navigate directly to palm analysis results page
        if (item is PalmAnalysisHistoryModel) {
          // Convert PalmAnalysisResponseModel to PalmAnalysisServerModel
          final analysisData = _convertToPalmAnalysisServerModel(item);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PalmAnalysisHistoryResultsPage(
                analysisData: analysisData,
              ),
            ),
          );
        }
        break;
      case HistoryItemType.chatConversation:
        context.push('/history/chat/${item.id}');
        break;
    }
  }
  
  FacialAnalysisServerModel _convertToFacialAnalysisServerModel(FaceAnalysisHistoryModel item) {
    final analysis = item.analysisResult;
    final faceData = analysis?.analysis?.analysisResult?.face;
    final metadata = item.metadata;
    
    return FacialAnalysisServerModel(
      id: int.tryParse(metadata?['serverId']?.toString() ?? '') ?? 0,
      userId: analysis?.userId ?? '',
      resultText: analysis?.analysis?.result ?? '',
      faceShape: faceData?.shape?.primary ?? 'Unknown',
      harmonyScore: faceData?.proportionality?.overallHarmonyScore ?? 0.0,
      probabilities: faceData?.shape?.probabilities ?? {},
      harmonyDetails: faceData?.proportionality?.harmonyScores ?? {},
      metrics: (faceData?.proportionality?.metrics ?? []).map((m) => 
        FacialMetricServerModel(
          label: m.label ?? '',
          pixels: m.pixels ?? 0.0,
          percentage: m.percentage ?? 0.0,
          orientation: m.orientation ?? '',
        )
      ).toList(),
      annotatedImage: item.annotatedImageUrl ?? analysis?.annotatedImageUrl ?? '',
      processedAt: analysis?.processedAt ?? DateTime.now().toIso8601String(),
      createdAt: item.createdAt.toIso8601String(),
      updatedAt: item.updatedAt.toIso8601String(),
    );
  }
  
  PalmAnalysisServerModel _convertToPalmAnalysisServerModel(PalmAnalysisHistoryModel item) {
    final metadata = item.metadata;
    final serverId = metadata?['server_id'] ?? 0;
    
    // Get original server data if stored in metadata
    final originalInterpretations = metadata?['interpretations'] as List<dynamic>? ?? [];
    final originalLifeAspects = metadata?['lifeAspects'] as List<dynamic>? ?? [];
    
    // Convert interpretations from metadata
    final interpretations = originalInterpretations.map((data) {
      if (data is Map<String, dynamic>) {
        try {
          // Safely parse numeric values
          final int idValue = data['id'] is int ? data['id'] : int.tryParse(data['id']?.toString() ?? '') ?? 0;
          final int analysisIdValue = data['analysisId'] is int ? data['analysisId'] : int.tryParse(data['analysisId']?.toString() ?? '') ?? serverId;
          final int lengthPxValue = data['lengthPx'] is int 
              ? data['lengthPx'] 
              : (data['lengthPx'] is double 
                  ? (data['lengthPx'] as double).toInt() 
                  : int.tryParse(data['lengthPx']?.toString() ?? '') ?? 0);
          final double confidenceValue = data['confidence'] is double 
              ? data['confidence'] 
              : (data['confidence'] is int 
                  ? (data['confidence'] as int).toDouble() 
                  : double.tryParse(data['confidence']?.toString() ?? '') ?? 0.0);
          
          return InterpretationServerModel(
            id: idValue,
            analysisId: analysisIdValue,
            lineType: data['lineType']?.toString() ?? '',
            pattern: data['pattern']?.toString() ?? '',
            meaning: data['meaning']?.toString() ?? '',
            lengthPx: lengthPxValue,
            confidence: confidenceValue,
            createdAt: data['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
          );
        } catch (e) {
          AppLogger.error('Error converting interpretation data: $e');
          return null;
        }
      }
      return null;
    }).whereType<InterpretationServerModel>().toList();
    
    // Convert life aspects from metadata
    final lifeAspects = originalLifeAspects.map((data) {
      if (data is Map<String, dynamic>) {
        return LifeAspectServerModel(
          id: data['id'] ?? 0,
          analysisId: data['analysisId'] ?? serverId,
          aspect: data['aspect'] ?? '',
          content: data['content'] ?? '',
        );
      }
      return null;
    }).whereType<LifeAspectServerModel>().toList();
    
    // Use summary text from metadata if available, otherwise use message
    final summaryText = metadata?['summaryText'] ?? item.analysisResult?.message ?? '';
    
    // Calculate actual palm lines detected from the palm lines data
    final palmLines = item.analysisResult?.analysis?.palmLines ?? {};
    final activeLinesCount = [
      if ((palmLines['heart'] ?? 0) > 0) 'heart',
      if ((palmLines['head'] ?? 0) > 0) 'head',
      if ((palmLines['life'] ?? 0) > 0) 'life',
      if ((palmLines['fate'] ?? 0) > 0) 'fate',
    ].length;
    
    return PalmAnalysisServerModel(
      id: serverId is int ? serverId : int.tryParse(serverId.toString()) ?? 0,
      userId: int.tryParse(item.analysisResult?.userId ?? '0') ?? 0,
      palmLinesDetected: activeLinesCount, // Use actual count of detected lines
      detectedHeartLine: (item.analysisResult?.analysis?.palmLines?['heart'] ?? 0).toInt(),
      detectedHeadLine: (item.analysisResult?.analysis?.palmLines?['head'] ?? 0).toInt(),
      detectedLifeLine: (item.analysisResult?.analysis?.palmLines?['life'] ?? 0).toInt(),
      detectedFateLine: (item.analysisResult?.analysis?.palmLines?['fate'] ?? 0).toInt(),
      targetLines: 'heart,head,life,fate',
      summaryText: summaryText,
      interpretations: interpretations,
      lifeAspects: lifeAspects,
      annotatedImage: item.annotatedImageUrl ?? '',
      imageWidth: item.analysisResult?.measurementsSummary?.averagePalmWidth?.toDouble() ?? 0.0,
      imageHeight: item.analysisResult?.measurementsSummary?.averageHandLength?.toDouble() ?? 0.0,
      imageChannels: 3.0,
      createdAt: item.createdAt.toIso8601String(),
      updatedAt: item.updatedAt.toIso8601String(),
    );
  }

  void _handleMenuAction(String action) {
    final provider = context.read<HistoryProvider>();
    
    switch (action) {
      case 'refresh':
        provider.refreshHistory();
        break;
      // Clear all action - DISABLED
      // case 'clear_all':
      //   _showClearAllConfirmation();
      //   break;
    }
  }

  void _showDeleteConfirmation(HistoryItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Xóa mục lịch sử',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${item.title}"?',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HistoryProvider>().deleteHistoryItem(item.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Xóa',
              style: TextStyle(fontWeight: FontWeight.w600),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_sweep_rounded,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Xóa tất cả lịch sử',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa toàn bộ lịch sử? Hành động này không thể hoàn tác.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HistoryProvider>().clearAllHistory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Xóa tất cả',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
