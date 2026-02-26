import 'dart:developer' as Logger;

import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kryptic_core/kryptic_core.dart';
import 'package:openpgp/openpgp.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:crypto/crypto.dart';
import 'package:wealthtracker/features/asset/AssetListScreen.dart';

import '../../core/api_config.dart';
import '../../l10n/l10n.dart';
import '../../core/prefs/WealthtrackerPrefs.dart';
import '../../core/sync/WealthtrackerSync.dart' as WealthtrackerSync;
import '../../main.dart';
import '../Providers.dart';
import 'ServerScreen.dart';

const URL_PLACEHOLDER = "https://eu.wealthtracker.app/";
const double AUTH_CONTENT_WIDTH = 400;
const int USERNAME_MIN_LENGTH = 3;
const int USERNAME_MAX_LENGTH = 64;
const int PASSWORD_MIN_LENGTH = 16;
const int PASSWORD_MAX_LENGTH = 128;

class LoginScreen extends ConsumerStatefulWidget {
  final String serverUrl;
  final bool isFirstTime;

  const LoginScreen({super.key, this.serverUrl = URL_PLACEHOLDER, this.isFirstTime = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreen();
}

pc.AsymmetricKeyPair<pc.PublicKey, pc.PrivateKey> generateDeterministicRSA(
  String mnemonic, {
  int bits = 2048,
}) {
  final seed = bip39.mnemonicToSeed(mnemonic);
  final seedHash = sha256.convert(seed).bytes; // 32 bytes
  final secureRandom = pc.FortunaRandom()
    ..seed(pc.KeyParameter(Uint8List.fromList(seedHash)));
  final keyGen = pc.RSAKeyGenerator()
    ..init(
      pc.ParametersWithRandom(
        pc.RSAKeyGeneratorParameters(BigInt.parse('65537'), bits, 32),
        secureRandom,
      ),
    );
  return keyGen.generateKeyPair();
}

class _LoginScreen extends ConsumerState<LoginScreen> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  late String serverUrl;
  String seed = '';
  bool isLoginMode = true; // Toggle between login and register

  @override
  void initState() {
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    serverUrl = widget.serverUrl;
    _generateSeed();
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _generatePGPKeys(passphrase) async {
    try {
      var keyOptions = KeyOptions()..rsaBits = 2048;
      var keyPair = await OpenPGP.generate(
        options: Options()
          ..name = ''
          ..email = ''
          ..passphrase = passphrase
          ..keyOptions = keyOptions,
      );
      return {'public': keyPair.publicKey, 'private': keyPair.privateKey};
    } catch (e) {
      Logger.log('Error during key generation: $e');
      return {};
    }
  }

  _generateSeed() {
    setState(() {
      seed = bip39.generateMnemonic(strength: 256);
    });
  }

  _changeServer() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ServerScreen(initialUrl: serverUrl),
      ),
    );
    if (result != null) {
      setState(() {
        serverUrl = result;
      });
    }
  }

  _useWithoutAccount() async {
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    await wealthtrackerPrefs.setBool(PREFS_HAS_SIGNED_IN, true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            const AssetListScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  _register() async {
    Logger.log("Start register");

    if (usernameController.text.length < USERNAME_MIN_LENGTH) {
      krypticPopup(
        context,
        title: context.l10n.error,
        subtitle: context.l10n.usernameTooShort(USERNAME_MIN_LENGTH),
        buttonTitle: context.l10n.ok,
        onButtonPressed: () => Navigator.pop(context),
      );
      return;
    }

    if (usernameController.text.length > USERNAME_MAX_LENGTH) {
      krypticPopup(
        context,
        title: context.l10n.error,
        subtitle: context.l10n.usernameTooLong(USERNAME_MAX_LENGTH),
        buttonTitle: context.l10n.ok,
        onButtonPressed: () => Navigator.pop(context),
      );
      return;
    }

    if (passwordController.text.length < PASSWORD_MIN_LENGTH) {
      krypticPopup(
        context,
        title: context.l10n.error,
        subtitle: context.l10n.passwordTooShort(PASSWORD_MIN_LENGTH),
        buttonTitle: context.l10n.ok,
        onButtonPressed: () => Navigator.pop(context),
      );
      return;
    }

    if (passwordController.text.length > PASSWORD_MAX_LENGTH) {
      krypticPopup(
        context,
        title: context.l10n.error,
        subtitle: context.l10n.passwordTooLong(PASSWORD_MAX_LENGTH),
        buttonTitle: context.l10n.ok,
        onButtonPressed: () => Navigator.pop(context),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      krypticPopup(
        context,
        title: context.l10n.error,
        subtitle: context.l10n.newPasswordsDoNotMatch,
        buttonTitle: context.l10n.ok,
        onButtonPressed: () => Navigator.pop(context),
      );
      return;
    }

    // Show popup
    krypticPopup(context, title: context.l10n.creatingAccount, subtitle: context.l10n.pleaseWait);
    await Future.delayed(Duration(milliseconds: 250));

    try {
      Logger.log("Get device name");
      final deviceName = await getDeviceName();
      Logger.log("Device name: $deviceName");

      Logger.log("Encrypt seed");
      final encryptedSeed = await encryptText(seed, passwordController.text);
      Logger.log("Seed encrypted");

      Logger.log("Generating private key");
      var keys = await _generatePGPKeys(seed);
      Logger.log("Generating private key generated");

      Logger.log("Encrypt private key");
      if (keys['private'] == null) {
        Logger.log("private key generation failed");
        hideKrypticPopup(context);
        krypticPopup(
          context,
          title: context.l10n.error,
          subtitle: context.l10n.keyGenerationFailed,
          buttonTitle: context.l10n.ok,
          onButtonPressed: () => Navigator.pop(context),
        );
        return;
      }

      final encryptedPrivateKey = await encryptText(keys['private']!, seed);
      Logger.log("Private key encrypted ");

      KrypticAuthApi(serverUrl, wealthtrackerApiConfig)
          .register(
            usernameController.text,
            passwordController.text,
            encryptedSeed,
            keys['public'] ?? "",
            encryptedPrivateKey,
            deviceName,
          )
          .then((result) async {
            Logger.log("Register completed ");

            // Hide popup
            hideKrypticPopup(context);

            if (result.containsKey("error")) {
              krypticPopup(
                context,
                title: context.l10n.error,
                subtitle: result["error"]!.isNotEmpty ? result["error"]! : context.l10n.somethingWentWrong,
                buttonTitle: context.l10n.ok,
                onButtonPressed: () => Navigator.pop(context),
              );
            } else if (result.isNotEmpty) {
              final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
              await wealthtrackerPrefs.set(PREFS_SEED, seed);
              await wealthtrackerPrefs.set(PREFS_SERVER, serverUrl);
              await wealthtrackerPrefs.set(PREFS_USER, usernameController.text);
              await wealthtrackerPrefs.set(PREFS_PRIVATE_KEY, keys['private'] ?? "");
              await wealthtrackerPrefs.set(PREFS_PUBLIC_KEY, keys['public'] ?? "");
              await wealthtrackerPrefs.set(PREFS_TOKEN, result["token"] ?? "");
              await wealthtrackerPrefs.set(PREFS_TOKEN_ID, result["token_id"] ?? "");
              await wealthtrackerPrefs.setBool(PREFS_HAS_SIGNED_IN, true);

              ref.invalidate(wealthtrackerSyncProvider);
              ref.invalidate(pgpProvider);

              // Show seed backup dialog (important for registration)
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Text(context.l10n.backupYourSeed),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.backupSeedMessage),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: seed));
                          KrypticSnackbar.show(context, context.l10n.seedCopied);
                        },
                        child: Text(
                          seed,
                          style: TextStyle(
                            color: KrypticColors(
                              Theme.of(context).brightness == Brightness.dark,
                            ).accentPurple,
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
              ).then((_) {
                // Wait a frame to ensure dialog is fully dismissed
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    KrypticSnackbar.showSuccess(context, context.l10n.accountCreatedSuccessfully);
                    // Navigate to DashboardScreen with full download
                    Future.delayed(Duration(milliseconds: 300), () {
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                const AssetListScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      }
                    });
                  }
                });
              });
            } else {
              krypticPopup(
                context,
                title: context.l10n.error,
                subtitle: context.l10n.somethingWentWrong,
                buttonTitle: context.l10n.ok,
                onButtonPressed: () => Navigator.pop(context),
              );
            }
          })
          .catchError((error) {
            // Hide popup on error
            hideKrypticPopup(context);
            krypticPopup(
              context,
              title: context.l10n.error,
              subtitle: context.l10n.registrationFailed(error.toString()),
              buttonTitle: context.l10n.ok,
              onButtonPressed: () => Navigator.pop(context),
            );
          });
    } catch (e) {
      // Hide popup on exception
      hideKrypticPopup(context);
      krypticPopup(
        context,
        title: context.l10n.error,
        subtitle: context.l10n.anErrorOccurred(e.toString()),
        buttonTitle: context.l10n.ok,
        onButtonPressed: () => Navigator.pop(context),
      );
    }
  }

  _login({String? pin}) async {
    if (passwordController.text.length < PASSWORD_MIN_LENGTH) {
      krypticPopup(
        context,
        title: context.l10n.error,
        subtitle: context.l10n.passwordTooShort(PASSWORD_MIN_LENGTH),
        buttonTitle: context.l10n.ok,
        onButtonPressed: () => Navigator.pop(context),
      );
      return;
    }

    if (passwordController.text.length > PASSWORD_MAX_LENGTH) {
      krypticPopup(
        context,
        title: context.l10n.error,
        subtitle: context.l10n.passwordTooLong(PASSWORD_MAX_LENGTH),
        buttonTitle: context.l10n.ok,
        onButtonPressed: () => Navigator.pop(context),
      );
      return;
    }

    // Show popup
    krypticPopup(context, title: context.l10n.signingIn, subtitle: context.l10n.pleaseWait);
    await Future.delayed(Duration(milliseconds: 250));
    try {
      Logger.log("Get device name");
      final deviceName = await getDeviceName();
      Logger.log("Device name: $deviceName");

      final result = await KrypticAuthApi(serverUrl, wealthtrackerApiConfig)
          .login(
            usernameController.text,
            passwordController.text,
            pin,
            deviceName,
          );

      if (result.containsKey("otp_required")) {
        hideKrypticPopup(context);
        _showOtpDialog();
      } else if (result.containsKey("error")) {
        hideKrypticPopup(context);
        krypticPopup(
          context,
          title: context.l10n.error,
          subtitle: context.fromCode(result["error"].toString()),
          buttonTitle: context.l10n.ok,
          onButtonPressed: () => Navigator.pop(context),
        );
      } else if (result.isNotEmpty) {
        Logger.log("Login requests completed ");

        var encryptedSeed = result["seed"];
        var seed = decryptText(
          ciphertext: encryptedSeed["ciphertext"],
          salt: encryptedSeed["salt"],
          iv: encryptedSeed["iv"],
          password: passwordController.text,
        );
        Logger.log("Seed decrypted");

        Logger.log("Private key started");
        var encryptedPrivateKey = result["private_key"];
        var privateKey = decryptText(
          ciphertext: encryptedPrivateKey["ciphertext"],
          salt: encryptedPrivateKey["salt"],
          iv: encryptedPrivateKey["iv"],
          password: seed,
        );
        Logger.log("Private key completed");

        final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
        await wealthtrackerPrefs.set(PREFS_TOKEN, result["token"] ?? "");
        await wealthtrackerPrefs.set(PREFS_TOKEN_ID, result["token_id"] ?? "");
        await wealthtrackerPrefs.set(PREFS_USER, usernameController.text);
        await wealthtrackerPrefs.set(PREFS_SEED, seed);
        await wealthtrackerPrefs.set(PREFS_SERVER, serverUrl);
        await wealthtrackerPrefs.set(PREFS_PRIVATE_KEY, privateKey);
        await wealthtrackerPrefs.set(PREFS_PUBLIC_KEY, result["public_key"].toString());
        await wealthtrackerPrefs.setBool(PREFS_HAS_SIGNED_IN, true);

        ref.invalidate(wealthtrackerSyncProvider);
        ref.invalidate(pgpProvider);

        // Hide sign-in popup, show syncing popup
        hideKrypticPopup(context);
        krypticPopup(context, title: context.l10n.syncingTitle, subtitle: context.l10n.downloadingData);

        try {
          await WealthtrackerSync.fullDownload(ref);
        } catch (e) {
          Logger.log('Full download after login failed: $e');
        }

        if (!mounted) return;
        hideKrypticPopup(context);

        KrypticSnackbar.showSuccess(context, context.l10n.signedInSuccessfully);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const AssetListScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        // Hide popup
        hideKrypticPopup(context);

        krypticPopup(
          context,
          title: context.l10n.error,
          subtitle: context.l10n.somethingWentWrong,
          buttonTitle: context.l10n.ok,
          onButtonPressed: () => Navigator.pop(context),
        );
      }
    } catch (e) {
      // Hide popup on exception
      hideKrypticPopup(context);
      krypticPopup(
        context,
        title: context.l10n.error,
        subtitle: context.l10n.anErrorOccurred(e.toString()),
        buttonTitle: context.l10n.ok,
        onButtonPressed: () => Navigator.pop(context),
      );
    }
  }

  _showOtpDialog() {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.oneTimePasswordTitle),
        content: TextField(
          controller: otpController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.l10n.oneTimePasswordLabel,
            hintText: context.l10n.oneTimePasswordLabel,
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final otp = otpController.text;
              Navigator.pop(context);
              _login(pin: otp);
            },
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
  }

  String _localeLabel(Locale? locale) {
    switch (locale?.languageCode) {
      case 'et':
        return 'Eesti';
      case 'en':
        return 'English';
      default:
        return 'English';
    }
  }

  void _showLanguageBottomSheet() {
    final currentLocale = ref.read(localeNotifierProvider);
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
                child: Text(
                  context.l10n.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final option in [
                (const Locale('en'), 'English'),
                (const Locale('et'), 'Eesti'),
              ])
                ListTile(
                  title: Text(option.$2),
                  trailing: currentLocale == option.$1
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    ref
                        .read(localeNotifierProvider.notifier)
                        .setLocale(option.$1);
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
    final locale = ref.watch(localeNotifierProvider);

    return KrypticBaseScreen(
      toolbar: widget.isFirstTime
          ? null
          : KrypticToolbar(
              leftButton: ToolbarButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
                tooltip: context.l10n.back,
              ),
              title: context.l10n.loginButton,
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
          width: AUTH_CONTENT_WIDTH,
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Image.asset(
            'assets/icon/wealthtrackerColored.png',
            height: 140,
          ),
          const SizedBox(height: 40),
          // Login/Register toggle buttons
          _buildModeToggle(isDark),
          const SizedBox(height: 24),
          // Server card
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
                        context.l10n.serverLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: KrypticColors(isDark).secondaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        serverUrl,
                        style: TextStyle(
                          fontSize: 14,
                          color: KrypticColors(isDark).primaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _changeServer(),
                  child: Text(context.l10n.changeButton),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Form fields
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: context.l10n.usernameLabel,
              hintText: context.l10n.usernameLabel,
              counterText: '',
            ),
            maxLength: USERNAME_MAX_LENGTH,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: context.l10n.passwordLabel,
              hintText: context.l10n.passwordLabel,
              helperText: isLoginMode ? null : context.l10n.passwordHelperText(PASSWORD_MIN_LENGTH, PASSWORD_MAX_LENGTH),
            ),
            obscureText: true,
            maxLength: PASSWORD_MAX_LENGTH,
            onSubmitted: isLoginMode ? (_) => _login() : null,
          ),
          if (!isLoginMode) ...[
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: context.l10n.confirmNewPassword,
                hintText: context.l10n.confirmNewPassword,
              ),
              obscureText: true,
              maxLength: PASSWORD_MAX_LENGTH,
              onSubmitted: (_) => _register(),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            child: ElevatedButton(
              onPressed: () {
                if (isLoginMode) {
                  _login();
                }
                else {
                  _register();
                }
              },
              child: Text(isLoginMode ? context.l10n.loginButton : context.l10n.registerButton),
            ),
          ),
          if (widget.isFirstTime) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _useWithoutAccount(),
              child: Text(context.l10n.useWithoutAccount),
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
              label: context.l10n.loginButton,
              icon: Icons.login,
              isSelected: isLoginMode,
              isDark: isDark,
              onTap: () {
                setState(() {
                  isLoginMode = true;
                });
              },
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: context.l10n.registerButton,
              icon: Icons.person_add,
              isSelected: !isLoginMode,
              isDark: isDark,
              onTap: () {
                setState(() {
                  isLoginMode = false;
                });
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
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
