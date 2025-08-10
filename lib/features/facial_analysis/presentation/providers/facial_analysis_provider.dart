// Facial Analysis Provider
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ai_physiognomy_app/core/providers/base_provider.dart';
import 'package:ai_physiognomy_app/core/utils/logger.dart';
import 'package:ai_physiognomy_app/features/facial_analysis/data/repositories/facial_analysis_repository.dart';
import 'package:ai_physiognomy_app/features/facial_analysis/data/models/facial_analysis_models.dart';

class FacialAnalysisProvider extends BaseProvider {
  final FacialAnalysisRepository _repository;

  FacialAnalysisProvider({
    FacialAnalysisRepository? repository,
  }) : _repository = repository ?? FacialAnalysisRepository();

  // State
  List<FacialAnalysis> _analyses = [];
  List<FacialAnalysisSummary> _summaries = [];
  FacialAnalysis? _currentAnalysis;
  Map<String, dynamic>? _statistics;

  // Getters
  List<FacialAnalysis> get analyses => _analyses;
  List<FacialAnalysisSummary> get summaries => _summaries;
  FacialAnalysis? get currentAnalysis => _currentAnalysis;
  Map<String, dynamic>? get statistics => _statistics;
  
  bool get hasAnalyses => _analyses.isNotEmpty;
  int get analysesCount => _analyses.length;

  /// Process facial analysis from image file
  Future<void> processFacialAnalysisFromFile(File imageFile) async {
    await executeApiOperation(
      operation: () async {
        AppLogger.info('FacialAnalysisProvider: Processing facial analysis from file');
        
        final analysis = await _repository.processFacialAnalysisFromFile(imageFile);
        
        _currentAnalysis = analysis;
        _analyses.insert(0, analysis); // Add to beginning of list
        
        AppLogger.info('FacialAnalysisProvider: Facial analysis processed successfully');
        return analysis;
      },
      operationName: 'process_facial_analysis_file',
    );
  }

  /// Process facial analysis from base64 string
  Future<void> processFacialAnalysisFromBase64(String imageBase64) async {
    await executeApiOperation(
      operation: () async {
        AppLogger.info('FacialAnalysisProvider: Processing facial analysis from base64');
        
        final analysis = await _repository.processFacialAnalysisFromBase64(imageBase64);
        
        _currentAnalysis = analysis;
        _analyses.insert(0, analysis); // Add to beginning of list
        
        AppLogger.info('FacialAnalysisProvider: Facial analysis processed successfully');
        return analysis;
      },
      operationName: 'process_facial_analysis_base64',
    );
  }

  /// Load facial analyses for user
  Future<void> loadFacialAnalyses(int userId) async {
    await executeApiOperation(
      operation: () async {
        AppLogger.info('FacialAnalysisProvider: Loading facial analyses for user $userId');
        
        final analyses = await _repository.getFacialAnalysesByUser(userId);
        
        _analyses = analyses;
        
        AppLogger.info('FacialAnalysisProvider: Loaded ${analyses.length} facial analyses');
        return analyses;
      },
      operationName: 'load_facial_analyses',
    );
  }

  /// Load facial analysis summaries for user
  Future<void> loadFacialAnalysisSummaries(int userId) async {
    await executeApiOperation(
      operation: () async {
        AppLogger.info('FacialAnalysisProvider: Loading facial analysis summaries for user $userId');
        
        final summaries = await _repository.getFacialAnalysisSummaries(userId);
        
        _summaries = summaries;
        
        AppLogger.info('FacialAnalysisProvider: Loaded ${summaries.length} facial analysis summaries');
        return summaries;
      },
      operationName: 'load_facial_analysis_summaries',
    );
  }

  /// Get facial analysis by ID
  Future<void> getFacialAnalysisById(int id) async {
    await executeApiOperation(
      operation: () async {
        AppLogger.info('FacialAnalysisProvider: Getting facial analysis $id');
        
        final analysis = await _repository.getFacialAnalysisById(id);
        
        _currentAnalysis = analysis;
        
        AppLogger.info('FacialAnalysisProvider: Retrieved facial analysis $id');
        return analysis;
      },
      operationName: 'get_facial_analysis_by_id',
    );
  }

  /// Update facial analysis
  Future<void> updateFacialAnalysis(int id, FacialAnalysisDto analysisDto) async {
    await executeApiOperation(
      operation: () async {
        AppLogger.info('FacialAnalysisProvider: Updating facial analysis $id');
        
        final analysis = await _repository.updateFacialAnalysis(id, analysisDto);
        
        // Update in local list
        final index = _analyses.indexWhere((a) => a.id == id);
        if (index != -1) {
          _analyses[index] = analysis;
        }
        
        // Update current analysis if it's the same
        if (_currentAnalysis?.id == id) {
          _currentAnalysis = analysis;
        }
        
        AppLogger.info('FacialAnalysisProvider: Facial analysis updated successfully');
        return analysis;
      },
      operationName: 'update_facial_analysis',
    );
  }

  /// Delete facial analysis
  Future<void> deleteFacialAnalysis(int id) async {
    await executeApiOperation(
      operation: () async {
        AppLogger.info('FacialAnalysisProvider: Deleting facial analysis $id');
        
        await _repository.deleteFacialAnalysis(id);
        
        // Remove from local list
        _analyses.removeWhere((a) => a.id == id);
        _summaries.removeWhere((s) => s.id == id);
        
        // Clear current analysis if it's the same
        if (_currentAnalysis?.id == id) {
          _currentAnalysis = null;
        }
        
        AppLogger.info('FacialAnalysisProvider: Facial analysis deleted successfully');
        return true;
      },
      operationName: 'delete_facial_analysis',
    );
  }

