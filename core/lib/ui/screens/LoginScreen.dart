import 'dart:convert';
import 'dart:developer' as Logger;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/kryptic_api_config.dart';
import '../../kryptic_core_config.dart';
import '../../api/kryptic_auth_api.dart';
import '../../crypto/password_encryption.dart';
import '../../crypto/pgp_encryption.dart';
import '../../crypto/rsa_key_generation.dart';
import '../../gen_l10n/core_localizations.dart';
import '../../prefs/kryptic_prefs.dart';
import '../../util/device_info.dart';
import '../theme/KrypticColors.dart';
import '../layouts/KrypticBaseScreen.dart';
import '../widgets/KrypticToolbar.dart';
import '../UiExtensions.dart';
import '../views/KrypticSnackbar.dart';
import '../widgets/KrypticPopup.dart';
import 'ServerScreen.dart';

const int _usernameMinLength = 3;
const int _usernameMaxLength = 64;
const int _passwordMinLength = 16;
const int _passwordMaxLength = 128;

class LoginScreen extends ConsumerStatefulWidget {
  final bool isFirstTime;
  final KrypticApiConfig apiConfig;
  final ProviderListenable<KrypticPrefs> prefsProvider;
  final ProviderListenable<Future<KrypticPgpEncryption>> pgpProvider;
  final Future<void> Function(BuildContext context, WidgetRef ref) onAfterLogin;
  final Future<void> Function(BuildContext context, WidgetRef ref, String seed) onAfterRegister;
  final Future<void> Function(BuildContext context, WidgetRef ref) onUseWithoutAccount;

  const LoginScreen({
    super.key,
    this.isFirstTime = false,
    required this.apiConfig,
    required this.prefsProvider,
    required this.pgpProvider,
    required this.onAfterLogin,
    required this.onAfterRegister,
    required this.onUseWithoutAccount,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController captchaController;

  String serverUrl = '';
  String seed = '';
  bool isLoginMode = true;
  String? _captchaId;
  String? _captchaImageBase64;
  bool _isLoadingCaptcha = false;

  @override
  void initState() {
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    captchaController = TextEditingController();
    _generateSeed();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (serverUrl.isEmpty) {
      serverUrl = KrypticCore.of(context).defaultServerUrl;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    captchaController.dispose();
    super.dispose();
  }

  CoreLocalizations get _l => CoreLocalizations.of(context)!;

  _generateSeed() {
    setState(() {
      seed = generateMnemonic();
    });
  }

  _changeServer() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ServerScreen(initialUrl: serverUrl, apiConfig: widget.apiConfig),
      ),
    );
    if (result != null) {
      setState(() {
        serverUrl = result;
      });
    }
  }

  _useWithoutAccount() async {
    final prefs = ref.read(widget.prefsProvider);
    await prefs.setBool(PREFS_HAS_SIGNED_IN, true);
    if (!mounted) return;
    await widget.onUseWithoutAccount(context, ref);
  }

