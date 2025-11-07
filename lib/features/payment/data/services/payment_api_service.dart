import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../models/credit_package_model.dart';

class PaymentApiService {
  static const String _baseUrl = ApiConfig.baseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Get authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Handle API response
  Map<String, dynamic> _handleResponse(
      http.Response response, String operation) {
    AppLogger.info(
        'PaymentApiService: $operation response status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseData = jsonDecode(response.body);
      if (responseData['code'] == 'OPERATION_SUCCESS') {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? '$operation failed');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '$operation failed');
    }
  }

  /// Get all credit packages
  Future<List<CreditPackageModel>> getCreditPackages() async {
    try {
      AppLogger.info('PaymentApiService: Getting credit packages');

      final response = await http.get(
        Uri.parse('$_baseUrl/credit-packages'),
        headers: await _getAuthHeaders(),
      ).timeout(ApiConfig.requestTimeout);

      final responseData = _handleResponse(response, 'Get credit packages');
      final List<dynamic> packagesJson = responseData['data'];

      return packagesJson
          .map((json) => CreditPackageModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('PaymentApiService: Get credit packages error: $e');
      rethrow;
    }
  }

  /// Create recharge session (for current user)
  Future<PaymentSessionResponse> createRechargeSession(
      PaymentSessionRequest request) async {
    try {
      AppLogger.info('PaymentApiService: Creating recharge session');

      final response = await http.post(
        Uri.parse('$_baseUrl/users/me/recharge'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConfig.requestTimeout);

      final responseData = _handleResponse(response, 'Create recharge session');
      return PaymentSessionResponse.fromJson(responseData['data']);
    } catch (e) {
      AppLogger.error('PaymentApiService: Create recharge session error: $e');
      rethrow;
    }
  }

  /// Get current user credits
  Future<int> getCurrentUserCredits() async {
    try {
      AppLogger.info('PaymentApiService: Getting current user credits');

      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: await _getAuthHeaders(),
      ).timeout(ApiConfig.requestTimeout);

      final responseData = _handleResponse(response, 'Get current user');
      final userData = responseData['data'];
      
      return userData['credits'] ?? 0;
    } catch (e) {
      AppLogger.error('PaymentApiService: Get current user credits error: $e');
      rethrow;
    }
  }

  /// Create payment session with credit package
  Future<PaymentSessionResponse> createPaymentSession(
      CreditPackageModel package) async {
    try {
      // Convert price from USD to cents for Stripe
      final unitAmount = (package.priceUsd * 100).toInt();

      final request = PaymentSessionRequest(
        lineItems: [
          StripeLineItem(
            priceData: StripePriceData(
              currency: 'usd',
              productData: StripeProductData(
                name: '${package.name} - ${package.totalCredits} Credits',
              ),
              unitAmount: unitAmount,
            ),
            quantity: 1,
          ),
        ],
        mode: 'payment',
      );

      return await createRechargeSession(request);
    } catch (e) {
      AppLogger.error('PaymentApiService: Create payment session error: $e');
      rethrow;
    }
  }
}
