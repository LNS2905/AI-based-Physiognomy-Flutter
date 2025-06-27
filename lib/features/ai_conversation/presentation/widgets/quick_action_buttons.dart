import 'package:flutter/material.dart';

/// Quick action buttons widget for AI conversation
class QuickActionButtons extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionButtons({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 8),
      child: Row(
        children: [
          if (actions.isNotEmpty) ...[
            Expanded(
              child: _buildActionButton(actions[0]),
            ),
            if (actions.length > 1) ...[
              const SizedBox(width: 20),
              Expanded(
                child: _buildActionButton(actions[1]),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(QuickAction action) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFDDDDDD),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: action.onTap,
          child: Center(
            child: Text(
              action.title,
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

/// Quick action data model
class QuickAction {
  final String title;
  final VoidCallback onTap;

  const QuickAction({
    required this.title,
    required this.onTap,
  });
}