  /// Load facial analyses statistics
  Future<void> loadFacialAnalysesStatistics(int userId) async {
    await executeApiOperation(
      operation: () async {
        AppLogger.info('FacialAnalysisProvider: Loading facial analyses statistics for user $userId');
        
        final statistics = await _repository.getFacialAnalysesStatistics(userId);
        
        _statistics = statistics;
        
        AppLogger.info('FacialAnalysisProvider: Loaded facial analyses statistics');
        return statistics;
      },
      operationName: 'load_facial_analyses_statistics',
    );
  }

  /// Get latest facial analysis
  Future<void> getLatestFacialAnalysis(int userId) async {
    await executeApiOperation(
      operation: () async {
        AppLogger.info('FacialAnalysisProvider: Getting latest facial analysis for user $userId');
        
        final analysis = await _repository.getLatestFacialAnalysis(userId);
        
        _currentAnalysis = analysis;
        
        AppLogger.info('FacialAnalysisProvider: Retrieved latest facial analysis');
        return analysis;
      },
      operationName: 'get_latest_facial_analysis',
    );
  }

  /// Load facial analyses with pagination
  Future<void> loadFacialAnalysesWithPagination(
    int userId, {
    int page = 1,
    int limit = 10,
    bool append = false,
  }) async {
    await executeApiOperation(
      operation: () async {
        AppLogger.info('FacialAnalysisProvider: Loading facial analyses with pagination (page: $page, limit: $limit)');
        
        final analyses = await _repository.getFacialAnalysesWithPagination(
          userId,
          page: page,
          limit: limit,
        );
        
        if (append) {
          _analyses.addAll(analyses);
        } else {
          _analyses = analyses;
        }
        
        AppLogger.info('FacialAnalysisProvider: Loaded ${analyses.length} facial analyses for page $page');
        return analyses;
      },
      operationName: 'load_facial_analyses_pagination',
    );
  }

  /// Search facial analyses by face shape
  Future<void> searchFacialAnalysesByFaceShape(int userId, String faceShape) async {
    await executeApiOperation(
      operation: () async {
        AppLogger.info('FacialAnalysisProvider: Searching facial analyses by face shape "$faceShape"');
        
        final analyses = await _repository.searchFacialAnalysesByFaceShape(userId, faceShape);
        
        _analyses = analyses;
        
        AppLogger.info('FacialAnalysisProvider: Found ${analyses.length} facial analyses with face shape "$faceShape"');
        return analyses;
      },
      operationName: 'search_facial_analyses_by_face_shape',
    );
  }

  /// Refresh facial analyses data
  Future<void> refreshFacialAnalyses(int userId) async {
    await loadFacialAnalyses(userId);
    await loadFacialAnalysisSummaries(userId);
    await loadFacialAnalysesStatistics(userId);
  }

  /// Clear current analysis
  void clearCurrentAnalysis() {
    _currentAnalysis = null;
    notifyListeners();
    AppLogger.info('FacialAnalysisProvider: Current analysis cleared');
  }

  /// Clear all data
  void clearAllData() {
    _analyses.clear();
    _summaries.clear();
    _currentAnalysis = null;
    _statistics = null;
    notifyListeners();
    AppLogger.info('FacialAnalysisProvider: All data cleared');
  }

  /// Get analysis by ID from local list
  FacialAnalysis? getAnalysisFromList(int id) {
    try {
      return _analyses.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get face shape distribution from statistics
  Map<String, int> get faceShapeDistribution {
    return _statistics?['faceShapeDistribution'] ?? <String, int>{};
  }

  /// Get average harmony score from statistics
  double get averageHarmonyScore {
    return _statistics?['averageHarmonyScore'] ?? 0.0;
  }

  /// Get total analyses count from statistics
  int get totalAnalysesCount {
    return _statistics?['totalCount'] ?? 0;
  }

  /// Get latest analysis date from statistics
  DateTime? get latestAnalysisDate {
    final dateString = _statistics?['latestAnalysisDate'];
    if (dateString != null) {
      return DateTime.tryParse(dateString);
    }
    return null;
  }

  /// Check if user has any analyses
  bool hasAnalysesForUser(int userId) {
    return _analyses.any((a) => a.userId == userId.toString());
  }

  /// Get analyses count for specific face shape
  int getAnalysesCountForFaceShape(String faceShape) {
    return _analyses.where((a) => a.faceShape.toLowerCase() == faceShape.toLowerCase()).length;
  }

  /// Get highest harmony score analysis
  FacialAnalysis? get highestHarmonyScoreAnalysis {
    if (_analyses.isEmpty) return null;
    
    return _analyses.reduce((a, b) => a.harmonyScore > b.harmonyScore ? a : b);
  }

  /// Get most recent analysis
  FacialAnalysis? get mostRecentAnalysis {
    if (_analyses.isEmpty) return null;
    
    return _analyses.reduce((a, b) {
      final aDate = a.createdAt ?? DateTime.parse(a.processedAt);
      final bDate = b.createdAt ?? DateTime.parse(b.processedAt);
      return aDate.isAfter(bDate) ? a : b;
    });
  }
}
