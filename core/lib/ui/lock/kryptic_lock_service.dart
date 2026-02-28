import 'package:flutter/widgets.dart';

import '../../auth/biometric_service.dart';
import '../../prefs/kryptic_prefs.dart';

class KrypticLockService {
  final KrypticPrefs prefs;
  final KrypticBiometricService biometricService;
  final VoidCallback onChanged;

  bool isLocked = false;
  bool pinEnabled = false;
  bool biometricEnabled = false;
  bool _isAuthenticating = false;

  KrypticLockService({
    required this.prefs,
    required this.biometricService,
    required this.onChanged,
  });

  Future<void> checkOnStart() async {
    final biometric = await prefs.getBool(PREFS_BIOMETRIC_LOCK);
    final pin = await prefs.get(PREFS_PIN_CODE);
    biometricEnabled = biometric;
    pinEnabled = pin != null;
    if (biometricEnabled || pinEnabled) {
      isLocked = true;
      onChanged();
      if (biometricEnabled && !pinEnabled) {
        authenticateBiometric();
      }
    }
  }

  Future<void> refreshState() async {
    final biometric = await prefs.getBool(PREFS_BIOMETRIC_LOCK);
    final pin = await prefs.get(PREFS_PIN_CODE);
    biometricEnabled = biometric;
    pinEnabled = pin != null;
  }

  void lockIfEnabled() {
    if ((biometricEnabled || pinEnabled) && !isLocked) {
      isLocked = true;
      onChanged();
    }
  }

  void unlock() {
    isLocked = false;
    onChanged();
  }

  Future<void> authenticateBiometric() async {
    if (_isAuthenticating) return;
    _isAuthenticating = true;
    try {
      final success = await biometricService.authenticate();
      if (success) unlock();
    } catch (_) {
      // Auth cancelled or failed — stay locked
    } finally {
      _isAuthenticating = false;
    }
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await prefs.get(PREFS_PIN_CODE);
    if (pin == storedPin) {
      unlock();
      return true;
    }
    return false;
  }

  void onAppLifecycleChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      lockIfEnabled();
    } else if (state == AppLifecycleState.resumed) {
      if (isLocked && biometricEnabled && !pinEnabled) {
        authenticateBiometric();
      }
      if (!isLocked) {
        refreshState();
      }
    }
  }
}
