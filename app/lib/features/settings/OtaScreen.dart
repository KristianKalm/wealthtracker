import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:kryptic_ui/kryptic_ui.dart';
import '../../l10n/l10n.dart';
import '../Providers.dart';

enum OtaState { loading, setup, exists, error }

class OtaScreen extends ConsumerStatefulWidget {
  const OtaScreen({super.key});

  @override
  ConsumerState<OtaScreen> createState() => _OtaScreenState();
}

class _OtaScreenState extends ConsumerState<OtaScreen> {
  String? otaSecret;
  String? errorMessage;
  OtaState otaState = OtaState.loading;
  bool isConfirming = false;
  bool isDeleting = false;
  late TextEditingController pinController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    pinController = TextEditingController();
    passwordController = TextEditingController();
    _fetchOta();
  }

  Future<void> _fetchOta() async {
    setState(() {
      otaState = OtaState.loading;
      errorMessage = null;
    });

    final api = await ref.read(wealthtrackerSessionApiProvider.future);
    if (api == null) return;
    final result = await api.getOta();

    if (!mounted) return;

    setState(() {
      switch (result['status']) {
        case 'new':
          otaSecret = result['ota'];
          otaState = OtaState.setup;
          break;
        case 'exists':
          otaState = OtaState.exists;
          break;
        default:
          errorMessage = context.l10n.otaFailedToGetSecret;
          otaState = OtaState.error;
      }
    });
  }

  Future<void> _confirmPin() async {
    final pin = pinController.text.trim();
    if (pin.length != 6) return;

    setState(() {
      isConfirming = true;
    });

    final api = await ref.read(wealthtrackerSessionApiProvider.future);
    if (api == null) return;
    final success = await api.confirmOta(pin);

    if (!mounted) return;

    setState(() => isConfirming = false);

    if (success) {
      KrypticSnackbar.showSuccess(context, context.l10n.otaEnabled);
      Navigator.pop(context);
    } else {
      KrypticSnackbar.showError(context, context.l10n.otaInvalidCode);
      pinController.clear();
    }
  }

  Future<void> _deleteOta() async {
    final password = passwordController.text;
    if (password.isEmpty) return;

    setState(() {
      isDeleting = true;
    });

    final api = await ref.read(wealthtrackerSessionApiProvider.future);
    if (api == null) return;
    final success = await api.deleteOta(password);

    if (!mounted) return;

    setState(() => isDeleting = false);

    if (success) {
      KrypticSnackbar.showSuccess(context, context.l10n.otaPasswordRemoved);
      Navigator.pop(context);
    } else {
      KrypticSnackbar.showError(context, context.l10n.otaFailedToRemove);
      passwordController.clear();
    }
  }

  String _buildOtpAuthUri(String secret) {
    return 'otpauth://totp/Wealthtracker?secret=$secret&issuer=Wealthtracker';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = KrypticColors(isDark);

    return KrypticBaseScreen(
      toolbar: KrypticToolbar(
        leftButton: ToolbarButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.pop(context),
          tooltip: context.l10n.back,
        ),
        title: context.l10n.oneTimePasswordTitle,
      ),
      content: _buildContent(colors),
    );
  }

  Widget _buildContent(KrypticColors colors) {
    switch (otaState) {
      case OtaState.loading:
        return const Center(child: CircularProgressIndicator());
      case OtaState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!, style: TextStyle(color: colors.errorColor)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchOta,
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        );
      case OtaState.exists:
        return _buildExistsView(colors);
      case OtaState.setup:
        return _buildSetupView(colors);
    }
  }

  Widget _buildExistsView(KrypticColors colors) {
    return Center(
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 80),
            Icon(Icons.verified_user, size: 64, color: colors.successColor),
            const SizedBox(height: 24),
            Text(
              context.l10n.otaIsEnabled,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.otaTwoFactorProtected,
              style: TextStyle(
                fontSize: 14,
                color: colors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Text(
              context.l10n.otaEnterPasswordToRemove,
              style: TextStyle(
                fontSize: 14,
                color: colors.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: context.l10n.passwordLabel,
                hintText: context.l10n.passwordLabel,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isDeleting ? null : _deleteOta,
              child: isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.otaRemoveButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupView(KrypticColors colors) {
    return Center(
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            Text(
              context.l10n.otaScanQrCode,
              style: TextStyle(
                fontSize: 16,
                color: colors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: _buildOtpAuthUri(otaSecret!),
                version: QrVersions.auto,
                size: 200,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.otaOrEnterManually,
              style: TextStyle(
                fontSize: 14,
                color: colors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: otaSecret!));
                KrypticSnackbar.show(context, context.l10n.otaKeyCopied);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        otaSecret!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.primaryText,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.copy,
                      size: 18,
                      color: colors.secondaryText,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              context.l10n.otaEnterCode,
              style: TextStyle(
                fontSize: 14,
                color: colors.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              child: TextField(
                controller: pinController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  counterText: '',
                  hintText: '000000',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isConfirming ? null : _confirmPin,
              child: isConfirming
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }
}
