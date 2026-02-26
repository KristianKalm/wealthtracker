import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/MyConf.dart';
import 'drift/database.dart';

class ConfRepository {
  final WealthtrackerDatabase _db;

  ConfRepository(this._db);

  static int _nowEpochSeconds() =>
      DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  Future<void> save(MyConf conf, {bool fromSync = false}) async {
    final ua = fromSync ? conf.updatedAt : _nowEpochSeconds();
    if (!fromSync) conf.updatedAt = ua;
    await _db.into(_db.myConfEntries).insertOnConflictUpdate(
          MyConfEntriesCompanion(
            id: const Value('my_config'),
            jsonData: Value(jsonEncode(conf.toJson())),
            updatedAt: Value(ua),
            syncedAt: Value(fromSync ? ua : null),
          ),
        );
  }

  Future<MyConf> load() async {
    final row = await (_db.select(_db.myConfEntries)
          ..where((t) => t.id.equals('my_config')))
        .getSingleOrNull();
    if (row == null) return MyConf.empty();
    final typedJson = jsonDecode(row.jsonData) as Map<String, dynamic>;
    final conf = MyConf.fromJson(typedJson);
    conf.updatedAt = row.updatedAt;
    return conf;
  }

  Future<String> loadString() async {
    final conf = await load();
    return jsonEncode(conf.toJson());
  }

  Future<bool> isUnsynced() async {
    final row = await (_db.select(_db.myConfEntries)
          ..where((t) => t.id.equals('my_config')))
        .getSingleOrNull();
    if (row == null) return false;
    if (row.syncedAt == null) return true;
    if (row.updatedAt == null) return false;
    return row.updatedAt! > row.syncedAt!;
  }

  Future<void> markSynced() async {
    final now = _nowEpochSeconds();
    await (_db.update(_db.myConfEntries)
          ..where((t) => t.id.equals('my_config')))
        .write(MyConfEntriesCompanion(syncedAt: Value(now)));
  }

  Future<void> clear() async {
    await _db.delete(_db.myConfEntries).go();
  }

  Future<void> stampUnstamped() async {
    final now = _nowEpochSeconds();
    await (_db.update(_db.myConfEntries)
          ..where((t) => t.updatedAt.isNull()))
        .write(MyConfEntriesCompanion(updatedAt: Value(now)));
  }
}
