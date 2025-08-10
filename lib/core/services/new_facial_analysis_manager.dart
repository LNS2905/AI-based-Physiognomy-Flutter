// New Facial Analysis Manager for Backend Integration
import 'dart:convert';
import 'dart:io';
import 'package:ai_physiognomy_app/core/utils/logger.dart';
import 'package:ai_physiognomy_app/core/services/new_api_service.dart';
import 'package:ai_physiognomy_app/core/services/new_auth_manager.dart';
import 'package:ai_physiognomy_app/features/facial_analysis/data/models/facial_analysis_models.dart';

class NewFacialAnalysisManager {
  static final NewFacialAnalysisManager _instance = NewFacialAnalysisManager._internal();
  factory NewFacialAnalysisManager() => _instance;
  NewFacialAnalysisManager._internal();

  final NewApiService _apiService = NewApiService();
  final NewAuthManager _authManager = NewAuthManager();

  List<FacialAnalysis> _analyses = [];
  FacialAnalysis? _currentAnalysis;

  // Getters
  List<FacialAnalysis> get analyses => List.unmodifiable(_analyses);
  FacialAnalysis? get currentAnalysis => _currentAnalysis;
  bool get hasAnalyses => _analyses.isNotEmpty;
  int get analysesCount => _analyses.length;

