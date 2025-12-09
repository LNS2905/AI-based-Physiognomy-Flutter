// Referral API Service
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_physiognomy_app/core/config/api_config.dart';
import 'package:ai_physiognomy_app/core/utils/logger.dart';
import 'package:ai_physiognomy_app/core/storage/secure_storage_service.dart';

/// Referral code response
class ReferralCodeResponse {
  final String code;
  final String link;

  ReferralCodeResponse({
    required this.code,
    required this.link,
  });

  factory ReferralCodeResponse.fromJson(Map<String, dynamic> json) {
    return ReferralCodeResponse(
      code: json['code'] as String,
      link: json['link'] as String,
    );
  }
}

/// Referral stats response
class ReferralStatsResponse {
  final int totalReferrals;
  final int totalCreditsEarned;

  ReferralStatsResponse({
    required this.totalReferrals,
    required this.totalCreditsEarned,
  });

  factory ReferralStatsResponse.fromJson(Map<String, dynamic> json) {
    return ReferralStatsResponse(
      totalReferrals: json['totalReferrals'] as int? ?? 0,
      totalCreditsEarned: json['totalCreditsEarned'] as int? ?? 0,
    );
  }
}

/// Apply referral response
class ApplyReferralResponse {
  final bool success;
  final String message;
  final int? creditsAwarded;

  ApplyReferralResponse({
    required this.success,
    required this.message,
    this.creditsAwarded,
  });

  factory ApplyReferralResponse.fromJson(Map<String, dynamic> json) {
    return ApplyReferralResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      creditsAwarded: json['creditsAwarded'] as int?,
    );
  }
}

class ReferralApiService {
  static const String _baseUrl = ApiConfig.baseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Get authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null) {
      throw Exception('No access token found');
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get or create user's referral code
  Future<ReferralCodeResponse> getReferralCode() async {
    AppLogger.info('ReferralApiService: Getting referral code');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/referral/code'),
        headers: headers,
      );

      AppLogger.info('ReferralApiService: Get referral code response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          return ReferralCodeResponse.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to get referral code');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get referral code');
      }
    } catch (e) {
      AppLogger.error('ReferralApiService: Get referral code error: $e');
      rethrow;
    }
  }

  /// Apply a referral code (for new users)
  Future<ApplyReferralResponse> applyReferralCode(String referralCode) async {
    AppLogger.info('ReferralApiService: Applying referral code: $referralCode');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/referral/apply'),
        headers: headers,
        body: jsonEncode({'referralCode': referralCode}),
      );

      AppLogger.info('ReferralApiService: Apply referral code response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          return ApplyReferralResponse.fromJson(responseData['data']);
        } else {
          return ApplyReferralResponse(
            success: false,
            message: responseData['message'] ?? 'Failed to apply referral code',
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        return ApplyReferralResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to apply referral code',
        );
      }
    } catch (e) {
      AppLogger.error('ReferralApiService: Apply referral code error: $e');
      return ApplyReferralResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get referral statistics
  Future<ReferralStatsResponse> getReferralStats() async {
    AppLogger.info('ReferralApiService: Getting referral stats');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/referral/stats'),
        headers: headers,
      );

      AppLogger.info('ReferralApiService: Get referral stats response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OPERATION_SUCCESS') {
          return ReferralStatsResponse.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to get referral stats');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get referral stats');
      }
    } catch (e) {
      AppLogger.error('ReferralApiService: Get referral stats error: $e');
      rethrow;
    }
  }
}
