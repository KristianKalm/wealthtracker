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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => destructiveFallback;

  static Future<WealthtrackerDatabase> create(String? encryptionKey) async {
    final executor = await connection.createDatabaseConnection(encryptionKey, dbName: 'wealthtracker');
    return WealthtrackerDatabase(executor);
  }

  static Future<File> getDatabaseFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, 'wealthtracker.db'));
  }
}
