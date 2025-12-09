import 'dart:async';
import '../../../../core/providers/base_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';
import '../../../palm_scan/data/models/palm_analysis_server_model.dart';
import '../../../palm_scan/data/services/palm_analysis_history_service.dart';
import '../../../face_scan/data/models/facial_analysis_server_model.dart';
import '../../../face_scan/data/services/facial_analysis_history_service.dart';
import '../../data/models/history_item_model.dart';
import '../../data/models/chat_history_model.dart';
import '../../data/repositories/history_repository.dart';

/// Provider for managing history state and operations
class HistoryProvider extends BaseProvider {
  HistoryRepository _historyRepository;
  PalmAnalysisHistoryService _palmAnalysisHistoryService;
  FacialAnalysisHistoryService _facialAnalysisHistoryService;
  EnhancedAuthProvider _authProvider;

  // History data
  List<HistoryItemModel> _allHistoryItems = [];
  List<HistoryItemModel> _filteredHistoryItems = [];
  HistoryFilterConfig _filterConfig = const HistoryFilterConfig();

  // UI state
  bool _isSearching = false;
  String _searchQuery = '';
  Timer? _searchDebounceTimer;

  // Auth state tracking
  bool _hasInitialized = false;
  StreamSubscription? _authStateSubscription;
  
  // Disposal tracking for HistoryProvider-specific operations
  bool _historyDisposed = false;

  HistoryProvider({required EnhancedAuthProvider authProvider})
      : _authProvider = authProvider,
        _historyRepository = HistoryRepository(authProvider: authProvider),
        _palmAnalysisHistoryService = PalmAnalysisHistoryService(authProvider: authProvider),
        _facialAnalysisHistoryService = FacialAnalysisHistoryService(authProvider: authProvider) {
    _setupAuthListener();
  }

  /// Update the auth provider dependency when ProxyProvider calls update
  /// This pattern avoids creating a new HistoryProvider instance on auth changes
  void updateAuthProvider(EnhancedAuthProvider newAuthProvider) {
    if (_historyDisposed) return;
    
    // Check if authProvider actually changed
    if (_authProvider == newAuthProvider) {
      AppLogger.info('HistoryProvider.updateAuthProvider: Same provider, skipping update');
      return;
    }
    
    AppLogger.info('HistoryProvider.updateAuthProvider: Updating auth provider dependency');
    
    // Remove listener from old provider
    try {
      _authProvider.removeListener(_onAuthStateChanged);
    } catch (e) {
      AppLogger.warning('HistoryProvider: Error removing old auth listener: $e');
    }
    
    // Update references
    _authProvider = newAuthProvider;
    _historyRepository = HistoryRepository(authProvider: newAuthProvider);
    _palmAnalysisHistoryService = PalmAnalysisHistoryService(authProvider: newAuthProvider);
    _facialAnalysisHistoryService = FacialAnalysisHistoryService(authProvider: newAuthProvider);
    
    // Setup listener on new provider
    _setupAuthListener();
    
    AppLogger.info('HistoryProvider.updateAuthProvider: Auth provider dependency updated successfully');
  }

  // Getters
  List<HistoryItemModel> get allHistoryItems => _allHistoryItems;
  List<HistoryItemModel> get filteredHistoryItems => _filteredHistoryItems;
  HistoryFilterConfig get filterConfig => _filterConfig;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  bool get hasItems => _allHistoryItems.isNotEmpty;
  bool get hasFilteredItems => _filteredHistoryItems.isNotEmpty;
  bool get hasActiveFilters => _filterConfig.hasActiveFilters || _searchQuery.isNotEmpty;

  // Error handling
  String? _errorMessage;
  @override
  String? get errorMessage => _errorMessage;

  void setError(String message) {
    _errorMessage = message;
    setLoading(false);
    if (!_historyDisposed) {
      notifyListeners();
    }
  }

  @override
  void clearError() {
    _errorMessage = null;
    if (!_historyDisposed) {
      notifyListeners();
    }
  }

  // Statistics
  int get totalItems => _allHistoryItems.length;
  int get faceAnalysisCount => _allHistoryItems.where((item) => item.type == HistoryItemType.faceAnalysis).length;
  int get palmAnalysisCount => _allHistoryItems.where((item) => item.type == HistoryItemType.palmAnalysis).length;
  int get chatConversationCount => _allHistoryItems.where((item) => item.type == HistoryItemType.chatConversation).length;
  int get favoriteCount => _allHistoryItems.where((item) => item.isFavorite).length;

