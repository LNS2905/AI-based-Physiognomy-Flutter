import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/credit_package_model.dart';

class CreditPackageCard extends StatelessWidget {
  final CreditPackageModel package;
  final VoidCallback onTap;
  final bool isLoading;

  const CreditPackageCard({
    super.key,
    required this.package,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPopular = package.isPopular;

    return Card(
      elevation: isPopular ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPopular
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Popular badge
            if (isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '⭐ Popular',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Package name
                  Text(
                    package.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPopular ? AppColors.primary : null,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${package.priceUsd.toStringAsFixed(0)}',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'USD',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // VND Price
                  Text(
                    '${package.priceVnd.toStringAsFixed(0)} VND',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Credits info
                  _buildCreditInfo(
                    context,
                    '${package.credits} Credits',
                    Icons.stars,
                  ),
                  if (package.hasBonus) ...[
                    const SizedBox(height: 8),
                    _buildCreditInfo(
                      context,
                      '+${package.bonusCredits} Bonus Credits',
                      Icons.card_giftcard,
                      isBonus: true,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  _buildCreditInfo(
                    context,
                    '${package.totalCredits} Total Credits',
                    Icons.account_balance_wallet,
                    isBold: true,
                  ),
                  const SizedBox(height: 20),

                  // Buy button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isPopular ? AppColors.primary : AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Top Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditInfo(
    BuildContext context,
    String text,
    IconData icon, {
    bool isBonus = false,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isBonus ? Colors.green : AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBonus ? Colors.green : null,
              ),
        ),
      ],
    );
  }
}
