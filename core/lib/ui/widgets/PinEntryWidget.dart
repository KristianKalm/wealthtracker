import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../gen_l10n/core_localizations.dart';

class PinEntryWidget extends StatefulWidget {
  final String title;
  final String? subtitle;
  final int pinLength;
  final ValueChanged<String> onCompleted;
  final VoidCallback? onCancel;
  final Widget? bottomAction;

  const PinEntryWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.pinLength = 5,
    required this.onCompleted,
    this.onCancel,
    this.bottomAction,
  });

  @override
  PinEntryWidgetState createState() => PinEntryWidgetState();
}

class PinEntryWidgetState extends State<PinEntryWidget> {
  String _entered = '';
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void clear() {
    setState(() => _entered = '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace) {
      removeDigit();
    } else if (key.keyId >= LogicalKeyboardKey.digit0.keyId &&
        key.keyId <= LogicalKeyboardKey.digit9.keyId) {
      addDigit(String.fromCharCode(key.keyId));
    } else if (key.keyId >= LogicalKeyboardKey.numpad0.keyId &&
        key.keyId <= LogicalKeyboardKey.numpad9.keyId) {
      addDigit('${key.keyId - LogicalKeyboardKey.numpad0.keyId}');
    }
  }

  void addDigit(String digit) {
    if (_entered.length >= widget.pinLength) return;
    setState(() => _entered += digit);
    if (_entered.length == widget.pinLength) {
      widget.onCompleted(_entered);
    }
  }

  void removeDigit() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final filledColor = isDark ? Colors.white : Colors.black87;
    final emptyColor = isDark ? Colors.white38 : Colors.black26;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.subtitle != null)
          Text(
            widget.subtitle!,
            style: TextStyle(fontSize: 14, color: subtitleColor),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 24),
        // Circle indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.pinLength, (i) {
            final filled = i < _entered.length;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? filledColor : Colors.transparent,
                  border: Border.all(
                    color: filled ? filledColor : emptyColor,
                    width: 2,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        // Number pad
        _buildNumberPad(textColor, isDark),
        if (widget.bottomAction != null) ...[
          const SizedBox(height: 16),
          widget.bottomAction!,
        ],
      ],
    ),
    );
  }

  Widget _buildNumberPad(Color textColor, bool isDark) {
    final buttonColor = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);
    final cancelLabel = CoreLocalizations.of(context)?.cancel ?? 'Cancel';

    Widget digitButton(String digit) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Material(
            color: buttonColor,
            borderRadius: BorderRadius.circular(40),
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () => addDigit(digit),
              child: Container(
                height: 64,
                alignment: Alignment.center,
                child: Text(
                  digit,
                  style: TextStyle(fontSize: 28, color: textColor),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget emptyOrCancel() {
      if (widget.onCancel != null) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: widget.onCancel,
              child: Container(
                height: 64,
                alignment: Alignment.center,
                child: Text(
                  cancelLabel,
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
            ),
          ),
        );
      }
      return const Expanded(child: SizedBox(height: 64));
    }

    Widget backspaceButton() {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: removeDigit,
            child: Container(
              height: 64,
              alignment: Alignment.center,
              child: Icon(Icons.backspace_outlined, color: textColor, size: 24),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(children: [digitButton('1'), digitButton('2'), digitButton('3')]),
        Row(children: [digitButton('4'), digitButton('5'), digitButton('6')]),
        Row(children: [digitButton('7'), digitButton('8'), digitButton('9')]),
        Row(children: [emptyOrCancel(), digitButton('0'), backspaceButton()]),
      ],
    );
  }
}
