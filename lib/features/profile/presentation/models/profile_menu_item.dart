import 'package:flutter/material.dart';

/// Profile menu item model
class ProfileMenuItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool showArrow;
  final Widget? trailing;

  const ProfileMenuItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.iconColor,
    this.textColor,
    this.showArrow = true,
    this.trailing,
  });

  /// Create a copy with updated values
  ProfileMenuItem copyWith({
    String? title,
    String? subtitle,
    IconData? icon,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
    bool? showArrow,
    Widget? trailing,
  }) {
    return ProfileMenuItem(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      onTap: onTap ?? this.onTap,
      iconColor: iconColor ?? this.iconColor,
      textColor: textColor ?? this.textColor,
      showArrow: showArrow ?? this.showArrow,
      trailing: trailing ?? this.trailing,
    );
  }
}
