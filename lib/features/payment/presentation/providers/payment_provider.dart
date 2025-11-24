import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/enums/loading_state.dart';
import '../../data/models/credit_package_model.dart';
import '../../data/services/payment_api_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

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

      // Use real API data
      _packages = await _paymentApiService.getCreditPackages();
      
      /* Mock data for reference:
      _packages = _getMockPackages();
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
        name: 'Top Up \$1',
        credits: 10,
        bonusCredits: 0,
        priceUsd: 1.0,
        priceVnd: 25000.0,
        isActive: true,
        displayOrder: 1,
      ),
      const CreditPackageModel(
        id: 2,
        name: 'Top Up \$5',
        credits: 50,
        bonusCredits: 0,
        priceUsd: 5.0,
        priceVnd: 125000.0,
        isActive: true,
        displayOrder: 2,
      ),
      const CreditPackageModel(
        id: 3,
        name: 'Top Up \$10',
        credits: 100,
        bonusCredits: 0,
        priceUsd: 10.0,
        priceVnd: 250000.0,
        isActive: true,
        displayOrder: 3,
      ),
      const CreditPackageModel(
        id: 4,
        name: 'Top Up \$20',
        credits: 200,
        bonusCredits: 0,
        priceUsd: 20.0,
        priceVnd: 500000.0,
        isActive: true,
        displayOrder: 4,
      ),
      const CreditPackageModel(
        id: 5,
        name: 'Top Up \$50',
        credits: 500,
        bonusCredits: 0,
        priceUsd: 50.0,
        priceVnd: 1250000.0,
        isActive: true,
        displayOrder: 5,
      ),
      const CreditPackageModel(
        id: 6,
        name: 'Top Up \$100',
        credits: 1000,
        bonusCredits: 0,
        priceUsd: 100.0,
        priceVnd: 2500000.0,
        isActive: true,
        displayOrder: 6,
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

  /// Initialize and present Payment Sheet
  Future<bool> initPaymentSheet(CreditPackageModel package, String email) async {
    try {
      _loadingState = LoadingState.loading;
      _errorMessage = null;
      notifyListeners();

      // 1. Get keys from backend
      final data = await _paymentApiService.createPaymentSheetSession(package.priceUsd, email);
      
      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'AI Physiognomy',
          paymentIntentClientSecret: data['paymentIntent'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['customer'],
          style: ThemeMode.system,
        ),
      );

      // Store paymentIntentId for confirmation
      _currentSession = PaymentSessionResponse(
        id: data['paymentIntentId'], // We need to update the model or just store it locally
        clientSecret: data['paymentIntent'],
        amount: (package.priceUsd * 100).toInt(),
        currency: 'usd',
      );

      _loadingState = LoadingState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _loadingState = LoadingState.error;
      _errorMessage = e.toString();
      AppLogger.error('PaymentProvider: Init payment sheet error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Present Payment Sheet
  Future<bool> presentPaymentSheet(int userId) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      
      // Confirm payment with backend
      if (_currentSession != null) {
        final newCredits = await _paymentApiService.confirmPaymentSheet(_currentSession!.id, userId);
        _currentCredits = newCredits;
        AppLogger.info('PaymentProvider: Payment confirmed. New credits: $_currentCredits');
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      if (e is StripeException) {
        if (e.error.code == FailureCode.Canceled) {
           AppLogger.info('PaymentProvider: Payment canceled by user');
           // User canceled, don't show error
           _errorMessage = 'Payment canceled'; // Or leave null if we want silent fail
        } else {
           AppLogger.error('PaymentProvider: Stripe error: ${e.error.localizedMessage}');
           _errorMessage = e.error.localizedMessage;
        }
      } else {
        AppLogger.error('PaymentProvider: Present payment sheet error: $e');
        _errorMessage = e.toString();
      }
      // Only set error state if it's not a cancellation (or if we want to show "Cancelled" as error)
      // Usually cancellation is not an "error" state for the UI, just a return to previous state.
      // But we return false to indicate failure/cancellation.
      _loadingState = LoadingState.error;
      notifyListeners();
      return false;
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
