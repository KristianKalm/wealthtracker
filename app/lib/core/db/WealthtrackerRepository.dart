import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;

import '../prefs/WealthtrackerPrefs.dart';
import 'drift/database.dart';
import 'AssetRepository.dart';
import 'CommentRepository.dart';
import 'ConfRepository.dart';
import 'SalaryRepository.dart';

const TABLE_ASSET = "asset";
const TABLE_COMMENT = "comment";
const TABLE_CONF = "conf";
const TABLE_SALARY = "salary";


class WealthtrackerRepository {
  final WealthtrackerDatabase _db;
  final AssetRepository assets;
  final CommentRepository comments;
  final ConfRepository conf;
  final SalaryRepository salaries;

  WealthtrackerRepository(WealthtrackerDatabase db)
      : _db = db,
        assets = AssetRepository(db),
        comments = CommentRepository(db),
        conf = ConfRepository(db),
        salaries = SalaryRepository(db);

  static String generateId() {
    const chars =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rand = Random.secure();
    return List.generate(12, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  static Future<WealthtrackerRepository> initBox(WealthtrackerPrefs prefs) async {
    String? encryptionKey = await prefs.get("drift_encryption_key");
    if (encryptionKey == null) {
      final rand = Random.secure();
      final keyBytes = List.generate(32, (_) => rand.nextInt(256));
      encryptionKey = base64Encode(keyBytes);
      await prefs.set("drift_encryption_key", encryptionKey);
    }
    final db = await WealthtrackerDatabase.create(encryptionKey);
    return WealthtrackerRepository(db);
  }

  Future<void> clearAll() async {
    await assets.clear();
    await comments.clear();
    await conf.clear();
    await salaries.clear();
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
    await salaries.stampUnstamped();
  }
}
