import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget to display current credits count
class CreditDisplayWidget extends StatelessWidget {
  final int credits;
  final VoidCallback? onTap;
  final bool showAddButton;

  const CreditDisplayWidget({
    super.key,
    required this.credits,
    this.onTap,
    this.showAddButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stars,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              credits.toString(),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (showAddButton) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.add_circle_outline,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small credit badge for minimal display
class CreditBadge extends StatelessWidget {
  final int credits;
  final bool isLow;

  const CreditBadge({
    super.key,
    required this.credits,
    this.isLow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLow ? Colors.red.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            size: 14,
            color: isLow ? Colors.red : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            credits.toString(),
            style: TextStyle(
              color: isLow ? Colors.red : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
