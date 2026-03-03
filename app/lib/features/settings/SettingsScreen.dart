import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:kryptic_core/ui/screens/OtaScreen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthtracker/features/settings/AssetGroupListScreen.dart';
import 'package:wealthtracker/features/settings/TagListScreen.dart';

import '../../l10n/l10n.dart';
import '../../core/prefs/WealthtrackerPrefs.dart';
import '../../core/sync/WealthtrackerBackup.dart';
import '../../core/sync/WealthtrackerSync.dart' as WealthtrackerSync;
import '../../main.dart';
import '../navigation/WealthtrackerBottomNav.dart';
import 'package:kryptic_core/kryptic_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../Providers.dart';
import '../../core/login_screen_factory.dart';
import '../../core/api_config.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends ConsumerState<SettingsScreen> {
  var token = null;
  var username = null;
  var deleteController = TextEditingController();
  String? lastSyncLabel;
  bool _isSyncing = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _pinEnabled = false;
  int? _usageSizeBytes;
  int? _usageMaxMb;
  int _debugTapCount = 0;
  bool _legacyImportHidden = false;
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    updateToken();
    updateUsername();
    updateLastSync();
    _loadBiometricState();
    _loadPinState();
    _loadUsage();
    _loadLegacyImportHidden();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _appVersion = info.version);
  }

  Future<void> _loadBiometricState() async {
    final biometricService = ref.read(biometricServiceProvider);
    final available = await biometricService.isAvailable();
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    final enabled = await wealthtrackerPrefs.getBool(PREFS_BIOMETRIC_LOCK);
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
      });
    }
  }

  Future<void> _toggleBiometricLock() async {
    final biometricService = ref.read(biometricServiceProvider);
    final authenticated = await biometricService.authenticate();
    if (!authenticated) return;
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    final newValue = !_biometricEnabled;
    await wealthtrackerPrefs.setBool(PREFS_BIOMETRIC_LOCK, newValue);
    setState(() => _biometricEnabled = newValue);
  }

  Future<void> _loadPinState() async {
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    final pin = await wealthtrackerPrefs.get(PREFS_PIN_CODE);
    if (mounted) {
      setState(() => _pinEnabled = pin != null);
    }
  }

  void _onPinLockTap() {
    if (_pinEnabled) {
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
                    context.l10n.pinLock,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.edit, size: 20),
                  title: Text(context.l10n.changePinLabel),
                  onTap: () {
                    Navigator.pop(context);
                    _showSetPinDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, size: 20, color: Colors.red),
                  title: Text(
                    context.l10n.removePinLabel,
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removePinLock();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    } else {
      _showSetPinDialog();
    }
  }

  void _showSetPinDialog() {
    final pinKey = GlobalKey<PinEntryWidgetState>();
    String? firstPin;
    String? errorText;
    String dialogTitle = context.l10n.setPinTitle;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: PinEntryWidget(
                    key: pinKey,
                    title: dialogTitle,
                    subtitle: errorText,
                    onCancel: () => Navigator.pop(dialogContext),
                    onCompleted: (pin) async {
                      if (firstPin == null) {
                        firstPin = pin;
                        pinKey.currentState?.clear();
                        setDialogState(() {
                          dialogTitle = context.l10n.confirmPinTitle;
                          errorText = null;
                        });
                      } else {
                        if (pin == firstPin) {
                          final wealthtrackerPrefs = ref.read(
                            wealthtrackerPrefsProvider,
                          );
                          await wealthtrackerPrefs.set(PREFS_PIN_CODE, pin);
                          setState(() => _pinEnabled = true);
                          if (dialogContext.mounted)
                            Navigator.pop(dialogContext);
                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(this.context.l10n.pinSetSuccessfully),
                              ),
                            );
                          }
                        } else {
                          firstPin = null;
                          pinKey.currentState?.clear();
                          setDialogState(() {
                            dialogTitle = context.l10n.setPinTitle;
                            errorText = context.l10n.pinsDidNotMatch;
                          });
                        }
                      }
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _removePinLock() async {
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    await wealthtrackerPrefs.delete(PREFS_PIN_CODE);
    setState(() => _pinEnabled = false);
  }

  Future<void> _loadUsage() async {
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    final sizeStr = await wealthtrackerPrefs.get(PREFS_USAGE_SIZE_BYTES);
    final maxStr = await wealthtrackerPrefs.get(PREFS_USAGE_MAX_MB);
    if (!mounted) return;
    setState(() {
      _usageSizeBytes = sizeStr != null ? int.tryParse(sizeStr) : null;
      _usageMaxMb = maxStr != null ? int.tryParse(maxStr) : null;
    });
  }

  Future<void> _loadLegacyImportHidden() async {
    final repo = await ref.read(wealthtrackerRepositoryProvider.future);
    final myConf = await repo.conf.load();
    if (!mounted) return;
    setState(() {
      _legacyImportHidden = myConf.customConfigs['hideLegacyImport'] == true;
    });
  }

  Future<void> _toggleLegacyImportHidden() async {
    final repo = await ref.read(wealthtrackerRepositoryProvider.future);
    final myConf = await repo.conf.load();
    myConf.setCustomConfig('hideLegacyImport', !_legacyImportHidden);
    await repo.conf.save(myConf);
    WealthtrackerSync.uploadMyConf(ref);
    if (!mounted) return;
    setState(() {
      _legacyImportHidden = !_legacyImportHidden;
    });
  }

  void updateToken() {
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    wealthtrackerPrefs.get(PREFS_TOKEN).then((storedToken) {
      setState(() {
        token = storedToken;
      });
    });
  }

  void updateUsername() {
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    wealthtrackerPrefs.get(PREFS_USER).then((storedUsername) {
      setState(() {
        username = storedUsername;
      });
    });
  }

  Future<void> downloadBackup() async {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    Uint8List bytes = await backupWealthtrackerData(ref);
    String fileName = "Wealthtracker-${today}.zip";
    saveFile(bytes, fileName);
  }

  Future<void> saveFile(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        mimeType: MimeType.other,
      );
    } else {
      final tempDir = await getTemporaryDirectory();
      final file = io.File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: context.l10n.backupShareSubject,
        text: context.l10n.backupShareText(DateFormat('yyyy-MM-dd').format(DateTime.now())),
      );

      if (result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.dismissed) {
        await file.delete();
      }
    }
  }

  Future<void> pickBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: kIsWeb,
    );
    if (result == null) return;
    if (kIsWeb) {
      Uint8List? bytes = result.files.single.bytes;
      if (bytes != null) {
        await restoreWealthtrackerData(ref, bytes);
        await WealthtrackerSync.uploadUnsynced(ref);
      }
    } else {
      final path = result.files.single.path;
      if (path != null) {
        final file = io.File(path);
        final content = await file.readAsBytes();
        await restoreWealthtrackerData(ref, content);
        await WealthtrackerSync.uploadUnsynced(ref);
      }
    }
  }

  Future<void> pickLegacyJsonFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: kIsWeb,
    );
    if (result == null) return;
    String? jsonString;
    if (kIsWeb) {
      final bytes = result.files.single.bytes;
      if (bytes != null) jsonString = String.fromCharCodes(bytes);
    } else {
      final path = result.files.single.path;
      if (path != null) jsonString = await io.File(path).readAsString();
    }
    if (jsonString == null) return;
    final count = await restoreLegacyJson(ref, jsonString);
    await WealthtrackerSync.uploadUnsynced(ref);
    if (mounted) {
      KrypticSnackbar.showSuccess(
        context,
        context.l10n.importedLegacyItems(count),
      );
    }
  }

  Future<void> logOut() async {
    final isLoggedIn = token != null;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.l10n.logOutTitle),
          content: Text(
            isLoggedIn
                ? context.l10n.logOutConfirmLoggedIn
                : context.l10n.logOutConfirmNotLoggedIn,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.logOutButton, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await WealthtrackerSync.clearCache(ref);

    setState(() {
      token = null;
      username = null;
    });

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => makeLoginScreen(ref, isFirstTime: true)),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> changePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(context.l10n.changePasswordTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: context.l10n.currentPassword,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: context.l10n.newPassword,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: context.l10n.confirmNewPassword,
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorText!,
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(context.l10n.cancel),
                ),
                TextButton(
                  onPressed: () {
                    if (currentPasswordController.text.isEmpty ||
                        newPasswordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      setDialogState(
                        () => errorText = context.l10n.allFieldsRequired,
                      );
                      return;
                    }
                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      setDialogState(
                        () => errorText = context.l10n.newPasswordsDoNotMatch,
                      );
                      return;
                    }
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: Text(context.l10n.changeButton),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    final seed = await wealthtrackerPrefs.get(PREFS_SEED);
    final publicKey = await wealthtrackerPrefs.get(PREFS_PUBLIC_KEY);

    if (seed == null ||
        seed.isEmpty ||
        publicKey == null ||
        publicKey.isEmpty) {
      if (mounted)
        KrypticSnackbar.showError(context, context.l10n.accountDataNotFound);
      return;
    }

    final encryptedSeed = await encryptText(seed, newPasswordController.text);

    final api = await ref.read(wealthtrackerSessionApiProvider.future);
    if (api == null) return;

    final success = await api.changePassword(
      currentPasswordController.text,
      newPasswordController.text,
      encryptedSeed,
      publicKey,
    );

    if (!mounted) return;

    if (success) {
      KrypticSnackbar.showSuccess(context, context.l10n.passwordChangedSuccessfully);
    } else {
      KrypticSnackbar.showError(
        context,
        context.l10n.failedToChangePassword,
      );
    }
  }

  Future<void> deleteAccount() async {
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.l10n.deleteAccountTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.deleteAccountMessage),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: context.l10n.passwordLabel,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.delete, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final password = passwordController.text;
    if (password.isEmpty) return;

    final api = await ref.read(wealthtrackerSessionApiProvider.future);
    if (api == null) return;

    final success = await api.deleteAccount(password);

    if (!mounted) return;

    if (success) {
      await WealthtrackerSync.clearCache(ref);
      setState(() {
        token = null;
        username = null;
      });
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => makeLoginScreen(ref, isFirstTime: true),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      KrypticSnackbar.showError(
        context,
        context.l10n.failedToDeleteAccount,
      );
    }
  }

  Future<void> updateLastSync() async {
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    final downloadValue = await wealthtrackerPrefs.get(WealthtrackerSync.LAST_DOWNLOAD_TIME);
    final uploadValue = await wealthtrackerPrefs.get(WealthtrackerSync.LAST_UPLOAD_TIME);
    final downloadTs = downloadValue != null ? int.tryParse(downloadValue) : null;
    final uploadTs = uploadValue != null ? int.tryParse(uploadValue) : null;
    int? timestamp;
    if (downloadTs != null && uploadTs != null) {
      timestamp = downloadTs > uploadTs ? downloadTs : uploadTs;
    } else {
      timestamp = downloadTs ?? uploadTs;
    }
    if (timestamp == null || !mounted) return;
    final lastSync = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final diff = DateTime.now().difference(lastSync);
    setState(() {
      if (diff.inMinutes < 1) {
        lastSyncLabel = context.l10n.syncLastLessMinuteAgo;
      } else if (diff.inMinutes < 60) {
        final m = diff.inMinutes;
        lastSyncLabel = context.l10n.syncLastMinutesAgo(m);
      } else {
        final h = diff.inHours;
        lastSyncLabel = context.l10n.syncLastHoursAgo(h);
      }
    });
  }

  Future<void> syncNow() async {
    setState(() => _isSyncing = true);
    await WealthtrackerSync.syncNow(ref);
    if (mounted) {
      setState(() => _isSyncing = false);
      updateLastSync();
      _loadUsage();
    }
  }

  String _themeModeLabel(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return context.l10n.themeSystem;
      case ThemeMode.dark:
        return context.l10n.themeDark;
      case ThemeMode.light:
        return context.l10n.themeLight;
    }
  }

  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.light:
        return Icons.light_mode;
    }
  }

  void _showThemeBottomSheet() {
    final currentMode = ref.read(globalNotifierProvider);
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
                  context.l10n.theme,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final mode in ThemeMode.values)
                ListTile(
                  leading: Icon(_themeModeIcon(mode), size: 16),
                  title: Text(_themeModeLabel(context, mode)),
                  trailing: currentMode == mode
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    ref
                        .read(globalNotifierProvider.notifier)
                        .setThemeMode(mode);
                    Navigator.pop(context);
                  },
                ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
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

  void _showDebugMenu() {
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
                  context.l10n.debugTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bug_report, size: 20),
                title: Text(context.l10n.apiTester),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    this.context,
                    MaterialPageRoute(builder: (context) => KrypticDebugScreen(
                      apiConfig: wealthtrackerApiConfig,
                      prefsProvider: wealthtrackerPrefsProvider,
                    )),
                  );
                },
              ),
              if (_legacyImportHidden)
                ListTile(
                  leading: const Icon(Icons.history, size: 20),
                  title: Text(context.l10n.importLegacyJson),
                  onTap: () {
                    Navigator.pop(context);
                    pickLegacyJsonFile();
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
    final themeMode = ref.watch(globalNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = KrypticColors(isDark);

    return KrypticBaseScreen(
      extendBody: true,
      toolbar: KrypticToolbar(title: context.l10n.settingsTitle),
      bottomNavigation: WealthtrackerBottomNav(context, 2),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account section
          if (username != null)
            _SettingsGroup(
              title: context.l10n.account,
              colors: colors,
              children: [
                _SettingsItem(
                  icon: Icons.person,
                  title: context.l10n.user,
                  value: username!,
                  colors: colors,
                  onTap: () {
                    _debugTapCount++;
                    if (_debugTapCount >= 3) {
                      _debugTapCount = 0;
                      _showDebugMenu();
                    }
                  },
                ),
                if (_usageSizeBytes != null && _usageMaxMb != null)
                  _StorageUsageItem(
                    usedBytes: _usageSizeBytes!,
                    maxMb: _usageMaxMb!,
                    colors: colors,
                  ),
              ],
            ),

          // Preferences section
          _SettingsGroup(
            title: context.l10n.preferences,
            colors: colors,
            children: [
              _SettingsItem(
                icon: _themeModeIcon(themeMode),
                title: context.l10n.theme,
                value: _themeModeLabel(context, themeMode),
                colors: colors,
                showChevron: true,
                onTap: _showThemeBottomSheet,
              ),
              _SettingsItem(
                icon: Icons.language,
                title: context.l10n.language,
                value: _localeLabel(locale),
                colors: colors,
                showChevron: true,
                onTap: _showLanguageBottomSheet,
              ),
              _SettingsItem(
                icon: Icons.label,
                title: context.l10n.tags,
                colors: colors,
                showChevron: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TagListScreen(),
                  ),
                ),
              ),
              _SettingsItem(
                icon: Icons.folder_outlined,
                title: context.l10n.assetGroups,
                colors: colors,
                showChevron: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssetGroupListScreen(),
                  ),
                ),
              ),
              if (!kIsWeb && _biometricAvailable && !_pinEnabled)
                _SettingsItem(
                  icon: Icons.fingerprint,
                  title: context.l10n.appLock,
                  value: _biometricEnabled ? context.l10n.on : context.l10n.off,
                  colors: colors,
                  onTap: _toggleBiometricLock,
                ),
              if (!_biometricEnabled)
                _SettingsItem(
                  icon: Icons.pin,
                  title: context.l10n.pinLock,
                  value: _pinEnabled ? context.l10n.on : context.l10n.off,
                  colors: colors,
                  onTap: _onPinLockTap,
                ),
            ],
          ),

          // Sync section
          _SettingsGroup(
            title: context.l10n.syncSection,
            colors: colors,
            children: [
              if (token != null) ...[
                _SettingsItem(
                  icon: Icons.sync,
                  title: context.l10n.syncNow,
                  value: _isSyncing ? context.l10n.syncingTitle : lastSyncLabel,
                  colors: colors,
                  onTap: () async {
                    await syncNow();
                  },
                ),
                _SettingsItem(
                  icon: Icons.lock,
                  title: context.l10n.setOneTimePassword,
                  colors: colors,
                  showChevron: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OtaScreen(
                      sessionApiProvider: wealthtrackerSessionApiProvider.future,
                      appName: 'Wealthtracker',
                    )),
                  ),
                ),
                _SettingsItem(
                  icon: Icons.key,
                  title: context.l10n.tokens,
                  colors: colors,
                  showChevron: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TokenListScreen(
                      sessionApiProvider: wealthtrackerSessionApiProvider.future,
                      prefsProvider: wealthtrackerPrefsProvider,
                      pgpProvider: pgpProvider.future,
                    )),
                  ),
                ),
                _SettingsItem(
                  icon: Icons.password,
                  title: context.l10n.changePasswordSetting,
                  colors: colors,
                  onTap: changePassword,
                ),
                _SettingsItem(
                  icon: Icons.delete,
                  title: context.l10n.deleteMyAccount,
                  colors: colors,
                  onTap: deleteAccount,
                ),
              ],
              _SettingsItem(
                icon: Icons.logout,
                title: context.l10n.logOutSetting,
                colors: colors,
                onTap: logOut,
              ),
            ],
          ),

          // Backup section
          _SettingsGroup(
            title: context.l10n.localBackup,
            colors: colors,
            children: [
              _SettingsItem(
                icon: Icons.download,
                title: context.l10n.exportBackup,
                colors: colors,
                onTap: downloadBackup,
              ),
              _SettingsItem(
                icon: Icons.upload,
                title: context.l10n.importBackup,
                colors: colors,
                onTap: pickBackupFile,
              ),
              if (!_legacyImportHidden)
                _SettingsItem(
                  icon: Icons.history,
                  title: context.l10n.importLegacyJson,
                  subtitle: context.l10n.importLegacySubtitle,
                  colors: colors,
                  onTap: pickLegacyJsonFile,
                  trailing: GestureDetector(
                    onTap: _toggleLegacyImportHidden,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        context.l10n.hideLabel,
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // About section
          _SettingsGroup(
            title: 'About',
            colors: colors,
            children: [
              _SettingsItem(
                icon: Icons.info_outline,
                title: 'App version',
                value: _appVersion,
                colors: colors,
              ),
              _SettingsItem(
                icon: Icons.description_outlined,
                title: 'Open-source licenses',
                colors: colors,
                showChevron: true,
                onTap: () => showLicensePage(context: context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final KrypticColors colors;
  final List<Widget> children;

  const _SettingsGroup({
    required this.title,
    required this.colors,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out any null children from conditional items
    final items = children;
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                color: colors.primaryText,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colors.cardBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: _buildItemsWithDividers(items)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItemsWithDividers(List<Widget> items) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: colors.inputBorder,
            ),
          ),
        );
      }
    }
    return result;
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final KrypticColors colors;
  final bool showChevron;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.colors,
    this.subtitle,
    this.value,
    this.showChevron = false,
    this.onTap,
    this.titleColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colors.secondaryText),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor ?? colors.primaryText,
                        fontSize: 16,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (value != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    value!,
                    style: TextStyle(color: colors.secondaryText, fontSize: 14),
                  ),
                ),
              if (showChevron)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: colors.secondaryText,
                  ),
                ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _StorageUsageItem extends StatelessWidget {
  final int usedBytes;
  final int maxMb;
  final KrypticColors colors;

  const _StorageUsageItem({
    required this.usedBytes,
    required this.maxMb,
    required this.colors,
  });

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final maxBytes = maxMb * 1024 * 1024;
    final progress = maxBytes > 0
        ? (usedBytes / maxBytes).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.cloud_outlined, size: 20, color: colors.secondaryText),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.storage,
                      style: TextStyle(color: colors.primaryText, fontSize: 16),
                    ),
                    Text(
                      '${_formatSize(usedBytes)} / $maxMb MB',
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: colors.inputBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress > 0.9 ? colors.errorColor : colors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
