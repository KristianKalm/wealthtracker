
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wealthtracker/core/db/WealthtrackerRepository.dart';

import 'package:kryptic_core/kryptic_core.dart';
import '../core/api_config.dart';
import '../core/prefs/WealthtrackerPrefs.dart';

final wealthtrackerPrefsProvider = Provider((ref) => WealthtrackerPrefs());
final biometricServiceProvider = Provider((ref) => KrypticBiometricService(localizedReason: 'Unlock Wealthtracker'));

final _migrationStrategy = MigrationStrategy(
  onCreate: (m) => m.createAll(),
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      await m.database.customStatement('ALTER TABLE comment_entries ADD COLUMN salary REAL');
      await m.database.customStatement('ALTER TABLE comment_entries ADD COLUMN bonus REAL');
      await m.database.customStatement('ALTER TABLE comment_entries ADD COLUMN position TEXT');
      await m.database.customStatement('ALTER TABLE comment_entries ADD COLUMN company TEXT');
      await m.database.customStatement('ALTER TABLE comment_entries ADD COLUMN salary_comment TEXT');
    }
  },
);

final wealthtrackerRepositoryProvider = FutureProvider((ref) async {
  final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
  return WealthtrackerRepository.initBox(wealthtrackerPrefs, _migrationStrategy);
});

final wealthtrackerSessionApiProvider = FutureProvider((ref) async {
  final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
  String? serverUrl = await wealthtrackerPrefs.get(PREFS_SERVER);
  if (serverUrl == null || serverUrl.isEmpty) return null;
  String username = await wealthtrackerPrefs.get(PREFS_USER) ?? "";
  String token = await wealthtrackerPrefs.get(PREFS_TOKEN) ?? "";
  return KrypticSessionApi(serverUrl, username, token, wealthtrackerApiConfig);
});

final wealthtrackerSyncProvider = FutureProvider((ref) async {
  final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
  String? serverUrl = await wealthtrackerPrefs.get(PREFS_SERVER);
  if (serverUrl == null || serverUrl.isEmpty) return null;
  String username = await wealthtrackerPrefs.get(PREFS_USER) ?? "";
  String token = await wealthtrackerPrefs.get(PREFS_TOKEN) ?? "";
  return KrypticSyncApi(serverUrl, username, token, wealthtrackerApiConfig);
});


final pgpProvider = FutureProvider((ref) async {
  final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
  String public = await wealthtrackerPrefs.get(PREFS_PUBLIC_KEY) ?? "";
  String private = await wealthtrackerPrefs.get(PREFS_PRIVATE_KEY) ?? "";
  String seed = await wealthtrackerPrefs.get(PREFS_SEED) ?? "";
  return KrypticPgpEncryption(privateKey: private, publicKey: public, passphrase: seed);;
});
