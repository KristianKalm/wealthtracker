import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/Salary.dart';
import 'drift/database.dart';

class SalaryRepository {
  final WealthtrackerDatabase _db;

  SalaryRepository(this._db);

  static int _nowEpochSeconds() =>
      DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  Future<void> save(Salary item, {bool fromSync = false}) async {
    final ua = fromSync ? item.updatedAt : _nowEpochSeconds();
    if (!fromSync) item.updatedAt = ua;
    await _db.into(_db.salaryEntries).insertOnConflictUpdate(
          SalaryEntriesCompanion(
            id: Value(item.id),
            yearMonth: Value(item.yearMonth),
            netSalary: Value(item.netSalary),
            grossSalary: Value(item.grossSalary),
            bonusNet: Value(item.bonusNet),
            position: Value(item.position),
            comment: Value(item.comment),
            updatedAt: Value(ua),
            syncedAt: Value(fromSync ? ua : null),
          ),
        );
  }

  Future<Salary?> load(String id) async {
    final row = await (_db.select(_db.salaryEntries)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _fromRow(row);
  }

  Future<List<Salary>> loadAll() async {
    final rows = await _db.select(_db.salaryEntries).get();
    return rows.map(_fromRow).toList();
  }

  Future<Salary?> loadByMonth(int yearMonth) async {
    final row = await (_db.select(_db.salaryEntries)
          ..where((t) => t.yearMonth.equals(yearMonth))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return _fromRow(row);
  }

  Future<String?> loadString(String id) async {
    final salary = await load(id);
    if (salary == null) return null;
    return jsonEncode(salary.toJson());
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.salaryEntries)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clear() async {
    await _db.delete(_db.salaryEntries).go();
  }

  Future<List<Salary>> loadUnsynced() async {
    final query = _db.select(_db.salaryEntries)
      ..where((t) => t.syncedAt.isNull() |
          (t.updatedAt.isNotNull() & t.updatedAt.isBiggerThan(t.syncedAt)));
    final rows = await query.get();
    return rows.map(_fromRow).toList();
  }

  Future<void> markSynced(String id) async {
    final now = _nowEpochSeconds();
    await (_db.update(_db.salaryEntries)..where((t) => t.id.equals(id)))
        .write(SalaryEntriesCompanion(syncedAt: Value(now)));
  }

  Future<void> stampUnstamped() async {
    final now = _nowEpochSeconds();
    await (_db.update(_db.salaryEntries)
          ..where((t) => t.updatedAt.isNull()))
        .write(SalaryEntriesCompanion(updatedAt: Value(now)));
  }

  Salary _fromRow(SalaryEntry row) {
    return Salary(
      id: row.id,
      yearMonth: row.yearMonth,
      netSalary: row.netSalary,
      grossSalary: row.grossSalary,
      bonusNet: row.bonusNet,
      position: row.position,
      comment: row.comment,
      updatedAt: row.updatedAt,
    );
  }
}
