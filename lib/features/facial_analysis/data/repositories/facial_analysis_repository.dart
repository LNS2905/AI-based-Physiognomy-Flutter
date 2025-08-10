// Facial Analysis Repository
import 'dart:convert';
import 'dart:io';
import 'package:ai_physiognomy_app/core/utils/logger.dart';
import 'package:ai_physiognomy_app/features/facial_analysis/data/services/facial_analysis_api_service.dart';
import 'package:ai_physiognomy_app/features/facial_analysis/data/models/facial_analysis_models.dart';

class FacialAnalysisRepository {
  final FacialAnalysisApiService _apiService;

  FacialAnalysisRepository({
    FacialAnalysisApiService? apiService,
  }) : _apiService = apiService ?? FacialAnalysisApiService();

  /// Process facial analysis from image file
  Future<FacialAnalysis> processFacialAnalysisFromFile(File imageFile) async {
    try {
      AppLogger.info('FacialAnalysisRepository: Processing facial analysis from file');
      
      // Convert image to base64
      final imageBytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);
      
      // Process analysis
      final analysisDto = await _apiService.processFacialAnalysis(imageBase64);
      
      // Save to backend
      final analysis = await _apiService.saveFacialAnalysis(analysisDto);
      
      AppLogger.info('FacialAnalysisRepository: Facial analysis processed and saved successfully');
      return analysis;
    } catch (e) {
      AppLogger.error('FacialAnalysisRepository: Process facial analysis from file failed', e);
      rethrow;
    }
  }

  /// Process facial analysis from base64 string
  Future<FacialAnalysis> processFacialAnalysisFromBase64(String imageBase64) async {
    try {
      AppLogger.info('FacialAnalysisRepository: Processing facial analysis from base64');
      
      // Process analysis
      final analysisDto = await _apiService.processFacialAnalysis(imageBase64);
      
      // Save to backend
      final analysis = await _apiService.saveFacialAnalysis(analysisDto);
      
      AppLogger.info('FacialAnalysisRepository: Facial analysis processed and saved successfully');
      return analysis;
    } catch (e) {
      AppLogger.error('FacialAnalysisRepository: Process facial analysis from base64 failed', e);
      rethrow;
    }
  }

  /// Save facial analysis result
  Future<FacialAnalysis> saveFacialAnalysis(FacialAnalysisDto analysisDto) async {
    try {
      AppLogger.info('FacialAnalysisRepository: Saving facial analysis');
      
      final analysis = await _apiService.saveFacialAnalysis(analysisDto);
      
      AppLogger.info('FacialAnalysisRepository: Facial analysis saved successfully');
      return analysis;
    } catch (e) {
      AppLogger.error('FacialAnalysisRepository: Save facial analysis failed', e);
      rethrow;
    }
  }

  /// Get facial analyses by user ID
  Future<List<FacialAnalysis>> getFacialAnalysesByUser(int userId) async {
    try {
      AppLogger.info('FacialAnalysisRepository: Getting facial analyses for user $userId');
      
      final analyses = await _apiService.getFacialAnalysesByUser(userId);
      
      AppLogger.info('FacialAnalysisRepository: Retrieved ${analyses.length} facial analyses');
      return analyses;
    } catch (e) {
      AppLogger.error('FacialAnalysisRepository: Get facial analyses by user failed', e);
      rethrow;
    }
  }

  /// Get facial analysis summaries for list view
  Future<List<FacialAnalysisSummary>> getFacialAnalysisSummaries(int userId) async {
    try {
      AppLogger.info('FacialAnalysisRepository: Getting facial analysis summaries for user $userId');
      
      final summaries = await _apiService.getFacialAnalysisSummaries(userId);
      
      AppLogger.info('FacialAnalysisRepository: Retrieved ${summaries.length} facial analysis summaries');
      return summaries;
    } catch (e) {
      AppLogger.error('FacialAnalysisRepository: Get facial analysis summaries failed', e);
      rethrow;
    }
  }

  /// Get single facial analysis by ID
  Future<FacialAnalysis> getFacialAnalysisById(int id) async {
    try {
      AppLogger.info('FacialAnalysisRepository: Getting facial analysis $id');
      
      final analysis = await _apiService.getFacialAnalysisById(id);
      
      AppLogger.info('FacialAnalysisRepository: Retrieved facial analysis $id');
      return analysis;
    } catch (e) {
      AppLogger.error('FacialAnalysisRepository: Get facial analysis by ID failed', e);
      rethrow;
    }
  }

  /// Update facial analysis
  Future<FacialAnalysis> updateFacialAnalysis(int id, FacialAnalysisDto analysisDto) async {
    try {
      AppLogger.info('FacialAnalysisRepository: Updating facial analysis $id');
      
      final analysis = await _apiService.updateFacialAnalysis(id, analysisDto);
      
      AppLogger.info('FacialAnalysisRepository: Facial analysis updated successfully');
      return analysis;
    } catch (e) {
      AppLogger.error('FacialAnalysisRepository: Update facial analysis failed', e);
      rethrow;
    }
  }

  /// Delete facial analysis
  Future<void> deleteFacialAnalysis(int id) async {
    try {
      AppLogger.info('FacialAnalysisRepository: Deleting facial analysis $id');
      
      await _apiService.deleteFacialAnalysis(id);
      
      AppLogger.info('FacialAnalysisRepository: Facial analysis deleted successfully');
    } catch (e) {
      AppLogger.error('FacialAnalysisRepository: Delete facial analysis failed', e);
      rethrow;
    }
  }

  /// Get latest facial analysis for user
  Future<FacialAnalysis?> getLatestFacialAnalysis(int userId) async {
    try {
      AppLogger.info('FacialAnalysisRepository: Getting latest facial analysis for user $userId');
      
      final analyses = await getFacialAnalysesByUser(userId);
      
      if (analyses.isEmpty) {
        AppLogger.info('FacialAnalysisRepository: No facial analyses found for user $userId');
        return null;
      }
      
      // Sort by creation date and get the latest
      analyses.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.parse(a.processedAt);
        final bDate = b.createdAt ?? DateTime.parse(b.processedAt);
        return bDate.compareTo(aDate);
      });
      
      final latest = analyses.first;
      AppLogger.info('FacialAnalysisRepository: Retrieved latest facial analysis');
      return latest;
    } catch (e) {
      AppLogger.error('FacialAnalysisRepository: Get latest facial analysis failed', e);
      rethrow;
    }
  }

  /// Get facial analyses count for user
  Future<int> getFacialAnalysesCount(int userId) async {
    try {
      AppLogger.info('FacialAnalysisRepository: Getting facial analyses count for user $userId');
      
      final analyses = await getFacialAnalysesByUser(userId);
      final count = analyses.length;
      
      AppLogger.info('FacialAnalysisRepository: User $userId has $count facial analyses');
      return count;
    } catch (e) {
      AppLogger.error('FacialAnalysisRepository: Get facial analyses count failed', e);
      rethrow;
    }
  }

  /// Get facial analyses with pagination
  Future<List<FacialAnalysis>> getFacialAnalysesWithPagination(
    int userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      AppLogger.info('FacialAnalysisRepository: Getting facial analyses with pagination for user $userId (page: $page, limit: $limit)');
      
      final allAnalyses = await getFacialAnalysesByUser(userId);
      
      // Sort by creation date (newest first)
      allAnalyses.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.parse(a.processedAt);
        final bDate = b.createdAt ?? DateTime.parse(b.processedAt);
        return bDate.compareTo(aDate);
      });
      
      // Apply pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      
      if (startIndex >= allAnalyses.length) {
        AppLogger.info('FacialAnalysisRepository: No more facial analyses for page $page');
        return [];
      }
      
      final paginatedAnalyses = allAnalyses.sublist(
        startIndex,
        endIndex > allAnalyses.length ? allAnalyses.length : endIndex,
      );
      
      AppLogger.info('FacialAnalysisRepository: Retrieved ${paginatedAnalyses.length} facial analyses for page $page');
      return paginatedAnalyses;
    } catch (e) {
      AppLogger.error('FacialAnalysisRepository: Get facial analyses with pagination failed', e);
      rethrow;
    }
  }

  /// Search facial analyses by face shape
  Future<List<FacialAnalysis>> searchFacialAnalysesByFaceShape(
    int userId,
    String faceShape,
  ) async {
    try {
      AppLogger.info('FacialAnalysisRepository: Searching facial analyses by face shape "$faceShape" for user $userId');
      
      final allAnalyses = await getFacialAnalysesByUser(userId);
      
      final filteredAnalyses = allAnalyses
          .where((analysis) => analysis.faceShape.toLowerCase() == faceShape.toLowerCase())
          .toList();
      
      // Sort by creation date (newest first)
      filteredAnalyses.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.parse(a.processedAt);
        final bDate = b.createdAt ?? DateTime.parse(b.processedAt);
        return bDate.compareTo(aDate);
      });
      
      AppLogger.info('FacialAnalysisRepository: Found ${filteredAnalyses.length} facial analyses with face shape "$faceShape"');
      return filteredAnalyses;
    } catch (e) {
      AppLogger.error('FacialAnalysisRepository: Search facial analyses by face shape failed', e);
      rethrow;
    }
  }

  /// Get facial analyses statistics for user
  Future<Map<String, dynamic>> getFacialAnalysesStatistics(int userId) async {
    try {
      AppLogger.info('FacialAnalysisRepository: Getting facial analyses statistics for user $userId');

      final analyses = await getFacialAnalysesByUser(userId);

      if (analyses.isEmpty) {
        return {
          'totalCount': 0,
          'averageHarmonyScore': 0.0,
          'faceShapeDistribution': <String, int>{},
          'latestAnalysisDate': null,
        };
      }

      // Calculate statistics
      final totalCount = analyses.length;
      final averageHarmonyScore = analyses
          .map((a) => a.harmonyScore)
          .reduce((a, b) => a + b) / totalCount;

      // Face shape distribution
      final faceShapeDistribution = <String, int>{};
      for (final analysis in analyses) {
        faceShapeDistribution[analysis.faceShape] =
            (faceShapeDistribution[analysis.faceShape] ?? 0) + 1;
      }

      // Latest analysis date
      final latestDate = analyses
          .map((a) => a.createdAt ?? DateTime.parse(a.processedAt))
          .reduce((a, b) => a.isAfter(b) ? a : b);

      final statistics = {
        'totalCount': totalCount,
        'averageHarmonyScore': averageHarmonyScore,
        'faceShapeDistribution': faceShapeDistribution,
        'latestAnalysisDate': latestDate.toIso8601String(),
      };

      AppLogger.info('FacialAnalysisRepository: Retrieved facial analyses statistics');
      return statistics;
    } catch (e) {
      AppLogger.error('FacialAnalysisRepository: Get facial analyses statistics failed', e);
      rethrow;
    }
  }
}
