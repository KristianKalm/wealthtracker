import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/Month.dart';
import 'drift/database.dart';

class CommentRepository {
  final WealthtrackerDatabase _db;

  CommentRepository(this._db);

  static int _nowEpochSeconds() =>
      DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  Future<void> save(Month item, {bool fromSync = false}) async {
    final ua = fromSync ? item.updatedAt : _nowEpochSeconds();
    if (!fromSync) item.updatedAt = ua;
    await _db.into(_db.commentEntries).insertOnConflictUpdate(
          CommentEntriesCompanion(
            id: Value(item.id),
            yearMonth: Value(item.yearMonth),
            comment: Value(item.comment),
            updatedAt: Value(ua),
            syncedAt: Value(fromSync ? ua : null),
            salary: Value(item.salary),
            bonus: Value(item.bonus),
            position: Value(item.position),
            company: Value(item.company),
            salaryComment: Value(item.salaryComment),
          ),
        );
  }

  Future<Month?> load(String id) async {
    final row = await (_db.select(_db.commentEntries)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _fromRow(row);
  }

  Future<List<Month>> loadAll() async {
    final rows = await _db.select(_db.commentEntries).get();
    return rows.map(_fromRow).toList();
  }

  Future<Month?> loadByMonth(int yearMonth) async {
    final row = await (_db.select(_db.commentEntries)
          ..where((t) => t.yearMonth.equals(yearMonth))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return _fromRow(row);
  }

  Future<String?> loadString(String id) async {
    final comment = await load(id);
    if (comment == null) return null;
    return jsonEncode(comment.toJson());
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.commentEntries)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clear() async {
    await _db.delete(_db.commentEntries).go();
  }

  Future<List<Month>> loadUnsynced() async {
    final query = _db.select(_db.commentEntries)
      ..where((t) => t.syncedAt.isNull() |
          (t.updatedAt.isNotNull() & t.updatedAt.isBiggerThan(t.syncedAt)));
    final rows = await query.get();
    return rows.map(_fromRow).toList();
  }

  Future<void> markSynced(String id) async {
    final now = _nowEpochSeconds();
    await (_db.update(_db.commentEntries)..where((t) => t.id.equals(id)))
        .write(CommentEntriesCompanion(syncedAt: Value(now)));
  }

  Future<void> stampUnstamped() async {
    final now = _nowEpochSeconds();
    await (_db.update(_db.commentEntries)
          ..where((t) => t.updatedAt.isNull()))
        .write(CommentEntriesCompanion(updatedAt: Value(now)));
  }

  Month _fromRow(CommentEntry row) {
    return Month(
      id: row.id,
      yearMonth: row.yearMonth,
      comment: row.comment,
      updatedAt: row.updatedAt,
      salary: row.salary,
      bonus: row.bonus,
      position: row.position,
      company: row.company,
      salaryComment: row.salaryComment,
    );
  }
}
