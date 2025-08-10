// Facial Analysis API Service
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_physiognomy_app/core/config/api_config.dart';
import 'package:ai_physiognomy_app/core/utils/logger.dart';
import 'package:ai_physiognomy_app/core/storage/secure_storage_service.dart';
import 'package:ai_physiognomy_app/features/facial_analysis/data/models/facial_analysis_models.dart';

class FacialAnalysisApiService {
  static const String _baseUrl = ApiConfig.baseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Save facial analysis result
  Future<FacialAnalysis> saveFacialAnalysis(FacialAnalysisDto analysisDto) async {
    AppLogger.info('FacialAnalysisApiService: Saving facial analysis');
    
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/facial-analysis'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(analysisDto.toJson()),
      );

      AppLogger.info('FacialAnalysisApiService: Save analysis response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          final analysis = FacialAnalysis.fromJson(responseData['data']);
          AppLogger.info('FacialAnalysisApiService: Facial analysis saved successfully');
          return analysis;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to save facial analysis');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to save facial analysis');
      }
    } catch (e) {
      AppLogger.error('FacialAnalysisApiService: Save analysis error: $e');
      rethrow;
    }
  }

  /// Get facial analyses by user ID
  Future<List<FacialAnalysis>> getFacialAnalysesByUser(int userId) async {
    AppLogger.info('FacialAnalysisApiService: Getting facial analyses for user $userId');
    
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/facial-analysis/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.info('FacialAnalysisApiService: Get analyses response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          final List<dynamic> analysesJson = responseData['data'];
          final analyses = analysesJson
              .map((json) => FacialAnalysis.fromJson(json))
              .toList();
          AppLogger.info('FacialAnalysisApiService: Retrieved ${analyses.length} facial analyses');
          return analyses;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to get facial analyses');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get facial analyses');
      }
    } catch (e) {
      AppLogger.error('FacialAnalysisApiService: Get analyses error: $e');
      rethrow;
    }
  }

  /// Update facial analysis
  Future<FacialAnalysis> updateFacialAnalysis(int id, FacialAnalysisDto analysisDto) async {
    AppLogger.info('FacialAnalysisApiService: Updating facial analysis $id');
    
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/facial-analysis/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(analysisDto.toJson()),
      );

      AppLogger.info('FacialAnalysisApiService: Update analysis response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          final analysis = FacialAnalysis.fromJson(responseData['data']);
          AppLogger.info('FacialAnalysisApiService: Facial analysis updated successfully');
          return analysis;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update facial analysis');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update facial analysis');
      }
    } catch (e) {
      AppLogger.error('FacialAnalysisApiService: Update analysis error: $e');
      rethrow;
    }
  }

  /// Delete facial analysis
  Future<void> deleteFacialAnalysis(int id) async {
    AppLogger.info('FacialAnalysisApiService: Deleting facial analysis $id');
    
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/facial-analysis/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.info('FacialAnalysisApiService: Delete analysis response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          AppLogger.info('FacialAnalysisApiService: Facial analysis deleted successfully');
        } else {
          throw Exception(responseData['message'] ?? 'Failed to delete facial analysis');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete facial analysis');
      }
    } catch (e) {
      AppLogger.error('FacialAnalysisApiService: Delete analysis error: $e');
      rethrow;
    }
  }

  /// Get facial analysis summaries for list view
  Future<List<FacialAnalysisSummary>> getFacialAnalysisSummaries(int userId) async {
    AppLogger.info('FacialAnalysisApiService: Getting facial analysis summaries for user $userId');
    
    try {
      final analyses = await getFacialAnalysesByUser(userId);
      final summaries = analyses.map((analysis) => FacialAnalysisSummary(
        id: analysis.id,
        faceShape: analysis.faceShape,
        harmonyScore: analysis.harmonyScore,
        processedAt: analysis.processedAt,
        createdAt: analysis.createdAt,
      )).toList();
      
      AppLogger.info('FacialAnalysisApiService: Retrieved ${summaries.length} facial analysis summaries');
      return summaries;
    } catch (e) {
      AppLogger.error('FacialAnalysisApiService: Get summaries error: $e');
      rethrow;
    }
  }

  /// Get single facial analysis by ID
  Future<FacialAnalysis> getFacialAnalysisById(int id) async {
    AppLogger.info('FacialAnalysisApiService: Getting facial analysis $id');
    
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      // Note: This endpoint might not exist in the API, so we'll get all and filter
      // In a real implementation, you might want to add a GET /facial-analysis/{id} endpoint
      final user = await _getCurrentUser();
      final analyses = await getFacialAnalysesByUser(user.id);
      
      final analysis = analyses.firstWhere(
        (a) => a.id == id,
        orElse: () => throw Exception('Facial analysis not found'),
      );
      
      AppLogger.info('FacialAnalysisApiService: Retrieved facial analysis $id');
      return analysis;
    } catch (e) {
      AppLogger.error('FacialAnalysisApiService: Get analysis by ID error: $e');
      rethrow;
    }
  }

  /// Helper method to get current user (you might want to move this to a shared service)
  Future<dynamic> _getCurrentUser() async {
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'Failed to get user info');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get user info');
      }
    } catch (e) {
      AppLogger.error('FacialAnalysisApiService: Get current user error: $e');
      rethrow;
    }
  }

  /// Process facial analysis from image
  /// This method would typically call an AI service to analyze the image
  /// For now, it's a placeholder that you can implement based on your AI service
  Future<FacialAnalysisDto> processFacialAnalysis(String imageBase64) async {
    AppLogger.info('FacialAnalysisApiService: Processing facial analysis from image');
    
    try {
      // TODO: Implement actual AI processing
      // This is a placeholder implementation
      
      final user = await _getCurrentUser();
      final now = DateTime.now().toIso8601String();
      
      // Mock analysis result - replace with actual AI service call
      final analysisDto = FacialAnalysisDto(
        userId: user['id'].toString(),
        resultText: 'Mock facial analysis result',
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
      
      AppLogger.info('FacialAnalysisApiService: Facial analysis processed successfully');
      return analysisDto;
    } catch (e) {
      AppLogger.error('FacialAnalysisApiService: Process analysis error: $e');
      rethrow;
    }
  }
}
