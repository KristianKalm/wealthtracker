import 'package:flutter/material.dart';
import '../UiConf.dart';
import '../widgets/KrypticToolbar.dart';
import '../widgets/KrypticFloatingButton.dart';

class KrypticBaseScreen extends StatelessWidget {
  /// The main content of the screen
  final Widget content;

  /// Optional toolbar at the top
  final KrypticToolbar? toolbar;

  /// Optional bottom navigation bar
  final Widget? bottomNavigation;

  /// Optional save button configuration
  final SaveButtonConfig? saveButton;

  /// Optional left-side button configuration (shown opposite the save button)
  final SaveButtonConfig? leftButton;

  /// Optional floating action button
  final FloatingActionButtonConfig? floatingActionButton;

  /// Whether the scaffold should extend body behind bottom navigation
  final bool extendBody;

  /// Whether to resize when keyboard appears
  final bool resizeToAvoidBottomInset;

  /// Whether to vertically center the content
  final bool centerContent;

  const KrypticBaseScreen({
    super.key,
    required this.content,
    this.toolbar,
    this.bottomNavigation,
    this.saveButton,
    this.leftButton,
    this.floatingActionButton,
    this.extendBody = false,
    this.resizeToAvoidBottomInset = true,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Calculate bottom padding for content
    double contentBottomPadding = 16;
    if (saveButton != null) {
      contentBottomPadding += 72; // Space for save button
    }
    if (floatingActionButton != null) {
      contentBottomPadding += 72; // Space for FAB
    }
    if (bottomNavigation != null) {
      contentBottomPadding += 70; // Space for bottom nav
    }

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                top: toolbar != null ? 76 : 0,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  alignment: Alignment.topCenter,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: contentBottomPadding + keyboardPadding,
                        ),
                        child: centerContent
                            ? ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight - contentBottomPadding - keyboardPadding,
                                ),
                                child: Center(child: content),
                              )
                            : content,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Toolbar
          if (toolbar != null) toolbar!,

          // Save button (and optional left button)
          if (saveButton != null)
            Positioned(
              bottom: 16 + bottomPadding,
              left: 0,
              right: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (leftButton != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: KrypticExtendedFab(
                            label: leftButton!.label,
                            onPressed: leftButton!.onPressed,
                            tooltip: leftButton!.tooltip ?? leftButton!.label,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: KrypticExtendedFab(
                          label: saveButton!.label,
                          onPressed: saveButton!.onPressed,
                          tooltip: saveButton!.tooltip ?? saveButton!.label,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Floating Action Button
          if (floatingActionButton != null)
            Positioned(
              bottom: (bottomNavigation != null ? 102 : 16) + bottomPadding,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: KrypticFloatingButton(
                    icon: floatingActionButton!.icon,
                    onPressed: floatingActionButton!.onPressed,
                    tooltip: floatingActionButton!.tooltip,
                  ),
                ),
              ),
            ),

          // Bottom Navigation
          if (bottomNavigation != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: bottomNavigation!,
            ),
        ],
      ),
    );
  }
}

/// Configuration for the save button
class SaveButtonConfig {
  final String label;
  final VoidCallback onPressed;
  final String? tooltip;

  SaveButtonConfig({
    required this.label,
    required this.onPressed,
    this.tooltip,
  });
}

/// Configuration for the floating action button
class FloatingActionButtonConfig {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  FloatingActionButtonConfig({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });
}
