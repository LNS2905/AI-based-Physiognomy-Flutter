import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/models/auth_models.dart';

/// Gender selector widget for palm analysis
/// Allows users to select gender (male/female) which determines which hand to analyze
/// Default value comes from user profile, but can be overridden
class GenderSelectorWidget extends StatelessWidget {
  final Gender selectedGender;
  final ValueChanged<Gender> onGenderChanged;
  final String? helpText;

  const GenderSelectorWidget({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
    this.helpText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.surfaceVariant.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Chọn giới tính',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Help text
          if (helpText != null)
            Text(
              helpText!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),

          const SizedBox(height: 12),

          // Gender options
          Row(
            children: [
              Expanded(
                child: _GenderOption(
                  gender: Gender.male,
                  label: 'Nam',
                  sublabel: 'Xem tay trái',
                  icon: Icons.male,
                  isSelected: selectedGender == Gender.male,
                  onTap: () => onGenderChanged(Gender.male),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GenderOption(
                  gender: Gender.female,
                  label: 'Nữ',
                  sublabel: 'Xem tay phải',
                  icon: Icons.female,
                  isSelected: selectedGender == Gender.female,
                  onTap: () => onGenderChanged(Gender.female),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final Gender gender;
  final String label;
  final String sublabel;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.gender,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.primaryDark.withOpacity(0.15),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.5),
                    AppColors.surfaceVariant.withOpacity(0.2),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? AppColors.primary.withOpacity(0.8)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
