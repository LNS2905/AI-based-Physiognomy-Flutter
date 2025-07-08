import 'package:flutter/material.dart';

/// Application color palette inspired by Bagua (Eight Trigrams) symbolism
/// Based on traditional Chinese Five Elements (Wuxing) philosophy
class AppColors {
  // Bagua-Inspired Primary Colors
  // Gold represents Earth element - prosperity, imperial power, stability
  static const Color primary = Color(0xFFD4AF37); // Traditional Chinese Gold
  static const Color primaryLight = Color(0xFFF4E4BC); // Light Gold
  static const Color primaryDark = Color(0xFFB8860B); // Dark Gold

  // Secondary Colors - Water & Wood Elements
  // Blue represents Wood element - growth, harmony, advancement
  static const Color secondary = Color(0xFF4682B4); // Steel Blue
  static const Color secondaryLight = Color(0xFF87CEEB); // Sky Blue
  static const Color secondaryDark = Color(0xFF2C5F7C); // Deep Blue

  // Bagua Accent Colors
  // Red represents Fire element - vitality, celebration, good fortune
  static const Color accent = Color(0xFFDC143C); // Chinese Red
  static const Color accentLight = Color(0xFFFF6B6B); // Soft Red
  static const Color accentDark = Color(0xFFB22222); // Fire Brick

  // Background Colors - Metal Element (White/Light)
  static const Color background = Color(0xFFFAFAFA); // Pure background
  static const Color surface = Color(0xFFFFFFFF); // Clean white
  static const Color surfaceVariant = Color(0xFFF8F8F8); // Subtle variant

  // Text Colors - Water Element influence
  static const Color textPrimary = Color(0xFF1C1C1C); // Sophisticated black
  static const Color textSecondary = Color(0xFF36454F); // Charcoal
  static const Color textHint = Color(0xFF87A96B); // Sage green for harmony
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on gold
  static const Color textOnAccent = Color(0xFFFFFFFF); // White on red

  // Status Colors - Balanced Five Elements approach
  static const Color success = Color(0xFF87A96B); // Sage green (Wood element)
  static const Color warning = Color(0xFFD4AF37); // Gold (Earth element)
  static const Color error = Color(0xFFDC143C); // Chinese red (Fire element)
  static const Color info = Color(0xFF4682B4); // Steel blue (Water element)

  // Border Colors - Subtle earth tones
  static const Color border = Color(0xFFE8D5B7); // Light gold border
  static const Color borderLight = Color(0xFFF4E4BC); // Very light gold
  static const Color borderDark = Color(0xFFB8860B); // Dark gold

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowDark = Color(0x33000000);

  // Bagua-Inspired Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark], // Gold gradient
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark], // Blue gradient
  );

  // Bagua Yin-Yang inspired gradient
  static const LinearGradient baguaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C1C1C), primary], // Black to gold
  );

  // Fire element gradient
  static const LinearGradient fireGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accent, accentDark], // Red gradient
  );

  // Face Scanning Specific Colors - Bagua inspired
  static const Color scanningOverlay = Color(0x80000000); // Black overlay
  static const Color scanningFrame = Color(0xFFD4AF37); // Gold frame
  static const Color scanningProgress = Color(0xFF4682B4); // Blue progress

  // Chat Colors - Balanced elements
  static const Color chatUserBubble = Color(0xFFD4AF37); // Gold for user
  static const Color chatBotBubble = Color(0xFFF8F8F8); // Light surface
  static const Color chatUserText = Color(0xFF1C1C1C); // Dark text on gold
  static const Color chatBotText = Color(0xFF1C1C1C); // Dark text

  // Result Colors - Five Elements harmony
  static const Color resultPositive = Color(0xFF87A96B); // Sage green (Wood)
  static const Color resultNeutral = Color(0xFFD4AF37); // Gold (Earth)
  static const Color resultNegative = Color(0xFFDC143C); // Chinese red (Fire)

  // Dark Theme Colors - Yin aspect of Bagua
  static const Color darkBackground = Color(0xFF1C1C1C); // Sophisticated black
  static const Color darkSurface = Color(0xFF2C2C2C); // Dark surface
  static const Color darkSurfaceVariant = Color(0xFF36454F); // Charcoal
  static const Color darkTextPrimary = Color(0xFFD4AF37); // Gold text
  static const Color darkTextSecondary = Color(0xFFF4E4BC); // Light gold
  static const Color darkBorder = Color(0xFFB8860B); // Dark gold border

  // Bagua Eight Trigrams Colors (for advanced theming)
  static const Color trigram1 = Color(0xFFD4AF37); // Heaven - Gold
  static const Color trigram2 = Color(0xFF4682B4); // Lake - Blue
  static const Color trigram3 = Color(0xFFDC143C); // Fire - Red
  static const Color trigram4 = Color(0xFF87A96B); // Thunder - Green
  static const Color trigram5 = Color(0xFFB8860B); // Wind - Dark Gold
  static const Color trigram6 = Color(0xFF2C5F7C); // Water - Deep Blue
  static const Color trigram7 = Color(0xFF36454F); // Mountain - Charcoal
  static const Color trigram8 = Color(0xFFF4E4BC); // Earth - Light Gold

  // Utility Methods
  
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Get lighter shade of color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Get darker shade of color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
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

  /// Get Bagua trigram color by index (0-7)
  static Color getBaguaTrigramColor(int index) {
    switch (index % 8) {
      case 0: return trigram1; // Heaven
      case 1: return trigram2; // Lake
      case 2: return trigram3; // Fire
      case 3: return trigram4; // Thunder
      case 4: return trigram5; // Wind
      case 5: return trigram6; // Water
      case 6: return trigram7; // Mountain
      case 7: return trigram8; // Earth
      default: return primary;
    }
  }

  /// Get Five Elements color by element name
  static Color getFiveElementColor(String element) {
    switch (element.toLowerCase()) {
      case 'fire':
        return accent; // Red
      case 'earth':
        return primary; // Gold
      case 'metal':
        return surface; // White
      case 'water':
        return secondary; // Blue
      case 'wood':
        return success; // Green
      default:
        return textSecondary;
    }
  }

  /// Create Yin-Yang balanced color pair
  static List<Color> getYinYangColors() {
    return [Color(0xFF1C1C1C), Color(0xFFFAFAFA)]; // Black and White
  }

  /// Get harmonious color based on Bagua principles
  static Color getHarmoniousColor(Color baseColor) {
    // Simple complementary color logic based on Bagua balance
    final hsl = HSLColor.fromColor(baseColor);
    final complementaryHue = (hsl.hue + 180) % 360;
    return hsl.withHue(complementaryHue).toColor();
  }
}
