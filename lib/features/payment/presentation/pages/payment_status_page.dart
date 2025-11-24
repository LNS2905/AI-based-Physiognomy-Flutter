import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/payment_provider.dart';

class PaymentStatusPage extends StatefulWidget {
  final bool isSuccess;
  final int? credits;

  const PaymentStatusPage({
    super.key,
    required this.isSuccess,
    this.credits,
  });

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  @override
  void initState() {
    super.initState();
    if (widget.isSuccess) {
      // Refresh credits when payment is successful
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PaymentProvider>().refreshCredits();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                size: 80,
                color: widget.isSuccess ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                widget.isSuccess ? 'Thanh toán thành công!' : 'Thanh toán thất bại',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.isSuccess
                    ? 'Bạn đã nhận được ${widget.credits ?? 0} tín dụng vào tài khoản.'
                    : 'Đã có lỗi xảy ra trong quá trình thanh toán. Vui lòng thử lại.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to home or payment page
                  context.go('/payment/packages');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor: widget.isSuccess ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
