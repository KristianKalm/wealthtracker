import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../api/kryptic_session_api.dart';
import '../theme/KrypticColors.dart';
import '../layouts/KrypticBaseScreen.dart';
import '../widgets/KrypticToolbar.dart';
import '../views/KrypticSnackbar.dart';

class OtaStrings {
  final String title;
  final String back;
  final String failedToGetSecret;
  final String retry;
  final String isEnabled;
  final String twoFactorProtected;
  final String enterPasswordToRemove;
  final String passwordLabel;
  final String removeButton;
  final String scanQrCode;
  final String orEnterManually;
  final String keyCopied;
  final String enterCode;
  final String confirm;
  final String enabled;
  final String invalidCode;
  final String removed;
  final String failedToRemove;

  const OtaStrings({
    required this.title,
    required this.back,
    required this.failedToGetSecret,
    required this.retry,
    required this.isEnabled,
    required this.twoFactorProtected,
    required this.enterPasswordToRemove,
    required this.passwordLabel,
    required this.removeButton,
    required this.scanQrCode,
    required this.orEnterManually,
    required this.keyCopied,
    required this.enterCode,
    required this.confirm,
    required this.enabled,
    required this.invalidCode,
    required this.removed,
    required this.failedToRemove,
  });
}

enum OtaState { loading, setup, exists, error }

class OtaScreen extends ConsumerStatefulWidget {
  final ProviderListenable<Future<KrypticSessionApi?>> sessionApiProvider;
  final String appName;
  final OtaStrings strings;

  const OtaScreen({
    super.key,
    required this.sessionApiProvider,
    required this.appName,
    required this.strings,
  });

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

  @override
  void dispose() {
    pinController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _fetchOta() async {
    setState(() {
      otaState = OtaState.loading;
      errorMessage = null;
    });

    final api = await ref.read(widget.sessionApiProvider);
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
          errorMessage = widget.strings.failedToGetSecret;
          otaState = OtaState.error;
      }
    });
  }

  Future<void> _confirmPin() async {
    final pin = pinController.text.trim();
    if (pin.length != 6) return;

    setState(() => isConfirming = true);

    final api = await ref.read(widget.sessionApiProvider);
    if (api == null) return;
    final success = await api.confirmOta(pin);

    if (!mounted) return;

    setState(() => isConfirming = false);

    if (success) {
      KrypticSnackbar.showSuccess(context, widget.strings.enabled);
      Navigator.pop(context);
    } else {
      KrypticSnackbar.showError(context, widget.strings.invalidCode);
      pinController.clear();
    }
  }

  Future<void> _deleteOta() async {
    final password = passwordController.text;
    if (password.isEmpty) return;

    setState(() => isDeleting = true);

    final api = await ref.read(widget.sessionApiProvider);
    if (api == null) return;
    final success = await api.deleteOta(password);

    if (!mounted) return;

    setState(() => isDeleting = false);

    if (success) {
      KrypticSnackbar.showSuccess(context, widget.strings.removed);
      Navigator.pop(context);
    } else {
      KrypticSnackbar.showError(context, widget.strings.failedToRemove);
      passwordController.clear();
    }
  }

  String _buildOtpAuthUri(String secret) {
    return 'otpauth://totp/${widget.appName}?secret=$secret&issuer=${widget.appName}';
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
          tooltip: widget.strings.back,
        ),
        title: widget.strings.title,
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
                child: Text(widget.strings.retry),
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
              widget.strings.isEnabled,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.strings.twoFactorProtected,
              style: TextStyle(fontSize: 14, color: colors.secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Text(
              widget.strings.enterPasswordToRemove,
              style: TextStyle(fontSize: 14, color: colors.primaryText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: widget.strings.passwordLabel,
                hintText: widget.strings.passwordLabel,
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
                  : Text(widget.strings.removeButton),
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
              widget.strings.scanQrCode,
              style: TextStyle(fontSize: 16, color: colors.primaryText),
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
              widget.strings.orEnterManually,
              style: TextStyle(fontSize: 14, color: colors.secondaryText),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: otaSecret!));
                KrypticSnackbar.show(context, widget.strings.keyCopied);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    Icon(Icons.copy, size: 18, color: colors.secondaryText),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              widget.strings.enterCode,
              style: TextStyle(fontSize: 14, color: colors.primaryText),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              child: TextField(
                controller: pinController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  counterText: '',
                  hintText: '000000',
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  : Text(widget.strings.confirm),
            ),
          ],
        ),
      ),
    );
  }
}
