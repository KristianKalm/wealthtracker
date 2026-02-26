import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthtracker/features/asset/AssetListScreen.dart';
import 'package:wealthtracker/features/sync/LoginScreen.dart';

import '../../core/prefs/WealthtrackerPrefs.dart';
import '../Providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final WealthtrackerPrefs prefs;

  const SplashScreen({super.key, required this.prefs});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startup();
  }

  Future<void> _startup() async {
    // Initialize the database via the provider (single instance)
    await ref.read(wealthtrackerRepositoryProvider.future);

    // Check if user has signed in before
    final hasSignedIn = await widget.prefs.getBool(PREFS_HAS_SIGNED_IN, defaultValue: false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
          hasSignedIn ? const AssetListScreen() : const LoginScreen(isFirstTime: true),
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
