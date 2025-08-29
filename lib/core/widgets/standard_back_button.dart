import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// Standardized back button component used across the entire app
/// Based on the face scan screen design
class StandardBackButton extends StatelessWidget {
  /// Custom callback for the back action. If null, uses context.pop()
  final VoidCallback? onPressed;
  
  /// Custom size for the back button. Defaults to 40.0
  final double? size;
  
  /// Custom icon for the back button. Defaults to Icons.arrow_back_ios_new
  final IconData? icon;
  
  /// Custom icon size. Defaults to 18.0
  final double? iconSize;
  
  /// Whether this is a white variant (for use on colored backgrounds)
  final bool isWhiteVariant;

  const StandardBackButton({
    super.key,
    this.onPressed,
    this.size,
    this.icon,
    this.iconSize,
    this.isWhiteVariant = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? 40.0;
    final buttonIcon = icon ?? Icons.arrow_back_ios_new;
    final buttonIconSize = iconSize ?? 18.0;

    return GestureDetector(
      onTap: onPressed ?? () => context.pop(),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          gradient: isWhiteVariant 
              ? null
              : LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1), 
                    AppColors.primary.withValues(alpha: 0.2),
                  ],
                ),
          color: isWhiteVariant 
              ? Colors.white.withValues(alpha: 0.2)
              : null,
          border: isWhiteVariant 
              ? null
              : Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            buttonIcon,
            size: buttonIconSize,
            color: isWhiteVariant ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}