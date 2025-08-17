import '../../../../core/utils/logger.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/errors/failures.dart';
import '../../../facial_analysis/data/repositories/facial_analysis_repository.dart';
import '../../../palm_scan/data/services/palm_analysis_history_service.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';

/// Service for fetching and calculating user analysis statistics
class AnalysisStatisticsService {
  final FacialAnalysisRepository _facialRepository;
  final PalmAnalysisHistoryService _palmHistoryService;
  final EnhancedAuthProvider _authProvider;

  AnalysisStatisticsService({
    FacialAnalysisRepository? facialRepository,
    PalmAnalysisHistoryService? palmHistoryService,
    required EnhancedAuthProvider authProvider,
  })  : _facialRepository = facialRepository ?? FacialAnalysisRepository(),
        _palmHistoryService = palmHistoryService ?? PalmAnalysisHistoryService(authProvider: authProvider),
        _authProvider = authProvider;

  /// Get comprehensive analysis statistics for the current user
  Future<ApiResult<Map<String, dynamic>>> getUserStatistics() async {
    try {
      final userId = _authProvider.userId;
      if (userId == null) {
        AppLogger.error('No current user found for statistics');
        return Error(AuthFailure(
          message: 'User not authenticated',
          code: 'NO_CURRENT_USER',
        ));
      }

      AppLogger.info('Fetching analysis statistics for user: $userId');

      // Fetch facial analysis statistics
      int faceAnalysesCount = 0;
      DateTime? lastFaceAnalysisDate;
      double averageHarmonyScore = 0.0;
      
      try {
        final facialAnalyses = await _facialRepository.getFacialAnalysesByUser(userId);
        faceAnalysesCount = facialAnalyses.length;
        
        if (facialAnalyses.isNotEmpty) {
          // Get latest facial analysis date
          final sortedAnalyses = List.from(facialAnalyses)
            ..sort((a, b) {
              final aDate = a.createdAt ?? DateTime.parse(a.processedAt);
              final bDate = b.createdAt ?? DateTime.parse(b.processedAt);
              return bDate.compareTo(aDate);
            });
          
          lastFaceAnalysisDate = sortedAnalyses.first.createdAt ?? 
                                 DateTime.parse(sortedAnalyses.first.processedAt);
          
          // Calculate average harmony score
          final totalHarmony = facialAnalyses
              .map((a) => a.harmonyScore)
              .reduce((a, b) => a + b);
          averageHarmonyScore = totalHarmony / faceAnalysesCount;
        }
        
        AppLogger.info('Facial analyses retrieved: $faceAnalysesCount');
      } catch (e) {
        AppLogger.warning('Failed to fetch facial analyses: $e');
        // Continue with default values
      }

      // Fetch palm analysis statistics
      int palmAnalysesCount = 0;
      DateTime? lastPalmAnalysisDate;
      
      try {
        final palmHistoryResult = await _palmHistoryService.getPalmAnalysisHistory();
        
        if (palmHistoryResult is Success) {
          final palmAnalyses = palmHistoryResult.data;
          if (palmAnalyses != null) {
            palmAnalysesCount = palmAnalyses.length;
            
            if (palmAnalyses.isNotEmpty) {
              // Get latest palm analysis date
              final sortedAnalyses = List.from(palmAnalyses)
                ..sort((a, b) {
                  final aDate = a.createdAt;
                  final bDate = b.createdAt;
                  return bDate.compareTo(aDate);
                });
              
              lastPalmAnalysisDate = sortedAnalyses.first.createdAt;
            }
          }
        }
        
        AppLogger.info('Palm analyses retrieved: $palmAnalysesCount');
      } catch (e) {
        AppLogger.warning('Failed to fetch palm analyses: $e');
        // Continue with default values
      }

      // Calculate overall statistics
      final totalAnalyses = faceAnalysesCount + palmAnalysesCount;
      
      // Determine last analysis date (most recent between face and palm)
      DateTime? lastAnalysisDate;
      if (lastFaceAnalysisDate != null && lastPalmAnalysisDate != null) {
        lastAnalysisDate = lastFaceAnalysisDate.isAfter(lastPalmAnalysisDate) 
            ? lastFaceAnalysisDate 
            : lastPalmAnalysisDate;
      } else {
        lastAnalysisDate = lastFaceAnalysisDate ?? lastPalmAnalysisDate;
      }

      // Determine member since date (use user creation date if available, otherwise first analysis)
      DateTime memberSince = DateTime.now().subtract(const Duration(days: 30)); // Default
      
      // Use earliest analysis date or default for member since
      final allDates = <DateTime>[];
      if (lastFaceAnalysisDate != null) allDates.add(lastFaceAnalysisDate);
      if (lastPalmAnalysisDate != null) allDates.add(lastPalmAnalysisDate);
      
      if (allDates.isNotEmpty) {
        allDates.sort();
        memberSince = allDates.first;
      }

      // Calculate accuracy score (mock calculation based on harmony scores)
      double accuracyScore = 85.0; // Default value
      if (averageHarmonyScore > 0) {
        // Convert harmony score (0-100) to accuracy score with some variation
        accuracyScore = (averageHarmonyScore * 0.9) + 10; // Ensures minimum 10%
        accuracyScore = accuracyScore.clamp(10.0, 100.0);
      }

      final statistics = {
        'totalAnalyses': totalAnalyses,
        'faceAnalyses': faceAnalysesCount,
        'palmAnalyses': palmAnalysesCount,
        'lastAnalysisDate': lastAnalysisDate,
        'memberSince': memberSince,
        'accuracyScore': accuracyScore,
        'averageHarmonyScore': averageHarmonyScore,
      };

      AppLogger.info('Statistics calculated successfully: Total analyses: $totalAnalyses');
      return Success(statistics);
    } catch (e) {
      AppLogger.error('Failed to get user statistics', e);
      return Error(UnknownFailure(
        message: 'Failed to get analysis statistics',
        code: 'STATISTICS_ERROR',
      ));
    }
  }

