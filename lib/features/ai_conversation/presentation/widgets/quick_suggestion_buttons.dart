import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Quick suggestion buttons widget for AI conversation
class QuickSuggestionButtons extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;

  const QuickSuggestionButtons({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 8),
      child: Row(
        children: [
          if (suggestions.isNotEmpty) ...[
            Expanded(
              child: _buildSuggestionButton(suggestions[0]),
            ),
            if (suggestions.length > 1) ...[
              const SizedBox(width: 10),
              Expanded(
                child: _buildSuggestionButton(suggestions[1]),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionButton(String text) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withValues(alpha: 0.15),
            AppColors.primaryLight.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: () => onSuggestionTap(text),
          splashColor: AppColors.primary.withValues(alpha: 0.2),
          highlightColor: AppColors.primary.withValues(alpha: 0.1),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
