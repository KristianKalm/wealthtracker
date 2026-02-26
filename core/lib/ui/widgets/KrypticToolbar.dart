import 'package:flutter/material.dart';
import '../UiConf.dart';
import '../theme/KrypticColors.dart';
import 'KrypticFloatingButton.dart';

class ToolbarButton {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  ToolbarButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });
}

class KrypticToolbar extends StatefulWidget {
  final ToolbarButton? leftButton;
  final String? title;
  final VoidCallback? onTitleTap;
  final List<ToolbarButton> rightButtons;
  final bool enableSearch;
  final Function(String)? onSearchChanged;
  final String? searchHint;
  final TextEditingController? searchController;

  const KrypticToolbar({
    super.key,
    this.leftButton,
    this.title,
    this.onTitleTap,
    this.rightButtons = const [],
    this.enableSearch = false,
    this.onSearchChanged,
    this.searchHint = 'Search...',
    this.searchController,
  }) : assert(rightButtons.length <= 3, 'Maximum 3 right buttons allowed');

  @override
  State<KrypticToolbar> createState() => _KrypticToolbarState();
}

class _KrypticToolbarState extends State<KrypticToolbar> {
  bool _isSearchActive = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = widget.searchController ?? TextEditingController();
    _searchController.addListener(() {
      if (widget.onSearchChanged != null) {
        widget.onSearchChanged!(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    if (widget.searchController == null) {
      _searchController.dispose();
    }
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _isSearchActive ? _buildSearchBar() : _buildNormalBar(),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalBar() {
    // Calculate number of right buttons (search + configured buttons)
    final int rightButtonCount = (widget.enableSearch ? 1 : 0) + widget.rightButtons.length;

    // Each button is 48px wide, plus 8px padding between buttons
    final double rightButtonsWidth = (rightButtonCount * 48.0) + ((rightButtonCount - 1) * 8.0);
    // Always reserve 48px on left side (for button or placeholder)
    final double leftButtonsWidth = 48.0;

    // Calculate extra padding needed on left to balance the right side
    final double extraLeftPadding = rightButtonsWidth - leftButtonsWidth;

    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side (button + extra padding to balance right side)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leftButton != null)
                KrypticAppBarButton(
                  icon: widget.leftButton!.icon,
                  onPressed: widget.leftButton!.onPressed,
                  tooltip: widget.leftButton!.tooltip,
                )
              else
                const SizedBox(width: 48),
              // Add extra padding to balance right side buttons
              if (extraLeftPadding > 0)
                SizedBox(width: extraLeftPadding),
            ],
          ),

          // Title
          Expanded(
            child: Center(
              child: widget.title != null
                  ? GestureDetector(
                      onTap: widget.onTitleTap,
                      child: Text(
                        widget.title!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // Right buttons - always reserve space even if empty
          SizedBox(
            width: rightButtonsWidth > 0 ? rightButtonsWidth : 48,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Add search button if enabled
                if (widget.enableSearch)
                  KrypticAppBarButton(
                    icon: Icons.search,
                    onPressed: _toggleSearch,
                    tooltip: 'Search',
                  ),
                // Add configured right buttons with proper spacing
                ...widget.rightButtons.asMap().entries.map((entry) {
                  final index = entry.key;
                  final button = entry.value;
                  // Add left padding if there's a search button or previous right button
                  final needsPadding = widget.enableSearch || index > 0;
                  return Padding(
                    padding: EdgeInsets.only(left: needsPadding ? 8 : 0),
                    child: KrypticAppBarButton(
                      icon: button.icon,
                      onPressed: button.onPressed,
                      tooltip: button.tooltip,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: KrypticColors(Theme.of(context).brightness == Brightness.dark).buttonBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurface),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        KrypticAppBarButton(
          icon: Icons.close,
          onPressed: _toggleSearch,
          tooltip: 'Close Search',
        ),
      ],
    );
  }
}
