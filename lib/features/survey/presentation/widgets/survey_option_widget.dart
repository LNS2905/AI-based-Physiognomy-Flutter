import 'package:flutter/material.dart';
import '../../data/models/survey_question_model.dart';

/// Survey option widget that matches the Figma design
class SurveyOptionWidget extends StatelessWidget {
  final SurveyOptionModel option;
  final bool isSelected;
  final VoidCallback onTap;

  const SurveyOptionWidget({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F5F5) : const Color(0xFFFAFAFA),
          border: Border.all(
            color: isSelected ? const Color(0xFF333333) : const Color(0xFFDDDDDD),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            
            // Radio button
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF333333) : const Color(0xFFCCCCCC),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF333333) : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // Option text
            Expanded(
              child: Text(
                option.text,
                style: const TextStyle(
                  fontSize: 17,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
