import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kryptic_core/kryptic_core.dart';

import '../features/asset/AssetListScreen.dart';
import '../features/Providers.dart';
import 'api_config.dart';
import 'sync/WealthtrackerSync.dart' as WealthtrackerSync;
import '../l10n/l10n.dart';

LoginScreen makeLoginScreen(WidgetRef ref, {bool isFirstTime = false}) {
  return LoginScreen(
    isFirstTime: isFirstTime,
    apiConfig: wealthtrackerApiConfig,
    prefsProvider: wealthtrackerPrefsProvider,
    pgpProvider: pgpProvider.future,
    onAfterLogin: (context, ref) async {
      ref.invalidate(wealthtrackerSyncProvider);
      ref.invalidate(pgpProvider);
      krypticPopup(context, title: context.l10n.syncingTitle, subtitle: context.l10n.downloadingData);
      try {
        await WealthtrackerSync.fullDownload(ref);
      } catch (_) {}
      if (!context.mounted) return;
      hideKrypticPopup(context);
      KrypticSnackbar.showSuccess(context, context.l10n.signedInSuccessfully);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, _, __) => const AssetListScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    },
    onAfterRegister: (context, ref, seed) async {
      ref.invalidate(wealthtrackerSyncProvider);
      ref.invalidate(pgpProvider);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.backupYourSeed),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.backupSeedMessage),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: seed));
                  KrypticSnackbar.show(context, context.l10n.seedCopied);
                },
                child: Text(
                  seed,
                  style: TextStyle(
                    color: KrypticColors(Theme.of(context).brightness == Brightness.dark).accentPurple,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.ok),
            ),
          ],
        ),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          KrypticSnackbar.showSuccess(context, context.l10n.accountCreatedSuccessfully);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, _, __) => const AssetListScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          });
        }
      });
    },
    onUseWithoutAccount: (context, ref) async {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, _, __) => const AssetListScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    },
  );
}