  _fetchCaptcha() async {
    setState(() {
      _isLoadingCaptcha = true;
      _captchaId = null;
      _captchaImageBase64 = null;
      captchaController.clear();
    });
    try {
      final result = await KrypticAuthApi(serverUrl, widget.apiConfig).getCaptcha();
      if (mounted) {
        setState(() {
          _captchaId = result['captcha_id'];
          _captchaImageBase64 = result['captcha_image'];
          _isLoadingCaptcha = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCaptcha = false);
    }
  }

  _register() async {
    Logger.log("Start register");

    if (usernameController.text.length < _usernameMinLength) {
      krypticPopup(context, title: _l.error, subtitle: _l.usernameTooShort(_usernameMinLength), buttonTitle: _l.ok, onButtonPressed: () => Navigator.pop(context));
      return;
    }
    if (usernameController.text.length > _usernameMaxLength) {
      krypticPopup(context, title: _l.error, subtitle: _l.usernameTooLong(_usernameMaxLength), buttonTitle: _l.ok, onButtonPressed: () => Navigator.pop(context));
      return;
    }
    if (passwordController.text.length < _passwordMinLength) {
      krypticPopup(context, title: _l.error, subtitle: _l.passwordTooShort(_passwordMinLength), buttonTitle: _l.ok, onButtonPressed: () => Navigator.pop(context));
      return;
    }
    if (passwordController.text.length > _passwordMaxLength) {
      krypticPopup(context, title: _l.error, subtitle: _l.passwordTooLong(_passwordMaxLength), buttonTitle: _l.ok, onButtonPressed: () => Navigator.pop(context));
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      krypticPopup(context, title: _l.error, subtitle: _l.newPasswordsDoNotMatch, buttonTitle: _l.ok, onButtonPressed: () => Navigator.pop(context));
      return;
    }
    if (_captchaId == null || captchaController.text.isEmpty) {
      krypticPopup(context, title: _l.error, subtitle: _l.captchaInvalid, buttonTitle: _l.ok, onButtonPressed: () => Navigator.pop(context));
      return;
    }

    krypticPopup(context, title: _l.creatingAccount, subtitle: _l.pleaseWait);
    await Future.delayed(Duration(milliseconds: 250));

    try {
      Logger.log("Get device name");
      final deviceName = await getDeviceName();

      Logger.log("Encrypt seed");
      final encryptedSeed = await encryptText(seed, passwordController.text);

      Logger.log("Generating PGP keys");
      var keys = await generatePGPKeys(seed);

      if (keys['private'] == null) {
        Logger.log("private key generation failed");
        hideKrypticPopup(context);
        krypticPopup(context, title: _l.error, subtitle: _l.keyGenerationFailed, buttonTitle: _l.ok, onButtonPressed: () => Navigator.pop(context));
        return;
      }

      final encryptedPrivateKey = await encryptText(keys['private']!, seed);

      KrypticAuthApi(serverUrl, widget.apiConfig)
          .register(
            usernameController.text,
            passwordController.text,
            encryptedSeed,
            keys['public'] ?? "",
            encryptedPrivateKey,
            deviceName,
            _captchaId ?? "",
            captchaController.text,
          )
          .then((result) async {
            hideKrypticPopup(context);

            if (result.containsKey("error")) {
              _fetchCaptcha();
              krypticPopup(
                context,
                title: _l.error,
                subtitle: result["error"]!.isNotEmpty ? result["error"]! : _l.somethingWentWrong,
                buttonTitle: _l.ok,
                onButtonPressed: () => Navigator.pop(context),
              );
            } else if (result.isNotEmpty) {
              final prefs = ref.read(widget.prefsProvider);
              await prefs.set(PREFS_SEED, seed);
              await prefs.set(PREFS_SERVER, serverUrl);
              await prefs.set(PREFS_USER, usernameController.text);
              await prefs.set(PREFS_PRIVATE_KEY, keys['private'] ?? "");
              await prefs.set(PREFS_PUBLIC_KEY, keys['public'] ?? "");
              await prefs.set(PREFS_TOKEN, result["token"] ?? "");
              await prefs.set(PREFS_TOKEN_ID, result["token_id"] ?? "");
              await prefs.setBool(PREFS_HAS_SIGNED_IN, true);

              if (!mounted) return;
              await widget.onAfterRegister(context, ref, seed);
            } else {
              krypticPopup(context, title: _l.error, subtitle: _l.somethingWentWrong, buttonTitle: _l.ok, onButtonPressed: () => Navigator.pop(context));
            }
          })
          .catchError((error) {
            _fetchCaptcha();
            hideKrypticPopup(context);
            krypticPopup(context, title: _l.error, subtitle: _l.registrationFailed(error.toString()), buttonTitle: _l.ok, onButtonPressed: () => Navigator.pop(context));
          });
    } catch (e) {
      hideKrypticPopup(context);
      krypticPopup(context, title: _l.error, subtitle: _l.anErrorOccurred(e.toString()), buttonTitle: _l.ok, onButtonPressed: () => Navigator.pop(context));
    }
  }

  _login({String? pin}) async {
    if (passwordController.text.length < _passwordMinLength) {
      krypticPopup(context, title: _l.error, subtitle: _l.passwordTooShort(_passwordMinLength), buttonTitle: _l.ok, onButtonPressed: () => Navigator.pop(context));
      return;
    }
    if (passwordController.text.length > _passwordMaxLength) {
      krypticPopup(context, title: _l.error, subtitle: _l.passwordTooLong(_passwordMaxLength), buttonTitle: _l.ok, onButtonPressed: () => Navigator.pop(context));
      return;
    }

    krypticPopup(context, title: _l.signingIn, subtitle: _l.pleaseWait);
    await Future.delayed(Duration(milliseconds: 250));

    try {
      Logger.log("Get device name");
      final deviceName = await getDeviceName();

      final result = await KrypticAuthApi(serverUrl, widget.apiConfig)
          .login(usernameController.text, passwordController.text, pin, deviceName);

      if (result.containsKey("otp_required")) {
        hideKrypticPopup(context);
        _showOtpDialog();
      } else if (result.containsKey("error")) {
        hideKrypticPopup(context);
        krypticPopup(
          context,
          title: _l.error,
          subtitle: _l.fromErrorCode(result["error"].toString()),
          buttonTitle: _l.ok,
          onButtonPressed: () => Navigator.pop(context),
        );
      } else if (result.isNotEmpty) {
        Logger.log("Login completed");

        var encryptedSeed = result["seed"];
        var decryptedSeed = decryptText(
          ciphertext: encryptedSeed["ciphertext"],
          salt: encryptedSeed["salt"],
          iv: encryptedSeed["iv"],
          password: passwordController.text,
        );

        var encryptedPrivateKey = result["private_key"];
        var privateKey = decryptText(
          ciphertext: encryptedPrivateKey["ciphertext"],
          salt: encryptedPrivateKey["salt"],
          iv: encryptedPrivateKey["iv"],
          password: decryptedSeed,
        );

        final prefs = ref.read(widget.prefsProvider);
        await prefs.set(PREFS_TOKEN, result["token"] ?? "");
        await prefs.set(PREFS_TOKEN_ID, result["token_id"] ?? "");
        await prefs.set(PREFS_USER, usernameController.text);
        await prefs.set(PREFS_SEED, decryptedSeed);
        await prefs.set(PREFS_SERVER, serverUrl);
        await prefs.set(PREFS_PRIVATE_KEY, privateKey);
        await prefs.set(PREFS_PUBLIC_KEY, result["public_key"].toString());
        await prefs.setBool(PREFS_HAS_SIGNED_IN, true);

        hideKrypticPopup(context);
        if (!mounted) return;
        await widget.onAfterLogin(context, ref);
      } else {
        hideKrypticPopup(context);
        krypticPopup(context, title: _l.error, subtitle: _l.somethingWentWrong, buttonTitle: _l.ok, onButtonPressed: () => Navigator.pop(context));
      }
    } catch (e) {
      hideKrypticPopup(context);
      krypticPopup(context, title: _l.error, subtitle: _l.anErrorOccurred(e.toString()), buttonTitle: _l.ok, onButtonPressed: () => Navigator.pop(context));
    }
  }

  _showOtpDialog() {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_l.oneTimePasswordTitle),
        content: TextField(
          controller: otpController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: _l.oneTimePasswordLabel,
            hintText: _l.oneTimePasswordLabel,
          ),
          obscureText: true,
          autofocus: true,
          onSubmitted: (_) {
            final otp = otpController.text;
            Navigator.pop(context);
            _login(pin: otp);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_l.cancel)),
          TextButton(
            onPressed: () {
              final otp = otpController.text;
              Navigator.pop(context);
              _login(pin: otp);
            },
            child: Text(_l.confirm),
          ),
        ],
      ),
    );
  }

  String _localeLabel(Locale? locale) {
    final options = KrypticCore.of(context).localeOptions;
    for (final option in options) {
      if (locale?.languageCode == option.$1.languageCode) return option.$2;
    }
    return options.isNotEmpty ? options.first.$2 : '';
  }

  void _showLanguageBottomSheet() {
    final coreConfig = KrypticCore.of(context);
    final currentLocale = ref.read(coreConfig.localeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_l.language, style: Theme.of(context).textTheme.titleMedium),
              ),
              for (final option in coreConfig.localeOptions)
                ListTile(
                  title: Text(option.$2),
                  trailing: currentLocale?.languageCode == option.$1.languageCode
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    coreConfig.setLocale(option.$1);
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(KrypticCore.of(context).localeProvider);

    return KrypticBaseScreen(
      toolbar: widget.isFirstTime
          ? null
          : KrypticToolbar(
              leftButton: ToolbarButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
                tooltip: _l.back,
              ),
              title: _l.loginButton,
            ),
      bottomNavigation: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _showLanguageBottomSheet,
                icon: const Icon(Icons.language, size: 16),
                label: Text(_localeLabel(locale)),
              ),
            ],
          ),
        ),
      ),
      content: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 60),
              Image.asset(KrypticCore.of(context).appLogoAsset, height: 140),
              const SizedBox(height: 40),
              _buildModeToggle(isDark),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: KrypticColors(isDark).cardBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.dns, size: 20, color: KrypticColors(isDark).secondaryText),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _l.serverLabel,
                            style: TextStyle(fontSize: 12, color: KrypticColors(isDark).secondaryText),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            serverUrl,
                            style: TextStyle(fontSize: 14, color: KrypticColors(isDark).primaryText),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TextButton(onPressed: () => _changeServer(), child: Text(_l.changeButton)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AutofillGroup(
                child: Column(
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: _l.usernameLabel,
                        hintText: _l.usernameLabel,
                        counterText: '',
                      ),
                      maxLength: _usernameMaxLength,
                      autofillHints: isLoginMode ? [AutofillHints.username] : [AutofillHints.newUsername],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: _l.passwordLabel,
                        hintText: _l.passwordLabel,
                        helperText: isLoginMode ? null : _l.passwordHelperText(_passwordMinLength, _passwordMaxLength),
                      ),
                      obscureText: true,
                      maxLength: _passwordMaxLength,
                      autofillHints: isLoginMode ? [AutofillHints.password] : [AutofillHints.newPassword],
                      textInputAction: isLoginMode ? TextInputAction.done : TextInputAction.next,
                      onSubmitted: isLoginMode ? (_) => _login() : null,
                    ),
                    if (!isLoginMode) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: _l.confirmNewPassword,
                          hintText: _l.confirmNewPassword,
                        ),
                        obscureText: true,
                        maxLength: _passwordMaxLength,
                        autofillHints: const [AutofillHints.newPassword],
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingCaptcha)
                        const Center(child: CircularProgressIndicator())
                      else if (_captchaImageBase64 != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.memory(base64Decode(_captchaImageBase64!), height: 60),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _fetchCaptcha,
                              tooltip: _l.retry,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: captchaController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: _l.captchaLabel,
                            hintText: _l.captchaLabel,
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _register(),
                        ),
                      ] else
                        TextButton.icon(
                          onPressed: _fetchCaptcha,
                          icon: const Icon(Icons.refresh),
                          label: Text(_l.captchaFailedToLoad),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                child: ElevatedButton(
                  onPressed: () => isLoginMode ? _login() : _register(),
                  child: Text(isLoginMode ? _l.loginButton : _l.registerButton),
                ),
              ),
              if (widget.isFirstTime) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _useWithoutAccount(),
                  child: Text(_l.useWithoutAccount),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle(bool isDark) {
    final colors = KrypticColors(isDark);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: BoxDecoration(
        color: colors.buttonBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: _l.loginButton,
              icon: Icons.login,
              isSelected: isLoginMode,
              isDark: isDark,
              onTap: () => setState(() => isLoginMode = true),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: _l.registerButton,
              icon: Icons.person_add,
              isSelected: !isLoginMode,
              isDark: isDark,
              onTap: () {
                setState(() => isLoginMode = false);
                _fetchCaptcha();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(30),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : KrypticColors(isDark).unselectedIcon,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : KrypticColors(isDark).unselectedIcon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
