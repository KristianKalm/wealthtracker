import 'dart:io';

import 'package:drift/drift.dart';
import 'package:kryptic_core/kryptic_core.dart' as connection;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [MyConfEntries, AssetEntries, CommentEntries, SalaryEntries])
class WealthtrackerDatabase extends _$WealthtrackerDatabase {
  WealthtrackerDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(salaryEntries);
      if (from < 3) await m.addColumn(salaryEntries, salaryEntries.bonusNet);
    },
  );

  static Future<WealthtrackerDatabase> create(String? encryptionKey) async {
    final executor = await connection.createDatabaseConnection(encryptionKey, dbName: 'wealthtracker');
    final db = WealthtrackerDatabase(executor);

    try {
      // Force connection open to detect incompatible/corrupt database files early
      await db.customSelect('SELECT 1').get();
    } catch (_) {
      // File is not a valid database (e.g. old unencrypted file opened with encryption key).
      // Delete it and let Drift create a fresh database.
      try { await db.close(); } catch (_) {}
      final file = await getDatabaseFile();
      if (await file.exists()) await file.delete();
      final freshExecutor = await connection.createDatabaseConnection(encryptionKey, dbName: 'wealthtracker');
      return WealthtrackerDatabase(freshExecutor);
    }

    return db;
  }

  static Future<File> getDatabaseFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, 'wealthtracker.db'));
  }
}
