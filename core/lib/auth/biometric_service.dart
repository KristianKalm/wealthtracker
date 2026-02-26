import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

class KrypticBiometricService {
  final _auth = LocalAuthentication();
  final String localizedReason;

  KrypticBiometricService({this.localizedReason = 'Unlock app'});

  bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  Future<bool> isAvailable() async {
    if (!isSupportedPlatform) return false;
    return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
  }

  Future<bool> authenticate() async {
    return await _auth.authenticate(
      localizedReason: localizedReason,
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
      ),
    );
  }
}
