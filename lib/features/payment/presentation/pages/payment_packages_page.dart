import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';
import '../../data/models/credit_package_model.dart';
import '../providers/payment_provider.dart';
import '../widgets/credit_package_card.dart';

class PaymentPackagesPage extends StatefulWidget {
  const PaymentPackagesPage({super.key});

  @override
  State<PaymentPackagesPage> createState() => _PaymentPackagesPageState();
}

class _PaymentPackagesPageState extends State<PaymentPackagesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PaymentProvider>().loadCreditPackages();
      context.read<PaymentProvider>().refreshCredits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const StandardBackButton(),
        title: const Text('Buy Credits'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer2<PaymentProvider, EnhancedAuthProvider>(
        builder: (context, paymentProvider, authProvider, _) {
          if (paymentProvider.isLoading && paymentProvider.packages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paymentProvider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load packages',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paymentProvider.errorMessage ?? 'Unknown error',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      paymentProvider.loadCreditPackages();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await paymentProvider.loadCreditPackages();
              await paymentProvider.refreshCredits();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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

                  // Package grid
                  Text(
                    'Choose Your Package',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...paymentProvider.packages.map((package) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CreditPackageCard(
                        package: package,
                        isLoading: paymentProvider.isLoading,
                        onTap: () => _handlePurchase(context, package),
                      ),
                    );
                  }),
                ],
              ),
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
              'Your Current Credits',
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
              'credits',
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
                  'How Credits Work',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              'AI Chatbot: 1 credit per message',
              Icons.chat,
            ),
            const SizedBox(height: 8),
            _buildInfoItem(
              context,
              'Face Analysis: FREE',
              Icons.face,
              isHighlighted: true,
            ),
            const SizedBox(height: 8),
            _buildInfoItem(
              context,
              'Palm Reading: FREE',
              Icons.back_hand,
              isHighlighted: true,
            ),
            const SizedBox(height: 8),
            _buildInfoItem(
              context,
              'Tử Vi Chart: FREE',
              Icons.auto_awesome,
              isHighlighted: true,
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

  Future<void> _handlePurchase(
    BuildContext context,
    CreditPackageModel package,
  ) async {
    try {
      final paymentProvider = context.read<PaymentProvider>();
      
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
                  Text('Creating payment session...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Create payment session
      final session = await paymentProvider.createPaymentSession(package);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (session == null) {
        if (context.mounted) {
          _showErrorDialog(
            context,
            'Failed to create payment session. Please try again.',
          );
        }
        return;
      }

      // Open Stripe Checkout URL
      final uri = Uri.parse(session.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (context.mounted) {
          _showPaymentInstructionsDialog(context);
        }
      } else {
        if (context.mounted) {
          _showErrorDialog(
            context,
            'Could not open payment page. Please try again.',
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

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
        title: const Text('Payment Error'),
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

  void _showPaymentInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Your Payment'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment page has been opened in your browser.'),
            SizedBox(height: 12),
            Text('After completing payment:'),
            SizedBox(height: 8),
            Text('1. Return to the app'),
            Text('2. Your credits will be updated automatically'),
            Text('3. Pull down to refresh if needed'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PaymentProvider>().refreshCredits();
            },
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
