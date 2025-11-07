import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/enums/loading_state.dart';
import '../../data/models/credit_package_model.dart';
import '../../data/services/payment_api_service.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentApiService _paymentApiService = PaymentApiService();

  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;
  List<CreditPackageModel> _packages = [];
  int _currentCredits = 0;
  PaymentSessionResponse? _currentSession;

  // Getters
  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  List<CreditPackageModel> get packages => _packages;
  int get currentCredits => _currentCredits;
  PaymentSessionResponse? get currentSession => _currentSession;
  bool get isLoading => _loadingState == LoadingState.loading;
  bool get hasError => _loadingState == LoadingState.error;

  /// Load credit packages
  Future<void> loadCreditPackages() async {
    try {
      _loadingState = LoadingState.loading;
      _errorMessage = null;
      notifyListeners();

      // For now, use mock data since endpoint might not be available yet
      _packages = _getMockPackages();
      
      /* Uncomment when backend endpoint is ready:
      _packages = await _paymentApiService.getCreditPackages();
      */

      _loadingState = LoadingState.loaded;
      AppLogger.info('PaymentProvider: Loaded ${_packages.length} packages');
    } catch (e) {
      _loadingState = LoadingState.error;
      _errorMessage = e.toString();
      AppLogger.error('PaymentProvider: Load packages error: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Get mock credit packages (matching backend data)
  List<CreditPackageModel> _getMockPackages() {
    return [
      const CreditPackageModel(
        id: 1,
        name: 'Starter',
        credits: 50,
        bonusCredits: 0,
        priceUsd: 2.0,
        priceVnd: 50000.0,
        isActive: true,
        displayOrder: 1,
      ),
      const CreditPackageModel(
        id: 2,
        name: 'Basic',
        credits: 125,
        bonusCredits: 25,
        priceUsd: 5.0,
        priceVnd: 125000.0,
        isActive: true,
        displayOrder: 2,
      ),
      const CreditPackageModel(
        id: 3,
        name: 'Popular',
        credits: 275,
        bonusCredits: 75,
        priceUsd: 10.0,
        priceVnd: 250000.0,
        isActive: true,
        displayOrder: 3,
      ),
      const CreditPackageModel(
        id: 4,
        name: 'Premium',
        credits: 625,
        bonusCredits: 125,
        priceUsd: 20.0,
        priceVnd: 500000.0,
        isActive: true,
        displayOrder: 4,
      ),
    ];
  }

  /// Refresh current user credits
  Future<void> refreshCredits() async {
    try {
      _currentCredits = await _paymentApiService.getCurrentUserCredits();
      AppLogger.info('PaymentProvider: Current credits: $_currentCredits');
      notifyListeners();
    } catch (e) {
      AppLogger.error('PaymentProvider: Refresh credits error: $e');
      // Don't change loading state, just log error
    }
  }

  /// Create payment session for a package
  Future<PaymentSessionResponse?> createPaymentSession(
      CreditPackageModel package) async {
    try {
      _loadingState = LoadingState.loading;
      _errorMessage = null;
      notifyListeners();

      _currentSession = await _paymentApiService.createPaymentSession(package);
      
      _loadingState = LoadingState.loaded;
      AppLogger.info('PaymentProvider: Payment session created: ${_currentSession?.url}');
      notifyListeners();
      
      return _currentSession;
    } catch (e) {
      _loadingState = LoadingState.error;
      _errorMessage = e.toString();
      AppLogger.error('PaymentProvider: Create payment session error: $e');
      notifyListeners();
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    _loadingState = LoadingState.idle;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _loadingState = LoadingState.idle;
    _errorMessage = null;
    _packages = [];
    _currentCredits = 0;
    _currentSession = null;
    notifyListeners();
  }
}
