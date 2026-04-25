import 'dart:io';

import 'package:drift/drift.dart';
import 'package:kryptic_core/kryptic_core.dart' as connection;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [MyConfEntries, AssetEntries, CommentEntries])
class WealthtrackerDatabase extends _$WealthtrackerDatabase {
  WealthtrackerDatabase(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.database.customStatement('''
          CREATE TABLE IF NOT EXISTS salary_entries (
            id TEXT NOT NULL PRIMARY KEY,
            year_month INTEGER NOT NULL,
            net_salary REAL,
            gross_salary REAL,
            position TEXT,
            comment TEXT,
            updated_at INTEGER,
            synced_at INTEGER
          )
        ''');
      }
      if (from < 3) {
        await m.database.customStatement(
          'ALTER TABLE salary_entries ADD COLUMN bonus_net REAL',
        );
      }
      if (from < 4) {
        await m.database.customStatement(
          'ALTER TABLE salary_entries ADD COLUMN company TEXT',
        );
      }
      if (from < 5) {
        await m.addColumn(commentEntries, commentEntries.netSalary);
        await m.addColumn(commentEntries, commentEntries.grossSalary);
        await m.addColumn(commentEntries, commentEntries.bonusNet);
        await m.addColumn(commentEntries, commentEntries.position);
        await m.addColumn(commentEntries, commentEntries.company);
        await m.addColumn(commentEntries, commentEntries.salaryComment);
        // Migrate salary data: update existing comment rows, insert new ones
        await m.database.customStatement('''
          UPDATE comment_entries SET
            net_salary = (SELECT net_salary FROM salary_entries WHERE salary_entries.year_month = comment_entries.year_month),
            gross_salary = (SELECT gross_salary FROM salary_entries WHERE salary_entries.year_month = comment_entries.year_month),
            bonus_net = (SELECT bonus_net FROM salary_entries WHERE salary_entries.year_month = comment_entries.year_month),
            position = (SELECT position FROM salary_entries WHERE salary_entries.year_month = comment_entries.year_month),
            company = (SELECT company FROM salary_entries WHERE salary_entries.year_month = comment_entries.year_month),
            salary_comment = (SELECT comment FROM salary_entries WHERE salary_entries.year_month = comment_entries.year_month),
            synced_at = NULL
          WHERE EXISTS (SELECT 1 FROM salary_entries WHERE salary_entries.year_month = comment_entries.year_month)
        ''');
        await m.database.customStatement('''
          INSERT INTO comment_entries (id, year_month, comment, net_salary, gross_salary, bonus_net, position, company, salary_comment, updated_at, synced_at)
          SELECT id, year_month, '', net_salary, gross_salary, bonus_net, position, company, comment, updated_at, NULL
          FROM salary_entries
          WHERE year_month NOT IN (SELECT year_month FROM comment_entries)
        ''');
        await m.database.customStatement('DROP TABLE IF EXISTS salary_entries');
      }
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
