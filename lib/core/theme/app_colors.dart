import 'package:flutter/material.dart';

/// Application color palette inspired by Cracker Book design
/// Modern, friendly, and warm color scheme with yellow as primary
class AppColors {
  // ============================================
  // PRIMARY COLORS - Golden Yellow (Main Theme)
  // ============================================
  static const Color primary = Color(0xFFF5D547); // Bright Golden Yellow
  static const Color primaryLight = Color(0xFFFFF3CD); // Light Golden
  static const Color primaryDark = Color(0xFFE5C235); // Dark Golden
  static const Color primarySoft = Color(0xFFFFF8E7); // Very soft yellow bg

  // ============================================
  // SECONDARY COLORS - Teal/Turquoise (Accent)
  // ============================================
  static const Color secondary = Color(0xFF4ECDC4); // Teal/Turquoise
  static const Color secondaryLight = Color(0xFF7DE8E1); // Light Teal
  static const Color secondaryDark = Color(0xFF35B5AC); // Dark Teal

  // ============================================
  // ACCENT COLORS - Coral/Peach (Soft Accent)
  // ============================================
  static const Color accent = Color(0xFFF5A589); // Coral/Peach
  static const Color accentLight = Color(0xFFFFCCBC); // Light Peach
  static const Color accentDark = Color(0xFFE88A6C); // Dark Coral
  static const Color accentPink = Color(0xFFFFB7B2); // Soft Pink

  // ============================================
  // BACKGROUND COLORS - Clean & Warm
  // ============================================
  static const Color background = Color(0xFFFAFAFA); // Pure background
  static const Color backgroundWarm = Color(0xFFFFF8E7); // Warm cream background
  static const Color surface = Color(0xFFFFFFFF); // White surface
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Light grey variant
  static const Color surfaceYellow = Color(0xFFFFF3CD); // Yellow tinted surface

  // ============================================
  // TEXT COLORS - Clear & Readable
  // ============================================
  static const Color textPrimary = Color(0xFF1A1A1A); // Almost black
  static const Color textSecondary = Color(0xFF6B6B6B); // Medium grey
  static const Color textTertiary = Color(0xFF9E9E9E); // Light grey
  static const Color textHint = Color(0xFFBDBDBD); // Hint grey
  static const Color textOnPrimary = Color(0xFF1A1A1A); // Dark on yellow
  static const Color textOnAccent = Color(0xFFFFFFFF); // White on accent

  // ============================================
  // STATUS COLORS - Modern & Friendly
  // ============================================
  static const Color success = Color(0xFF4CAF50); // Green success
  static const Color successLight = Color(0xFFE8F5E9); // Light green bg
  static const Color warning = Color(0xFFFF9800); // Orange warning
  static const Color warningLight = Color(0xFFFFF3E0); // Light orange bg
  static const Color error = Color(0xFFE53935); // Red error
  static const Color errorLight = Color(0xFFFFEBEE); // Light red bg
  static const Color info = Color(0xFF2196F3); // Blue info
  static const Color infoLight = Color(0xFFE3F2FD); // Light blue bg

  // ============================================
  // BORDER & DIVIDER COLORS
  // ============================================
  static const Color border = Color(0xFFE0E0E0); // Standard border
  static const Color borderLight = Color(0xFFF0F0F0); // Light border
  static const Color borderYellow = Color(0xFFFFE082); // Yellow accent border
  static const Color divider = Color(0xFFEEEEEE); // Divider line

  // ============================================
  // SHADOW COLORS
  // ============================================
  static const Color shadow = Color(0x14000000); // 8% black
  static const Color shadowLight = Color(0x0A000000); // 4% black
  static const Color shadowMedium = Color(0x1F000000); // 12% black
  static const Color shadowYellow = Color(0x29F5D547); // Yellow shadow

  // ============================================
  // CARD COLORS - For different card types
  // ============================================
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardYellow = Color(0xFFFFF8E7);
  static const Color cardTeal = Color(0xFFE0F7F5);
  static const Color cardPeach = Color(0xFFFFF0EC);
  static const Color cardBlue = Color(0xFFE8F4FD);
  static const Color cardGreen = Color(0xFFE8F5E9);

  // ============================================
  // ICON BACKGROUND COLORS (Circle backgrounds)
  // ============================================
  static const Color iconBgYellow = Color(0xFFFFF3CD);
  static const Color iconBgTeal = Color(0xFFE0F7F5);
  static const Color iconBgPeach = Color(0xFFFFF0EC);
  static const Color iconBgBlue = Color(0xFFE3F2FD);
  static const Color iconBgGreen = Color(0xFFE8F5E9);
  static const Color iconBgPurple = Color(0xFFF3E5F5);

