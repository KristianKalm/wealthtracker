import 'package:flutter/material.dart';
import '../theme/KrypticColors.dart';

class KrypticPopup extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonTitle;
  final VoidCallback? onButtonPressed;

  const KrypticPopup({
    Key? key,
    required this.title,
    required this.subtitle,
    this.buttonTitle,
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = KrypticColors(isDark);

    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colors.buttonBackground,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                title,
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              // Optional button
              if (buttonTitle != null && onButtonPressed != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      buttonTitle!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show the popup
void krypticPopup(
  BuildContext context, {
  required String title,
  required String subtitle,
  String? buttonTitle,
  VoidCallback? onButtonPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: buttonTitle != null,
    barrierColor: Colors.transparent,
    builder: (context) => KrypticPopup(
      title: title,
      subtitle: subtitle,
      buttonTitle: buttonTitle,
      onButtonPressed: onButtonPressed,
    ),
  );
}

// Helper function to hide the popup
void hideKrypticPopup(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}
