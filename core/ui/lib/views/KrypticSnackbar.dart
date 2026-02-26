import 'package:flutter/material.dart';

import '../theme/KrypticColors.dart';

class KrypticSnackbar {
  static void show(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = KrypticColors(isDark);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: colors.white)),
        backgroundColor: colors.black,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = KrypticColors(isDark);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: colors.white)),
        backgroundColor: colors.successColor,
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    final theme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: theme.onError)),
        backgroundColor: theme.error,
      ),
    );
  }
}
