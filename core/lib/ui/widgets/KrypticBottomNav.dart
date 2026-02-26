import 'package:flutter/material.dart';
import '../theme/KrypticColors.dart';
import '../UiConf.dart';

class KrypticBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const KrypticBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = KrypticColors(isDark);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: bottomNavigationWidth),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          height: 70,
          decoration: BoxDecoration(
            color: colors.buttonBackground,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _buildNavItem(
                context,
                items[index],
                index == currentIndex,
                () => onTap(index),
                isDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    BottomNavItem item,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    final colors = KrypticColors(isDark);
    final color = isSelected
        ? colors.selectedIcon
        : colors.unselectedIcon;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSelected ? 6 : 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.selectedBackground
                      : colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.icon,
                  size: isSelected ? 24 : 22,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 10 : 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.label,
  });
}
