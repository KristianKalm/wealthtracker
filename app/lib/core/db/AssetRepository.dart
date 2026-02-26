import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/Asset.dart';
import 'drift/database.dart';

class AssetRepository {
  final WealthtrackerDatabase _db;

  AssetRepository(this._db);

  static int _nowEpochSeconds() =>
      DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  Future<void> save(Asset item, {bool fromSync = false}) async {
    final ua = fromSync ? item.updatedAt : _nowEpochSeconds();
    if (!fromSync) item.updatedAt = ua;
    await _db.into(_db.assetEntries).insertOnConflictUpdate(
          AssetEntriesCompanion(
            id: Value(item.id),
            name: Value(item.name),
            tagIds: Value(jsonEncode(item.tagIds)),
            groupId: Value(item.groupId),
            monthlyValues: Value(jsonEncode(item.monthlyValues)),
            updatedAt: Value(ua),
            syncedAt: Value(fromSync ? ua : null),
          ),
        );
  }

  Future<Asset?> load(String id) async {
    final row = await (_db.select(_db.assetEntries)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _fromRow(row);
  }

  Future<List<Asset>> loadAll() async {
    final rows = await _db.select(_db.assetEntries).get();
    return rows.map(_fromRow).toList();
  }

  Future<Asset?> loadByName(String name) async {
    final row = await (_db.select(_db.assetEntries)
          ..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    if (row == null) return null;
    return _fromRow(row);
  }

  Future<String?> loadString(String id) async {
    final asset = await load(id);
    if (asset == null) return null;
    return jsonEncode(asset.toJson());
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.assetEntries)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clear() async {
    await _db.delete(_db.assetEntries).go();
  }

  Future<List<Asset>> loadUnsynced() async {
    final query = _db.select(_db.assetEntries)
      ..where((t) => t.syncedAt.isNull() |
          (t.updatedAt.isNotNull() & t.updatedAt.isBiggerThan(t.syncedAt)));
    final rows = await query.get();
    return rows.map(_fromRow).toList();
  }

  Future<void> markSynced(String id) async {
    final now = _nowEpochSeconds();
    await (_db.update(_db.assetEntries)..where((t) => t.id.equals(id)))
        .write(AssetEntriesCompanion(syncedAt: Value(now)));
  }

  Future<void> stampUnstamped() async {
    final now = _nowEpochSeconds();
    await (_db.update(_db.assetEntries)
          ..where((t) => t.updatedAt.isNull()))
        .write(AssetEntriesCompanion(updatedAt: Value(now)));
  }

  Asset _fromRow(AssetEntry row) {
    final mvRaw = jsonDecode(row.monthlyValues) as Map<String, dynamic>;
    final mv = mvRaw.map((k, v) => MapEntry(k, (v as num).toDouble()));
    return Asset(
      id: row.id,
      name: row.name,
      tagIds: (jsonDecode(row.tagIds) as List).cast<String>(),
      groupId: row.groupId,
      monthlyValues: mv,
      updatedAt: row.updatedAt,
    );
  }
}
