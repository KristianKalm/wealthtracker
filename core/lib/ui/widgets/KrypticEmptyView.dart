import 'package:flutter/material.dart';

class KrypticEmptyView extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isEmpty;
  final Duration delay;

  const KrypticEmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isEmpty,
    this.delay = const Duration(milliseconds: 200),
  });

  @override
  State<KrypticEmptyView> createState() => _KrypticEmptyViewState();
}

class _KrypticEmptyViewState extends State<KrypticEmptyView> {
  bool _showEmpty = false;

  @override
  void initState() {
    super.initState();
    _checkEmpty();
  }

  @override
  void didUpdateWidget(KrypticEmptyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEmpty != widget.isEmpty) {
      _checkEmpty();
    }
  }

  void _checkEmpty() async {
    if (widget.isEmpty) {
      setState(() => _showEmpty = false);
      await Future.delayed(widget.delay);
      if (mounted && widget.isEmpty) {
        setState(() => _showEmpty = true);
      }
    } else {
      setState(() => _showEmpty = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            size: 120,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
