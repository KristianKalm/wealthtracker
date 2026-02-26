import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealthtracker/features/splash/SplashScreen.dart';

//import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kryptic_core/kryptic_core.dart';
import 'core/prefs/WealthtrackerPrefs.dart';
import 'features/settings/PinEntryWidget.dart';
import 'features/sync/LoginScreen.dart';
import 'l10n/l10n.dart';

class GlobalNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode value) {
    state = value;
    _saveTheme(value);
  }

  Future<void> _saveTheme(ThemeMode value) async {
    var prefs = WealthtrackerPrefs();
    await prefs.set("themeMode", value.name);
  }

  Future<void> loadTheme() async {
    var prefs = WealthtrackerPrefs();
    final value = await prefs.get("themeMode");
    switch (value) {
      case 'dark':
        state = ThemeMode.dark;
      case 'light':
        state = ThemeMode.light;
      default:
        state = ThemeMode.system;
    }
  }
}

final globalNotifierProvider = NotifierProvider<GlobalNotifier, ThemeMode>(GlobalNotifier.new);

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => const Locale('en');

  void setLocale(Locale? value) {
    state = value;
    _saveLocale(value);
  }

  Future<void> _saveLocale(Locale? value) async {
    var prefs = WealthtrackerPrefs();
    if (value == null) {
      await prefs.delete(PREFS_LOCALE);
    } else {
      await prefs.set(PREFS_LOCALE, value.languageCode);
    }
  }

  Future<void> loadLocale() async {
    var prefs = WealthtrackerPrefs();
    final code = await prefs.get(PREFS_LOCALE);
    state = Locale(code ?? 'en');
  }
}

final localeNotifierProvider = NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  runApp(ProviderScope(child: WealthtrackerApp()));
}


class WealthtrackerApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<WealthtrackerApp> createState() => _WealthtrackerApp();
}

class _WealthtrackerApp extends ConsumerState<WealthtrackerApp> with WidgetsBindingObserver {
  var prefs = WealthtrackerPrefs();
  final _biometricService = KrypticBiometricService(localizedReason: 'Unlock Wealthtracker');
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _isLocked = false;
  bool _checkingAuth = false;
  bool _pinEnabled = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(globalNotifierProvider.notifier).loadTheme();
    ref.read(localeNotifierProvider.notifier).loadLocale();
    _checkLockOnStart();
    onUnauthorized = _handleUnauthorized;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    onUnauthorized = null;
    super.dispose();
  }

  void _handleUnauthorized() {
    prefs.delete(PREFS_TOKEN);
    prefs.delete(PREFS_HAS_SIGNED_IN);
    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen(isFirstTime: true)),
      (_) => false,
    );
  }

  Future<void> _checkLockOnStart() async {
    final biometric = await prefs.getBool(PREFS_BIOMETRIC_LOCK);
    final pin = await prefs.get(PREFS_PIN_CODE);
    _biometricEnabled = biometric;
    _pinEnabled = pin != null;
    if ((_biometricEnabled || _pinEnabled) && mounted) {
      setState(() => _isLocked = true);
      if (_biometricEnabled && !_pinEnabled) {
        _authenticateBiometric();
      }
    }
  }

  Future<void> _refreshLockState() async {
    final biometric = await prefs.getBool(PREFS_BIOMETRIC_LOCK);
    final pin = await prefs.get(PREFS_PIN_CODE);
    _biometricEnabled = biometric;
    _pinEnabled = pin != null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lockIfEnabled();
    } else if (state == AppLifecycleState.resumed) {
      if (_isLocked && _biometricEnabled && !_pinEnabled) {
        _authenticateBiometric();
      }
      if (!_isLocked) {
        _refreshLockState();
      }
    }
  }

  void _lockIfEnabled() {
    if ((_biometricEnabled || _pinEnabled) && mounted && !_isLocked) {
      setState(() => _isLocked = true);
    }
  }

  void _unlockApp() {
    if (!mounted) return;
    setState(() => _isLocked = false);
  }

  Future<void> _authenticateBiometric() async {
    if (_checkingAuth) return;
    _checkingAuth = true;
    try {
      final success = await _biometricService.authenticate();
      if (success) _unlockApp();
    } catch (_) {
      // Auth cancelled or failed — stay locked
    } finally {
      _checkingAuth = false;
    }
  }

  Future<bool> _verifyPin(String pin) async {
    final storedPin = await prefs.get(PREFS_PIN_CODE);
    if (pin == storedPin) {
      _unlockApp();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(globalNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);

    return MaterialApp(
      title: 'Wealthtracker',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: KrypticTheme.lightTheme(),
      darkTheme: KrypticTheme.darkTheme(),
      themeMode: themeMode,
      home: SplashScreen(prefs: prefs),
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            if (_isLocked)
              Positioned.fill(
                child: _LockScreen(
                  pinEnabled: _pinEnabled,
                  biometricEnabled: _biometricEnabled,
                  onPinVerify: _verifyPin,
                  onBiometricTap: _authenticateBiometric,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LockScreen extends StatefulWidget {
  final bool pinEnabled;
  final bool biometricEnabled;
  final Future<bool> Function(String) onPinVerify;
  final VoidCallback onBiometricTap;

  const _LockScreen({
    required this.pinEnabled,
    required this.biometricEnabled,
    required this.onPinVerify,
    required this.onBiometricTap,
  });

  @override
  State<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<_LockScreen> {
  final _pinKey = GlobalKey<PinEntryWidgetState>();
  final _focusNode = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent || !widget.pinEnabled) return;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace) {
      _pinKey.currentState?.removeDigit();
    } else if (key.keyId >= LogicalKeyboardKey.digit0.keyId &&
        key.keyId <= LogicalKeyboardKey.digit9.keyId) {
      _pinKey.currentState?.addDigit(String.fromCharCode(key.keyId));
    } else if (key.keyId >= LogicalKeyboardKey.numpad0.keyId &&
        key.keyId <= LogicalKeyboardKey.numpad9.keyId) {
      _pinKey.currentState?.addDigit('${key.keyId - LogicalKeyboardKey.numpad0.keyId}');
    }
  }

  Future<void> _handlePinCompleted(String pin) async {
    final success = await widget.onPinVerify(pin);
    if (!success && mounted) {
      _pinKey.currentState?.clear();
      setState(() => _error = context.l10n.wrongPin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: Center(
        child: SizedBox(
          width: 400,
          child: widget.pinEnabled
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: PinEntryWidget(
                  key: _pinKey,
                  title: context.l10n.enterPin,
                  subtitle: _error,
                  onCompleted: _handlePinCompleted,
                  bottomAction: widget.biometricEnabled
                      ? TextButton.icon(
                          onPressed: widget.onBiometricTap,
                          icon: const Icon(Icons.fingerprint),
                          label: Text(context.l10n.useBiometrics),
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        )
                      : null,
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.appIsLocked,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextButton.icon(
                    onPressed: widget.onBiometricTap,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(context.l10n.unlock),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
        ),
      ),
    ),
    );
  }
}
