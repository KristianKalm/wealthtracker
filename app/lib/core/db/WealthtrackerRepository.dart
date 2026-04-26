import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../prefs/WealthtrackerPrefs.dart';
import 'drift/database.dart';
import 'AssetRepository.dart';
import 'CommentRepository.dart';
import 'ConfRepository.dart';

const TABLE_ASSET = "asset";
const TABLE_MONTH = "comment";
const TABLE_CONF = "conf";


class WealthtrackerRepository {
  final WealthtrackerDatabase _db;
  final AssetRepository assets;
  final CommentRepository comments;
  final ConfRepository conf;

  WealthtrackerRepository(WealthtrackerDatabase db)
      : _db = db,
        assets = AssetRepository(db),
        comments = CommentRepository(db),
        conf = ConfRepository(db);

  static String generateId() {
    const chars =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rand = Random.secure();
    return List.generate(12, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  static Future<WealthtrackerRepository> initBox(WealthtrackerPrefs prefs, MigrationStrategy migrationStrategy) async {
    String? encryptionKey = await prefs.get("drift_encryption_key");
    if (encryptionKey == null) {
      final rand = Random.secure();
      final keyBytes = List.generate(32, (_) => rand.nextInt(256));
      encryptionKey = base64Encode(keyBytes);
      await prefs.set("drift_encryption_key", encryptionKey);
    }
    final db = await WealthtrackerDatabase.create(encryptionKey, migrationStrategy);
    return WealthtrackerRepository(db);
  }

  Future<void> clearAll() async {
    await assets.clear();
    await comments.clear();
    await conf.clear();
  }

  Future<void> deleteDatabase() async {
    if (kIsWeb) {
      await clearAll();
    } else {
      await _db.close();
      final file = await WealthtrackerDatabase.getDatabaseFile();
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> stampUnstampedEntities() async {
    await assets.stampUnstamped();
    await comments.stampUnstamped();
    await conf.stampUnstamped();
  }
}
