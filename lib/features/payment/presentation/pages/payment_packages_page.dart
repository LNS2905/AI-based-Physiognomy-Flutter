import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';
import '../../data/models/credit_package_model.dart';
import '../providers/payment_provider.dart';

class PaymentPackagesPage extends StatefulWidget {
  const PaymentPackagesPage({super.key});

  @override
  State<PaymentPackagesPage> createState() => _PaymentPackagesPageState();
}

class _PaymentPackagesPageState extends State<PaymentPackagesPage> {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PaymentProvider>().refreshCredits();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const StandardBackButton(),
        title: const Text('Nạp Tín Dụng', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer2<PaymentProvider, EnhancedAuthProvider>(
        builder: (context, paymentProvider, authProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current credits card
                _buildCurrentCreditsCard(
                  context,
                  authProvider.currentUser?.credits ?? paymentProvider.currentCredits,
                ),
                const SizedBox(height: 24),

                // Info section
                _buildInfoSection(context),
                const SizedBox(height: 24),

                // Custom Amount Input
                Text(
                  'Nhập số tiền cần nạp',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Số tiền tối thiểu: \$5.00',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),

                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      labelText: 'Số tiền (USD)',
                      hintText: 'Nhập số tiền (vd: 10)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số tiền';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return 'Số tiền không hợp lệ';
                      }
                      if (amount < 5.0) {
                        return 'Số tiền tối thiểu là \$5.00';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Top Up Button
                ElevatedButton(
                  onPressed: paymentProvider.isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            final amount = double.parse(_amountController.text);
                            _handleCustomPurchase(context, amount);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppColors.primary,
                    elevation: 2,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: paymentProvider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Nạp Ngay',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentCreditsCard(BuildContext context, int credits) {
    return Card(
      elevation: 6,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tín dụng hiện tại',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              credits.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tín dụng',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Thông tin quy đổi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              context,
              'Tỷ giá: \$1 USD = 10 Tín dụng',
              Icons.currency_exchange,
              isHighlighted: true,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              'Nạp tối thiểu: \$5.00',
              Icons.vertical_align_bottom,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String text,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isHighlighted ? AppColors.success : AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isHighlighted ? AppColors.success : AppColors.textSecondary,
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleCustomPurchase(
    BuildContext context,
    double amount,
  ) async {
    try {
      final paymentProvider = context.read<PaymentProvider>();
      
      // Create a temporary package for the custom amount
      final package = CreditPackageModel(
        id: -1, // Temporary ID
        name: 'Nạp tín dụng tùy chỉnh',
        credits: (amount * 10).toInt(),
        bonusCredits: 0,
        priceUsd: amount,
        priceVnd: amount * 25000, // Approx exchange rate
        isActive: true,
        displayOrder: 0,
      );

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Đang khởi tạo thanh toán...'),
                ],
              ),
            ),
          ),
        ),
      );

      // 1. Get user email
      final authProvider = context.read<EnhancedAuthProvider>();
      final email = authProvider.currentUser?.email;
      
      if (email == null) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading
          ErrorHandler.handleError(context, 'Không tìm thấy email người dùng. Vui lòng đăng nhập lại.');
        }
        return;
      }

      // 2. Initialize Payment Sheet
      final initSuccess = await paymentProvider.initPaymentSheet(package, email);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (!initSuccess) {
        if (context.mounted) {
          ErrorHandler.handleError(
            context,
            paymentProvider.errorMessage ?? 'Khởi tạo thanh toán thất bại.',
          );
        }
        return;
      }

      // 3. Present Payment Sheet
      if (context.mounted) {
        // We need userId for confirmation
        final userId = context.read<EnhancedAuthProvider>().currentUser?.id;
        if (userId == null) {
           if (context.mounted) {
            ErrorHandler.handleError(context, 'Không tìm thấy ID người dùng. Vui lòng đăng nhập lại.');
           }
           return;
        }

        final presentSuccess = await paymentProvider.presentPaymentSheet(userId);
        
        if (presentSuccess) {
          // Payment successful
          
          // Wait for the payment sheet to fully close and Flutter to resume rendering
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (context.mounted) {
            ErrorHandler.showSuccess(context, 'Thanh toán thành công! Tín dụng đã được cập nhật.');
            
            // Optimistic update using the value from PaymentProvider
            context.read<EnhancedAuthProvider>().updateUserCredits(paymentProvider.currentCredits);
            
            // Then refresh data from server to be consistent
            context.read<EnhancedAuthProvider>().refreshUserData();
            
            // Clear input
            _amountController.clear();
          }
        } else {
          // Payment failed or cancelled
          if (context.mounted && paymentProvider.errorMessage != null) {
             if (paymentProvider.errorMessage != 'Payment canceled') {
                ErrorHandler.handleError(context, paymentProvider.errorMessage!);
             }
          }
        }
      }
    } catch (e) {
      AppLogger.error('Payment error: $e');
      if (context.mounted) {
        ErrorHandler.handleError(context, e);
      }
    }
  }
}
