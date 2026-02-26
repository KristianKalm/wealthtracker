import 'package:flutter/material.dart';

abstract class KrypticColors {
  // Background Colors
  Color get backgroundColor;
  Color get cardBackgroundColor;
  Color get buttonBackground;

  // Primary Colors
  Color get primaryBlue;
  Color get primaryDarkBlue;
  Color get accentPurple;
  Color get accentLightPurple;

  // Navigation Colors
  Color get selectedIcon;
  Color get selectedBackground;
  Color get unselectedIcon;

  // Text Colors
  Color get primaryText;
  Color get secondaryText;

  // Status Colors
  Color get successColor;
  Color get errorColor;
  Color get warningColor;

  // Chart/Dashboard Colors
  Color get chartPrimary;
  Color get chartSecondary;
  Color get chartBackground;
  Color get chartGrid;
  Color get chartText;

  // Input Colors
  Color get inputFill;
  Color get inputBorder;
  Color get inputBorderFocused;

  // Utility Colors
  Color get transparent;
  Color get white;
  Color get black;

  factory KrypticColors(bool isDark) {
    return isDark ? KrypticColorsDark() : KrypticColorsLight();
  }
}

class KrypticColorsDark implements KrypticColors {
  // Background Colors
  @override
  Color get backgroundColor => const Color(0xFF18181a);

  @override
  Color get cardBackgroundColor => const Color(0xFF212123);

  @override
  Color get buttonBackground => const Color(0xFF2a2a2c);

  // Primary Colors
  @override
  Color get primaryBlue => const Color(0xFF4E94F3);

  @override
  Color get primaryDarkBlue => const Color(0xFF2C7AE0);

  @override
  Color get accentPurple => const Color(0xFF8B5CF6);

  @override
  Color get accentLightPurple => const Color(0xFFA78BFA);

  // Navigation Colors
  @override
  Color get selectedIcon => const Color(0xFF4E94F3);

  @override
  Color get selectedBackground => const Color(0xFF1E3A5F);

  @override
  Color get unselectedIcon => const Color(0xFF8E8E93);

  // Text Colors
  @override
  Color get primaryText => const Color(0xFFF2F2F7);

  @override
  Color get secondaryText => const Color(0xFF8E8E93);

  // Status Colors
  @override
  Color get successColor => Colors.green;

  @override
  Color get errorColor => Colors.red;

  @override
  Color get warningColor => Colors.deepOrange;

  // Chart/Dashboard Colors
  @override
  Color get chartPrimary => const Color(0xFF4E94F3);

  @override
  Color get chartSecondary => const Color(0x44FFA726);

  @override
  Color get chartBackground => const Color(0xFF1A1A1A);

  @override
  Color get chartGrid => const Color(0xFF3A3A3C);

  @override
  Color get chartText => const Color(0xFFF2F2F7);

  // Input Colors
  @override
  Color get inputFill => const Color(0xFF1E1E20);

  @override
  Color get inputBorder => const Color(0xFF3A3A3C);

  @override
  Color get inputBorderFocused => const Color(0xFF4E94F3);

  // Utility Colors
  @override
  Color get transparent => Colors.transparent;

  @override
  Color get white => Colors.white;

  @override
  Color get black => Colors.black;
}

class KrypticColorsLight implements KrypticColors {
  // Background Colors
  @override
  Color get backgroundColor => const Color(0xFFfafaf9);

  @override
  Color get cardBackgroundColor => const Color(0xFFFFFFFF);

  @override
  Color get buttonBackground => const Color(0xFFededec);

  // Primary Colors
  @override
  Color get primaryBlue => const Color(0xFF4E94F3);

  @override
  Color get primaryDarkBlue => const Color(0xFF2C7AE0);

  @override
  Color get accentPurple => const Color(0xFF8B5CF6);

  @override
  Color get accentLightPurple => const Color(0xFFA78BFA);

  // Navigation Colors
  @override
  Color get selectedIcon => const Color(0xFF4E94F3);

  @override
  Color get selectedBackground => const Color(0xFFD6E8FC);

  @override
  Color get unselectedIcon => const Color(0xFF8E8E93);

  // Text Colors
  @override
  Color get primaryText => const Color(0xFF1C1C1E);

  @override
  Color get secondaryText => const Color(0xFF8E8E93);

  // Status Colors
  @override
  Color get successColor => Colors.green;

  @override
  Color get errorColor => Colors.red;

  @override
  Color get warningColor => Colors.deepOrange;

  // Chart/Dashboard Colors
  @override
  Color get chartPrimary => const Color(0xFF4E94F3);

  @override
  Color get chartSecondary => const Color(0x44FFA726);

  @override
  Color get chartBackground => const Color(0xFFF3F2EF);

  @override
  Color get chartGrid => const Color(0xFFE0DFDD);

  @override
  Color get chartText => const Color(0xFF1C1C1E);

  // Input Colors
  @override
  Color get inputFill => const Color(0xFFE5E4E2);

  @override
  Color get inputBorder => const Color(0xFFE0DFDD);

  @override
  Color get inputBorderFocused => const Color(0xFF4E94F3);

  // Utility Colors
  @override
  Color get transparent => Colors.transparent;

  @override
  Color get white => Colors.white;

  @override
  Color get black => Colors.black;
}