  /// Get detailed analysis history with pagination
  Future<ApiResult<List<Map<String, dynamic>>>> getAnalysisHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final userId = _authProvider.userId;
      if (userId == null) {
        return Error(AuthFailure(
          message: 'User not authenticated',
          code: 'NO_CURRENT_USER',
        ));
      }

      final history = <Map<String, dynamic>>[];
      
      // Fetch facial analyses
      try {
        final facialAnalyses = await _facialRepository.getFacialAnalysesWithPagination(
          userId,
          page: page,
          limit: limit ~/ 2, // Split limit between face and palm
        );
        
        for (final analysis in facialAnalyses) {
          history.add({
            'type': 'facial',
            'id': analysis.id,
            'date': analysis.createdAt ?? DateTime.parse(analysis.processedAt),
            'result': analysis.resultText,
            'score': analysis.harmonyScore,
            'faceShape': analysis.faceShape,
            'image': analysis.annotatedImage,
          });
        }
      } catch (e) {
        AppLogger.warning('Failed to fetch facial analysis history: $e');
      }

      // Fetch palm analyses
      try {
        final palmHistoryResult = await _palmHistoryService.getPalmAnalysisHistory();
        
        if (palmHistoryResult is Success) {
          final palmAnalyses = palmHistoryResult.data;
          
          if (palmAnalyses != null) {
            // Apply pagination manually
            final startIndex = (page - 1) * (limit ~/ 2);
            final endIndex = startIndex + (limit ~/ 2);
            
            final paginatedPalm = palmAnalyses.length > startIndex
                ? palmAnalyses.sublist(
                    startIndex,
                    endIndex > palmAnalyses.length ? palmAnalyses.length : endIndex,
                  )
                : <dynamic>[];
            
            for (final analysis in paginatedPalm) {
              history.add({
                'type': 'palm',
                'id': analysis.id,
                'date': analysis.createdAt,
                'result': analysis.summaryText,
                'palmLines': analysis.palmLinesDetected,
                'image': analysis.annotatedImage,
              });
            }
          }
        }
      } catch (e) {
        AppLogger.warning('Failed to fetch palm analysis history: $e');
      }

      // Sort by date (newest first)
      history.sort((a, b) {
        final aDate = a['date'] as DateTime;
        final bDate = b['date'] as DateTime;
        return bDate.compareTo(aDate);
      });

      AppLogger.info('Analysis history retrieved: ${history.length} items');
      return Success(history);
    } catch (e) {
      AppLogger.error('Failed to get analysis history', e);
      return Error(UnknownFailure(
        message: 'Failed to get analysis history',
        code: 'HISTORY_ERROR',
      ));
    }
  }
}