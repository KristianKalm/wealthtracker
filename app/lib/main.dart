import 'package:flutter/material.dart';

//import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kryptic_core/kryptic_core.dart';
import 'package:kryptic_core/gen_l10n/core_localizations.dart';
import 'core/login_screen_factory.dart';
import 'core/prefs/WealthtrackerPrefs.dart';
import 'features/Providers.dart';
import 'features/asset/AssetListScreen.dart';
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
  final _prefs = WealthtrackerPrefs();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final KrypticLockService _lockService;

  @override
  void initState() {
    super.initState();
    _lockService = KrypticLockService(
      prefs: _prefs,
      biometricService: KrypticBiometricService(localizedReason: 'Unlock Wealthtracker'),
      onChanged: () { if (mounted) setState(() {}); },
    );
    WidgetsBinding.instance.addObserver(this);
    ref.read(globalNotifierProvider.notifier).loadTheme();
    ref.read(localeNotifierProvider.notifier).loadLocale();
    _lockService.checkOnStart();
    onUnauthorized = _handleUnauthorized;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    onUnauthorized = null;
    super.dispose();
  }

  void _handleUnauthorized() {
    _prefs.delete(PREFS_TOKEN);
    _prefs.delete(PREFS_HAS_SIGNED_IN);
    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => makeLoginScreen(ref, isFirstTime: true)),
      (_) => false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lockService.onAppLifecycleChanged(state);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(globalNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);

    return KrypticCore(
      localeOptions: const [(Locale('en'), 'English'), (Locale('et'), 'Eesti')],
      localeProvider: localeNotifierProvider,
      setLocale: (locale) => ref.read(localeNotifierProvider.notifier).setLocale(locale),
      child: MaterialApp(
        title: 'Wealthtracker',
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          CoreLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: KrypticTheme.lightTheme(),
        darkTheme: KrypticTheme.darkTheme(),
        themeMode: themeMode,
        home: SplashScreen(
          prefs: _prefs,
          onInit: (ref) async {
            await ref.read(wealthtrackerRepositoryProvider.future);
          },
          homeScreen: const AssetListScreen(),
          loginScreen: makeLoginScreen(ref, isFirstTime: true),
        ),
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              if (_lockService.isLocked)
                Positioned.fill(
                  child: KrypticLockScreen(
                    pinEnabled: _lockService.pinEnabled,
                    biometricEnabled: _lockService.biometricEnabled,
                    onPinVerify: _lockService.verifyPin,
                    onBiometricTap: _lockService.authenticateBiometric,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
