import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger.dart';
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
      appBar: AppBar(
        leading: const StandardBackButton(),
        title: const Text('Nạp tín dụng'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer2<PaymentProvider, EnhancedAuthProvider>(
        builder: (context, paymentProvider, authProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Số tiền tối thiểu: \$5.00',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
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
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
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
                          'Nạp ngay',
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tín dụng hiện tại',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              credits.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'tín dụng',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Thông tin nạp tín dụng',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              'Tỷ giá: \$1 USD = 10 Tín dụng',
              Icons.currency_exchange,
              isHighlighted: true,
            ),
            const SizedBox(height: 8),
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
          color: isHighlighted ? Colors.green : AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isHighlighted ? Colors.green : AppColors.textSecondary,
                  fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
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
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
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
          _showErrorDialog(context, 'Không tìm thấy email người dùng. Vui lòng đăng nhập lại.');
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
          _showErrorDialog(
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
            _showErrorDialog(context, 'Không tìm thấy ID người dùng. Vui lòng đăng nhập lại.');
           }
           return;
        }

        final presentSuccess = await paymentProvider.presentPaymentSheet(userId);
        
        if (presentSuccess) {
          // Payment successful
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thanh toán thành công! Tín dụng đã được cập nhật.'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<EnhancedAuthProvider>().refreshUserData();
            // Clear input
            _amountController.clear();
          }
        } else {
          // Payment failed or cancelled
          if (context.mounted && paymentProvider.errorMessage != null) {
             if (paymentProvider.errorMessage != 'Payment canceled') {
                _showErrorDialog(context, paymentProvider.errorMessage!);
             }
          }
        }
      }
    } catch (e) {
      AppLogger.error('Payment error: $e');
      if (context.mounted) {
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi thanh toán'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
