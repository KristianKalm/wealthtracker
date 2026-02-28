import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../prefs/kryptic_prefs.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final KrypticPrefs prefs;
  final Future<void> Function(WidgetRef ref) onInit;
  final Widget homeScreen;
  final Widget loginScreen;

  const SplashScreen({
    super.key,
    required this.prefs,
    required this.onInit,
    required this.homeScreen,
    required this.loginScreen,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startup();
  }

  Future<void> _startup() async {
    await widget.onInit(ref);

    final hasSignedIn = await widget.prefs.getBool(PREFS_HAS_SIGNED_IN, defaultValue: false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            hasSignedIn ? widget.homeScreen : widget.loginScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Scaffold());
  }
}