  /// Process facial analysis from image file
  Future<FacialAnalysis> processFacialAnalysisFromFile(File imageFile) async {
    try {
      AppLogger.info('NewFacialAnalysisManager: Processing facial analysis from file');
      
      // Convert image to base64
      final imageBytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);
      
      return await processFacialAnalysisFromBase64(imageBase64);
    } catch (e) {
      AppLogger.error('NewFacialAnalysisManager: Process facial analysis from file failed', e);
      rethrow;
    }
  }

  /// Process facial analysis from base64 string
  Future<FacialAnalysis> processFacialAnalysisFromBase64(String imageBase64) async {
    try {
      AppLogger.info('NewFacialAnalysisManager: Processing facial analysis from base64');
      
      final userId = _authManager.userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Create mock analysis data (replace with actual AI processing)
      final analysisDto = _createMockAnalysisDto(userId.toString(), imageBase64);
      
      // Save to backend
      final analysisData = await _apiService.saveFacialAnalysis(analysisDto.toJson());
      final analysis = FacialAnalysis.fromJson(analysisData);
      
      // Update local state
      _currentAnalysis = analysis;
      _analyses.insert(0, analysis); // Add to beginning of list
      
      AppLogger.info('NewFacialAnalysisManager: Facial analysis processed and saved successfully');
      return analysis;
    } catch (e) {
      AppLogger.error('NewFacialAnalysisManager: Process facial analysis from base64 failed', e);
      rethrow;
    }
  }

  /// Load facial analyses for current user
  Future<List<FacialAnalysis>> loadFacialAnalyses() async {
    try {
      AppLogger.info('NewFacialAnalysisManager: Loading facial analyses');
      
      final userId = _authManager.userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final analysesData = await _apiService.getFacialAnalysesByUser(userId);
      final analyses = analysesData.map((data) => FacialAnalysis.fromJson(data)).toList();
      
      // Sort by creation date (newest first)
      analyses.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.parse(a.processedAt);
        final bDate = b.createdAt ?? DateTime.parse(b.processedAt);
        return bDate.compareTo(aDate);
      });
      
      _analyses = analyses;
      
      AppLogger.info('NewFacialAnalysisManager: Loaded ${analyses.length} facial analyses');
      return analyses;
    } catch (e) {
      AppLogger.error('NewFacialAnalysisManager: Load facial analyses failed', e);
      rethrow;
    }
  }

  /// Get facial analysis by ID
  Future<FacialAnalysis> getFacialAnalysisById(int id) async {
    try {
      AppLogger.info('NewFacialAnalysisManager: Getting facial analysis $id');
      
      // First try to find in local list
      final localAnalysis = _analyses.where((a) => a.id == id).firstOrNull;
      if (localAnalysis != null) {
        _currentAnalysis = localAnalysis;
        AppLogger.info('NewFacialAnalysisManager: Found facial analysis $id in local cache');
        return localAnalysis;
      }
      
      // If not found locally, reload all analyses
      await loadFacialAnalyses();
      
      final analysis = _analyses.where((a) => a.id == id).firstOrNull;
      if (analysis == null) {
        throw Exception('Facial analysis not found');
      }
      
      _currentAnalysis = analysis;
      AppLogger.info('NewFacialAnalysisManager: Retrieved facial analysis $id');
      return analysis;
    } catch (e) {
      AppLogger.error('NewFacialAnalysisManager: Get facial analysis by ID failed', e);
      rethrow;
    }
  }

  /// Update facial analysis
  Future<FacialAnalysis> updateFacialAnalysis(int id, FacialAnalysisDto analysisDto) async {
    try {
      AppLogger.info('NewFacialAnalysisManager: Updating facial analysis $id');
      
      final analysisData = await _apiService.updateFacialAnalysis(id, analysisDto.toJson());
      final analysis = FacialAnalysis.fromJson(analysisData);
      
      // Update in local list
      final index = _analyses.indexWhere((a) => a.id == id);
      if (index != -1) {
        _analyses[index] = analysis;
      }
      
      // Update current analysis if it's the same
      if (_currentAnalysis?.id == id) {
        _currentAnalysis = analysis;
      }
      
      AppLogger.info('NewFacialAnalysisManager: Facial analysis updated successfully');
      return analysis;
    } catch (e) {
      AppLogger.error('NewFacialAnalysisManager: Update facial analysis failed', e);
      rethrow;
    }
  }

  /// Delete facial analysis
  Future<void> deleteFacialAnalysis(int id) async {
    try {
      AppLogger.info('NewFacialAnalysisManager: Deleting facial analysis $id');
      
      await _apiService.deleteFacialAnalysis(id);
      
      // Remove from local list
      _analyses.removeWhere((a) => a.id == id);
      
      // Clear current analysis if it's the same
      if (_currentAnalysis?.id == id) {
        _currentAnalysis = null;
      }
      
      AppLogger.info('NewFacialAnalysisManager: Facial analysis deleted successfully');
    } catch (e) {
      AppLogger.error('NewFacialAnalysisManager: Delete facial analysis failed', e);
      rethrow;
    }
  }

  /// Get latest facial analysis
  FacialAnalysis? getLatestFacialAnalysis() {
    if (_analyses.isEmpty) return null;
    
    return _analyses.first; // Already sorted by date in loadFacialAnalyses
  }

  /// Get facial analyses with pagination
  List<FacialAnalysis> getFacialAnalysesWithPagination({
    int page = 1,
    int limit = 10,
  }) {
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= _analyses.length) {
      return [];
    }
    
    return _analyses.sublist(
      startIndex,
      endIndex > _analyses.length ? _analyses.length : endIndex,
    );
  }

  /// Search facial analyses by face shape
  List<FacialAnalysis> searchFacialAnalysesByFaceShape(String faceShape) {
    return _analyses
        .where((analysis) => analysis.faceShape.toLowerCase() == faceShape.toLowerCase())
        .toList();
  }

  /// Get facial analyses statistics
  Map<String, dynamic> getFacialAnalysesStatistics() {
    if (_analyses.isEmpty) {
      return {
        'totalCount': 0,
        'averageHarmonyScore': 0.0,
        'faceShapeDistribution': <String, int>{},
        'latestAnalysisDate': null,
      };
    }
    
    // Calculate statistics
    final totalCount = _analyses.length;
    final averageHarmonyScore = _analyses
        .map((a) => a.harmonyScore)
        .reduce((a, b) => a + b) / totalCount;
    
    // Face shape distribution
    final faceShapeDistribution = <String, int>{};
    for (final analysis in _analyses) {
      faceShapeDistribution[analysis.faceShape] = 
          (faceShapeDistribution[analysis.faceShape] ?? 0) + 1;
    }
    
    // Latest analysis date
    final latestDate = _analyses
        .map((a) => a.createdAt ?? DateTime.parse(a.processedAt))
        .reduce((a, b) => a.isAfter(b) ? a : b);
    
    return {
      'totalCount': totalCount,
      'averageHarmonyScore': averageHarmonyScore,
      'faceShapeDistribution': faceShapeDistribution,
      'latestAnalysisDate': latestDate.toIso8601String(),
    };
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

  /// Clear current analysis
  void clearCurrentAnalysis() {
    _currentAnalysis = null;
    AppLogger.info('NewFacialAnalysisManager: Current analysis cleared');
  }

  /// Clear all data
  void clearAllData() {
    _analyses.clear();
    _currentAnalysis = null;
    AppLogger.info('NewFacialAnalysisManager: All data cleared');
  }

  /// Create mock analysis DTO (replace with actual AI processing)
  FacialAnalysisDto _createMockAnalysisDto(String userId, String imageBase64) {
    final now = DateTime.now().toIso8601String();
    
    // Mock analysis result - replace with actual AI service call
    return FacialAnalysisDto(
      userId: userId,
      resultText: 'Mock facial analysis result - This is a placeholder for actual AI analysis',
      faceShape: 'oval',
      harmonyScore: 0.85,
      probabilities: {
        'oval': 0.85,
        'round': 0.10,
        'square': 0.05,
      },
      harmonyDetails: {
        'symmetry': 0.90,
        'proportion': 0.80,
        'balance': 0.85,
      },
      metrics: [
        const FacialMetric(
          orientation: 'horizontal',
          percentage: 85.0,
          pixels: 120.0,
          label: 'Face width',
        ),
        const FacialMetric(
          orientation: 'vertical',
          percentage: 90.0,
          pixels: 150.0,
          label: 'Face height',
        ),
      ],
      annotatedImage: imageBase64, // In real implementation, this would be the processed image
      processedAt: now,
    );
  }

  /// Refresh facial analyses data
  Future<void> refreshFacialAnalyses() async {
    await loadFacialAnalyses();
  }
}