  // ============================================
  // NAVIGATION & INTERACTION
  // ============================================
  static const Color navActive = Color(0xFFF5D547); // Active nav item
  static const Color navInactive = Color(0xFF9E9E9E); // Inactive nav item
  static const Color navBackground = Color(0xFFFFFFFF); // Nav bar background
  static const Color ripple = Color(0x1FF5D547); // Ripple effect

  // ============================================
  // CHAT COLORS
  // ============================================
  static const Color chatUserBubble = Color(0xFFF5D547); // User message bubble
  static const Color chatBotBubble = Color(0xFFF5F5F5); // Bot message bubble
  static const Color chatUserText = Color(0xFF1A1A1A); // User text
  static const Color chatBotText = Color(0xFF1A1A1A); // Bot text

  // ============================================
  // RESULT/ANALYSIS COLORS
  // ============================================
  static const Color resultPositive = Color(0xFF4CAF50); // Positive result
  static const Color resultNeutral = Color(0xFFF5D547); // Neutral result
  static const Color resultNegative = Color(0xFFE53935); // Negative result

  // ============================================
  // DARK THEME COLORS
  // ============================================
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // White for primary text
  static const Color darkTextSecondary = Color(0xFFB3B3B3); // Light grey for secondary
  static const Color darkTextTertiary = Color(0xFF8A8A8A); // Medium grey for tertiary
  static const Color darkTextHint = Color(0xFF6B6B6B); // Darker grey for hints
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkBorderLight = Color(0xFF2A2A2A);
  static const Color darkDivider = Color(0xFF3A3A3A);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkNavBackground = Color(0xFF1E1E1E);
  static const Color darkNavInactive = Color(0xFF8A8A8A);
  static const Color darkShadow = Color(0x40000000); // 25% black
  static const Color darkRipple = Color(0x1FFFFFFF); // White ripple

  // ============================================
  // GRADIENT DEFINITIONS
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF3CD), Color(0xFFF5D547)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF8E7), Color(0xFFFAFAFA)],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7DE8E1), Color(0xFF4ECDC4)],
  );

  static const LinearGradient coralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFCCBC), Color(0xFFF5A589)],
  );

  static const LinearGradient sunriseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF3CD), Color(0xFFF5A589)],
  );

  // Legacy gradient for backward compatibility
  static const LinearGradient baguaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A1A), Color(0xFFF5D547)], // Black to gold
  );

  // ============================================
  // ORGANIC SHAPE COLORS (for decorative elements)
  // ============================================
  static const Color organicYellow = Color(0xFFF5D547);
  static const Color organicTeal = Color(0xFF4ECDC4);
  static const Color organicPeach = Color(0xFFF5A589);
  static const Color organicPink = Color(0xFFFFB7B2);
  static const Color organicBlue = Color(0xFF90CAF9);

  // ============================================
  // FEATURE CARD COLORS (for home page grid)
  // ============================================
  static const List<Color> featureCardColors = [
    Color(0xFFFFF3CD), // Yellow
    Color(0xFFE0F7F5), // Teal
    Color(0xFFFFF0EC), // Peach
    Color(0xFFE3F2FD), // Blue
    Color(0xFFF3E5F5), // Purple
  ];

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Get lighter shade of color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Get darker shade of color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Get status color based on type
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'approved':
        return success;
      case 'warning':
      case 'pending':
      case 'in_progress':
        return warning;
      case 'error':
      case 'failed':
      case 'rejected':
        return error;
      case 'info':
      case 'draft':
        return info;
      default:
        return textSecondary;
    }
  }

  /// Get result color based on score
  static Color getResultColor(double score) {
    if (score >= 0.7) {
      return resultPositive;
    } else if (score >= 0.4) {
      return resultNeutral;
    } else {
      return resultNegative;
    }
  }

  /// Get feature card background color by index
  static Color getFeatureCardColor(int index) {
    return featureCardColors[index % featureCardColors.length];
  }

  /// Get icon background color by index
  static Color getIconBgColor(int index) {
    final colors = [
      iconBgYellow,
      iconBgTeal,
      iconBgPeach,
      iconBgBlue,
      iconBgGreen,
      iconBgPurple,
    ];
    return colors[index % colors.length];
  }

  // Legacy color aliases for backward compatibility
  static const Color textOnAccent2 = textOnAccent;
  static const Color scanningOverlay = Color(0x80000000);
  static const Color scanningFrame = primary;
  static const Color scanningProgress = secondary;
}
