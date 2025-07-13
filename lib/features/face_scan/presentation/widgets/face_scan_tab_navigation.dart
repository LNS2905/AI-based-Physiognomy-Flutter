import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Modern tab navigation widget for face scan screen with animations
class FaceScanTabNavigation extends StatefulWidget {
  final String selectedTab;
  final Function(String) onTabSelected;

  const FaceScanTabNavigation({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  State<FaceScanTabNavigation> createState() => _FaceScanTabNavigationState();
}

class _FaceScanTabNavigationState extends State<FaceScanTabNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 376,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildTab(
              'face_scan',
              'Quét mặt',
              Icons.face_retouching_natural,
              isSelected: widget.selectedTab == 'face_scan',
            ),
            _buildTab(
              'upload_photo',
              'Tải ảnh',
              Icons.cloud_upload_outlined,
              isSelected: widget.selectedTab == 'upload_photo',
            ),
            _buildTab(
              'user_guide',
              'Hướng dẫn',
              Icons.help_outline,
              isSelected: widget.selectedTab == 'user_guide',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    String tabId,
    String title,
    IconData icon, {
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onTabSelected(tabId);
          if (isSelected) {
            _animationController.forward().then((_) {
              _animationController.reverse();
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: isSelected ? 18 : 16,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                child: Text(title),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
