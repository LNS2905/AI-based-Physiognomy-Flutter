import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/constants/topic_suggestions.dart';

/// Widget hiển thị gợi ý câu hỏi contextual dưới message AI
class ContextualSuggestions extends StatelessWidget {
  final String messageContent;
  final Function(String) onSuggestionTap;
  final bool isLastMessage;

  const ContextualSuggestions({
    super.key,
    required this.messageContent,
    required this.onSuggestionTap,
    this.isLastMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    // Chỉ hiển thị cho tin nhắn cuối cùng
    if (!isLastMessage) return const SizedBox.shrink();

    final suggestions = TopicSuggestions.getSuggestionsForMessage(messageContent);

    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'Có thể bạn muốn hỏi',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) {
              return InkWell(
                onTap: () => onSuggestionTap(suggestion),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
