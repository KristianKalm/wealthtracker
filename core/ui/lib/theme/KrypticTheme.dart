import 'package:flutter/material.dart';
import 'KrypticColors.dart';

class KrypticTheme {
  static ThemeData lightTheme() {
    final colors = KrypticColors(false);

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: colors.primaryBlue,
        secondary: colors.accentPurple,
        surface: colors.cardBackgroundColor,
        onPrimary: colors.white,
        onSecondary: colors.white,
        onSurface: colors.primaryText,
      ),
      scaffoldBackgroundColor: colors.backgroundColor,
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colors.backgroundColor,
        foregroundColor: colors.primaryText,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colors.primaryBlue,
          foregroundColor: colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: colors.primaryBlue.withOpacity(0.8),
          foregroundColor: colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.inputBorderFocused, width: 2),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.buttonBackground,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.backgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colors.backgroundColor,
        surfaceTintColor: colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: colors.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.black,
        contentTextStyle: TextStyle(
          color: colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actionTextColor: colors.white,
        // Position 86px from bottom (70px nav + 16px margin)
        insetPadding: const EdgeInsets.fromLTRB(24, 0, 24, 86),
      ),
    );
  }

  static ThemeData darkTheme() {
    final colors = KrypticColors(true);

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: colors.primaryBlue,
        secondary: colors.accentLightPurple,
        surface: colors.cardBackgroundColor,
        onPrimary: colors.white,
        onSecondary: colors.white,
        onSurface: colors.primaryText,
      ),
      scaffoldBackgroundColor: colors.backgroundColor,
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colors.backgroundColor,
        foregroundColor: colors.white,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colors.primaryBlue,
          foregroundColor: colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: colors.primaryBlue.withOpacity(0.8),
          foregroundColor: colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.inputBorderFocused, width: 2),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.backgroundColor,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.backgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colors.backgroundColor,
        surfaceTintColor: colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: colors.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.black,
        contentTextStyle: TextStyle(
          color: colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actionTextColor: colors.white,
        // Position 100px from bottom (70px nav + 30px margin)
        insetPadding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      ),
    );
  }

  // Reusable container decoration
  static BoxDecoration containerDecoration({
    required bool isDark,
    double borderRadius = 20,
  }) {
    final colors = KrypticColors(isDark);

    return BoxDecoration(
      color: colors.cardBackgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}
