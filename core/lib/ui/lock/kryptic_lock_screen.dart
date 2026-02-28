import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../gen_l10n/core_localizations.dart';
import '../widgets/PinEntryWidget.dart';

class KrypticLockScreen extends StatefulWidget {
  final bool pinEnabled;
  final bool biometricEnabled;
  final Future<bool> Function(String) onPinVerify;
  final VoidCallback onBiometricTap;

  const KrypticLockScreen({
    super.key,
    required this.pinEnabled,
    required this.biometricEnabled,
    required this.onPinVerify,
    required this.onBiometricTap,
  });

  @override
  State<KrypticLockScreen> createState() => _KrypticLockScreenState();
}

class _KrypticLockScreenState extends State<KrypticLockScreen> {
  final _pinKey = GlobalKey<PinEntryWidgetState>();
  final _focusNode = FocusNode();
  String? _error;

  CoreLocalizations get _l => CoreLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
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
    if (event is! KeyDownEvent || !widget.pinEnabled) return;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace) {
      _pinKey.currentState?.removeDigit();
    } else if (key.keyId >= LogicalKeyboardKey.digit0.keyId &&
        key.keyId <= LogicalKeyboardKey.digit9.keyId) {
      _pinKey.currentState?.addDigit(String.fromCharCode(key.keyId));
    } else if (key.keyId >= LogicalKeyboardKey.numpad0.keyId &&
        key.keyId <= LogicalKeyboardKey.numpad9.keyId) {
      _pinKey.currentState?.addDigit('${key.keyId - LogicalKeyboardKey.numpad0.keyId}');
    }
  }

  Future<void> _handlePinCompleted(String pin) async {
    final success = await widget.onPinVerify(pin);
    if (!success && mounted) {
      _pinKey.currentState?.clear();
      setState(() => _error = _l.wrongPin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: Center(
          child: SizedBox(
            width: 400,
            child: widget.pinEnabled
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: PinEntryWidget(
                      key: _pinKey,
                      title: _l.enterPin,
                      subtitle: _error,
                      onCompleted: _handlePinCompleted,
                      bottomAction: widget.biometricEnabled
                          ? TextButton.icon(
                              onPressed: widget.onBiometricTap,
                              icon: const Icon(Icons.fingerprint),
                              label: Text(_l.useBiometrics),
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            )
                          : null,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 64,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _l.appIsLocked,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextButton.icon(
                        onPressed: widget.onBiometricTap,
                        icon: const Icon(Icons.fingerprint),
                        label: Text(_l.unlock),
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
