import 'package:flutter/material.dart';

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
    return Container(
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDDDDDD),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onSuggestionTap(text),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
