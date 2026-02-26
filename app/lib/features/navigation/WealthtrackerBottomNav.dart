import 'package:flutter/material.dart';
import 'package:wealthtracker/features/asset/AssetListScreen.dart';
import 'package:wealthtracker/features/graph/GraphScreen.dart';
import 'package:wealthtracker/features/settings/SettingsScreen.dart';
import 'package:kryptic_ui/kryptic_ui.dart';

Widget WealthtrackerBottomNav(BuildContext context, int selected) {
  return KrypticBottomNav(
    currentIndex: selected,
    items: const [
      BottomNavItem(icon: Icons.account_balance, label: 'Month'),
      BottomNavItem(icon: Icons.show_chart, label: 'Graph'),
      BottomNavItem(icon: Icons.settings, label: 'Settings'),
    ],
    onTap: (i) {
      if (i == selected) return;
      if (i == 0) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => AssetListScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
      if (i == 1) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => GraphScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
      if (i == 2) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => SettingsScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    },
  );
}
