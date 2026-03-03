import 'package:flutter/material.dart';

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
  String? _error;

  CoreLocalizations get _l => CoreLocalizations.of(context)!;

  Future<void> _handlePinCompleted(String pin) async {
    final success = await widget.onPinVerify(pin);
    if (!success && mounted) {
      _pinKey.currentState?.clear();
      setState(() => _error = _l.wrongPin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _l.appIsLocked,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