  /// Setup authentication state listener
  void _setupAuthListener() {
    // Listen to auth provider changes
    // Use try-catch to handle edge cases where auth provider might be in inconsistent state
    try {
      _authProvider.addListener(_onAuthStateChanged);
      
      // Check initial auth state (delayed to avoid issues during construction)
      Future.microtask(() {
        if (!_historyDisposed) {
          _onAuthStateChanged();
        }
      });
    } catch (e) {
      AppLogger.warning('HistoryProvider: Error setting up auth listener: $e');
    }
  }

  /// Handle authentication state changes
  void _onAuthStateChanged() {
    // CRITICAL: Check if disposed before doing anything
    // Use try-catch to handle any edge cases where provider is in inconsistent state
    try {
      if (_historyDisposed) {
        // Silently return - this can happen during normal dispose flow
        return;
      }
      
      AppLogger.info('HistoryProvider: Auth state changed - authenticated: ${_authProvider.isAuthenticated}, hasInitialized: $_hasInitialized');

      if (_authProvider.isAuthenticated && !_hasInitialized) {
        AppLogger.info('HistoryProvider: Auth state ready, initializing history');
        _hasInitialized = true;
        _initializeHistory();
      } else if (_authProvider.isAuthenticated && _hasInitialized && _allHistoryItems.isEmpty) {
        // Retry loading if auth is ready but we have no data (could be from previous failure)
        AppLogger.info('HistoryProvider: Auth ready and no data, retrying history load');
        _initializeHistory();
      } else if (!_authProvider.isAuthenticated && _hasInitialized) {
        AppLogger.info('HistoryProvider: Auth state lost, clearing history');
        _hasInitialized = false;
        _clearHistory();
      }
    } catch (e) {
      // Catch any errors that might occur if provider is in inconsistent state
      AppLogger.warning('HistoryProvider._onAuthStateChanged error (likely disposed): $e');
    }
  }

  /// Initialize history data when auth is ready
  Future<void> _initializeHistory() async {
    try {
      // Check if provider is disposed before proceeding
      if (_historyDisposed) return;
      
      await loadHistory();
      
      // CRITICAL: Check disposed again after async operation
      if (_historyDisposed) return;
      
      AppLogger.info('HistoryProvider: History initialized successfully');
    } catch (e) {
      // CRITICAL: Check disposed before logging (logger might trigger UI updates)
      if (_historyDisposed) return;
      AppLogger.error('HistoryProvider: Failed to initialize history', e);
    }
  }

  /// Clear history data when auth is lost
  void _clearHistory() {
    _allHistoryItems.clear();
    _filteredHistoryItems.clear();
    if (!_historyDisposed) {
      notifyListeners();
    }
    AppLogger.info('HistoryProvider: History cleared');
  }

