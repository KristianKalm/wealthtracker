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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 3) {
        await customStatement('DROP TABLE IF EXISTS asset_entries');
        await migrator.createTable(assetEntries);
      }
    },
  );

  static Future<WealthtrackerDatabase> create(String? encryptionKey) async {
    final executor = await connection.createDatabaseConnection(encryptionKey, dbName: 'wealthtracker');
    return WealthtrackerDatabase(executor);
  }

  static Future<File> getDatabaseFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, 'wealthtracker.db'));
  }
}
