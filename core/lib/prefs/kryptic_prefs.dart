import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String PREFS_SEED = "seed";
const String PREFS_TOKEN = "token";
const String PREFS_TOKEN_ID = "token_id";
const String PREFS_USER = "username";
const String PREFS_SERVER = "server";
const String PREFS_PRIVATE_KEY = "private_key";
const String PREFS_PUBLIC_KEY = "public_key";
const String PREFS_HAS_SIGNED_IN = "has_signed_in";
const String PREFS_BIOMETRIC_LOCK = "biometric_lock";
const String PREFS_PIN_CODE = "pin_code";

class KrypticPrefs {
  final _secureStorage = const FlutterSecureStorage();

  Future<String?> get(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    var value = await _secureStorage.read(key: key);
    if (value == null) return defaultValue;
    return value == "1";
  }

  Future<void> set(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<void> setBool(String key, bool value) async {
    await _secureStorage.write(key: key, value: value ? "1" : "0");
  }

  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }
}