  /// Initialize history provider (legacy method for backward compatibility)
  Future<void> initialize() async {
    AppLogger.info('HistoryProvider: Initialize called');
    
    // CRITICAL: Check disposed first
    if (_historyDisposed) return;

    // Wait for auth to be ready if it's still initializing
    if (!_authProvider.hasInitialized) {
      AppLogger.info('HistoryProvider: Auth still initializing, waiting...');
      // Wait up to 5 seconds for auth to initialize
      int attempts = 0;
      while (!_authProvider.hasInitialized && attempts < 50) {
        // CRITICAL: Check disposed in loop
        if (_historyDisposed) return;
        
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
    }

    // CRITICAL: Check disposed after async wait
    if (_historyDisposed) return;

    if (_authProvider.isAuthenticated) {
      AppLogger.info('HistoryProvider: Auth ready, loading history');
      await _initializeHistory();
    } else {
      AppLogger.info('HistoryProvider: Auth not ready, waiting for auth state');
      // Will be handled by _onAuthStateChanged when auth becomes ready
    }
  }

  /// Load history items with authentication check
  Future<void> loadHistory() async {
    // CRITICAL: Check disposed first
    if (_historyDisposed) return;
    
    // Check authentication before making API call
    if (!_authProvider.isAuthenticated) {
      AppLogger.warning('HistoryProvider: Cannot load history - user not authenticated');
      setError('Vui lòng đăng nhập để xem lịch sử');
      return;
    }

    final result = await executeApiOperation(
      () => _historyRepository.getAllHistory(),
      operationName: 'loadHistory',
    );

    // CRITICAL: Check disposed after async operation
    if (_historyDisposed) return;

    if (result != null) {
      _allHistoryItems = result;

      // Apply current filters
      _applyFilters();

      AppLogger.info('Loaded ${_allHistoryItems.length} history items from API');
      if (!_historyDisposed) {
        notifyListeners();
      }
    } else {
      // Don't use mock data - show real error to user
      AppLogger.error('Failed to load history from API');
      _allHistoryItems = [];
      _applyFilters();
      if (!_historyDisposed) {
        notifyListeners();
      }
    }
  }

  /// Refresh history
  Future<void> refreshHistory() async {
    AppLogger.info('Refreshing history');
    await loadHistory();
  }

  /// Search history items
  void searchHistory(String query) {
    _searchQuery = query.trim();
    _isSearching = query.isNotEmpty;

    // Debounce search to avoid excessive filtering
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_historyDisposed) {
        _applyFilters();
        notifyListeners();
      }
    });

    AppLogger.info('Searching history: "$query"');
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    _searchDebounceTimer?.cancel();
    _applyFilters();
    if (!_historyDisposed) {
      notifyListeners();
    }
    AppLogger.info('Search cleared');
  }

  /// Update filter configuration
  void updateFilter(HistoryFilterConfig newConfig) {
    _filterConfig = newConfig;
    _applyFilters();
    if (!_historyDisposed) {
      notifyListeners();
    }
    AppLogger.info('Filter updated: ${newConfig.filterDisplayName}');
  }

  /// Set filter type
  void setFilter(HistoryFilter filter) {
    _filterConfig = _filterConfig.copyWith(filter: filter);
    _applyFilters();
    if (!_historyDisposed) {
      notifyListeners();
    }
    AppLogger.info('Filter set to: ${filter.name}');
  }

  /// Set sort type
  void setSort(HistorySort sort) {
    _filterConfig = _filterConfig.copyWith(sort: sort);
    _applyFilters();
    if (!_historyDisposed) {
      notifyListeners();
    }
    AppLogger.info('Sort set to: ${sort.name}');
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String itemId) async {
    try {
      final itemIndex = _allHistoryItems.indexWhere((item) => item.id == itemId);
      if (itemIndex == -1) return;

      final item = _allHistoryItems[itemIndex];
      final updatedItem = item.copyWith(isFavorite: !item.isFavorite);
      
      _allHistoryItems[itemIndex] = updatedItem;
      _applyFilters();
      if (!_historyDisposed) {
        notifyListeners();
      }

      AppLogger.info('Toggled favorite for item: $itemId');
    } catch (e) {
      AppLogger.error('Failed to toggle favorite', e);
      setError('Không thể cập nhật yêu thích');
    }
  }

  /// Delete history item
  Future<void> deleteHistoryItem(String itemId) async {
    try {
      _allHistoryItems.removeWhere((item) => item.id == itemId);
      _applyFilters();
      if (!_historyDisposed) {
        notifyListeners();
      }

      AppLogger.info('Deleted history item: $itemId');
    } catch (e) {
      AppLogger.error('Failed to delete history item', e);
      setError('Không thể xóa mục lịch sử');
    }
  }

  /// Clear all history
  Future<void> clearAllHistory() async {
    try {
      _allHistoryItems.clear();
      _filteredHistoryItems.clear();
      if (!_historyDisposed) {
        notifyListeners();
      }

      AppLogger.info('Cleared all history');
    } catch (e) {
      AppLogger.error('Failed to clear history', e);
      setError('Không thể xóa lịch sử');
    }
  }

  /// Get history item by ID
  HistoryItemModel? getHistoryItemById(String id) {
    try {
      return _allHistoryItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get items by type
  List<HistoryItemModel> getItemsByType(HistoryItemType type) {
    return _allHistoryItems.where((item) => item.type == type).toList();
  }

  /// Get recent items
  List<HistoryItemModel> getRecentItems({int limit = 5}) {
    final sortedItems = List<HistoryItemModel>.from(_allHistoryItems);
    sortedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedItems.take(limit).toList();
  }

  /// Get favorite items
  List<HistoryItemModel> getFavoriteItems() {
    return _allHistoryItems.where((item) => item.isFavorite).toList();
  }

  /// Get palm analysis detail from server by ID
  Future<PalmAnalysisServerModel?> getPalmAnalysisDetail(int analysisId) async {
    // CRITICAL: Check disposed first
    if (_historyDisposed) return null;
    
    try {
      AppLogger.info('Getting palm analysis detail for ID: $analysisId');

      final result = await executeApiOperation(
        () => _palmAnalysisHistoryService.getPalmAnalysisById(analysisId),
        operationName: 'getPalmAnalysisDetail',
      );

      // CRITICAL: Check disposed after async operation
      if (_historyDisposed) return null;

      if (result != null) {
        AppLogger.info('Palm analysis detail retrieved successfully');
        return result;
      } else {
        AppLogger.error('Failed to get palm analysis detail');
        return null;
      }
    } catch (e) {
      if (_historyDisposed) return null;
      AppLogger.error('Exception in getPalmAnalysisDetail', e);
      return null;
    }
  }

  /// Get all facial analysis history from server
  Future<List<FacialAnalysisServerModel>> getFacialAnalysisHistory() async {
    // CRITICAL: Check disposed first
    if (_historyDisposed) return [];
    
    try {
      AppLogger.info('Getting facial analysis history from server');

      final result = await executeApiOperation(
        () => _facialAnalysisHistoryService.getFacialAnalysisHistory(),
        operationName: 'getFacialAnalysisHistory',
      );

      // CRITICAL: Check disposed after async operation
      if (_historyDisposed) return [];

      if (result != null) {
        AppLogger.info('Facial analysis history retrieved: ${result.length} items');
        return result;
      } else {
        AppLogger.error('Failed to get facial analysis history');
        return [];
      }
    } catch (e) {
      if (_historyDisposed) return [];
      AppLogger.error('Exception in getFacialAnalysisHistory', e);
      return [];
    }
  }

  /// Get all palm analysis history from server
  Future<List<PalmAnalysisServerModel>> getPalmAnalysisHistory() async {
    // CRITICAL: Check disposed first
    if (_historyDisposed) return [];
    
    try {
      AppLogger.info('Getting palm analysis history from server');

      final result = await executeApiOperation(
        () => _palmAnalysisHistoryService.getPalmAnalysisHistory(),
        operationName: 'getPalmAnalysisHistory',
      );

      // CRITICAL: Check disposed after async operation
      if (_historyDisposed) return [];

      if (result != null) {
        AppLogger.info('Palm analysis history retrieved: ${result.length} items');
        return result;
      } else {
        AppLogger.error('Failed to get palm analysis history');
        return [];
      }
    } catch (e) {
      if (_historyDisposed) return [];
      AppLogger.error('Exception in getPalmAnalysisHistory', e);
      return [];
    }
  }

  /// Apply filters and sorting
  void _applyFilters() {
    List<HistoryItemModel> filtered = List.from(_allHistoryItems);

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final query = _searchQuery.toLowerCase();
        return item.title.toLowerCase().contains(query) ||
               item.description.toLowerCase().contains(query) ||
               item.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // Apply type filter
    switch (_filterConfig.filter) {
      case HistoryFilter.faceAnalysis:
        filtered = filtered.where((item) => item.type == HistoryItemType.faceAnalysis).toList();
        break;
      case HistoryFilter.palmAnalysis:
        filtered = filtered.where((item) => item.type == HistoryItemType.palmAnalysis).toList();
        break;
      case HistoryFilter.chatConversation:
        filtered = filtered.where((item) => item.type == HistoryItemType.chatConversation).toList();
        break;
      case HistoryFilter.favorites:
        filtered = filtered.where((item) => item.isFavorite).toList();
        break;
      case HistoryFilter.recent:
        final recentDate = DateTime.now().subtract(const Duration(days: 7));
        filtered = filtered.where((item) => item.createdAt.isAfter(recentDate)).toList();
        break;
      case HistoryFilter.thisWeek:
        final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
        filtered = filtered.where((item) => item.createdAt.isAfter(weekStart)).toList();
        break;
      case HistoryFilter.thisMonth:
        final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
        filtered = filtered.where((item) => item.createdAt.isAfter(monthStart)).toList();
        break;
      case HistoryFilter.all:
        // No additional filtering
        break;
    }

    // Apply date range filter
    if (_filterConfig.dateFrom != null) {
      filtered = filtered.where((item) => item.createdAt.isAfter(_filterConfig.dateFrom!)).toList();
    }
    if (_filterConfig.dateTo != null) {
      filtered = filtered.where((item) => item.createdAt.isBefore(_filterConfig.dateTo!)).toList();
    }

    // Apply tag filter
    if (_filterConfig.tags.isNotEmpty) {
      filtered = filtered.where((item) {
        return _filterConfig.tags.any((tag) => item.tags.contains(tag));
      }).toList();
    }

    // Apply sorting
    switch (_filterConfig.sort) {
      case HistorySort.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case HistorySort.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case HistorySort.alphabetical:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case HistorySort.mostUsed:
        // For now, sort by update time as a proxy for usage
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case HistorySort.favorites:
        filtered.sort((a, b) {
          if (a.isFavorite && !b.isFavorite) return -1;
          if (!a.isFavorite && b.isFavorite) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
    }

    _filteredHistoryItems = filtered;
  }

  @override
  void dispose() {
    AppLogger.info('HistoryProvider.dispose() called - removing auth listener');
    // CRITICAL: Set disposed flag FIRST to prevent any callbacks
    _historyDisposed = true;
    
    // Remove listener in try-catch to handle edge cases
    try {
      _authProvider.removeListener(_onAuthStateChanged);
    } catch (e) {
      AppLogger.warning('HistoryProvider: Error removing auth listener: $e');
    }
    
    _searchDebounceTimer?.cancel();
    _authStateSubscription?.cancel();
    AppLogger.info('HistoryProvider.dispose() completed');
    super.dispose();
  }
}
