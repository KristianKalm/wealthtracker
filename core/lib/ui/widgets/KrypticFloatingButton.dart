import 'package:flutter/material.dart';
import '../theme/KrypticColors.dart';

class KrypticFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;

  const KrypticFloatingButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 56.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = KrypticColors(isDark);

    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.buttonBackground,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          child: Icon(
            icon,
            color: colors.primaryText,
            size: size * 0.45,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

class KrypticAppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const KrypticAppBarButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KrypticFloatingButton(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip,
      size: 44.0,
    );
  }
}

class KrypticExtendedFab extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final String? tooltip;

  const KrypticExtendedFab({
    Key? key,
    required this.label,
    required this.onPressed,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = KrypticColors(isDark);

    final button = Material(
      borderRadius: BorderRadius.circular(24),
      color: colors.buttonBackground,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                color: colors.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
