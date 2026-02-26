import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/open.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

Future<QueryExecutor> createDatabaseConnection(String? encryptionKey, {String dbName = 'app'}) async {
  // Point sqlite3 to the SQLCipher library bundled by sqlcipher_flutter_libs
  open.overrideFor(OperatingSystem.android, openCipherOnAndroid);

  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, '$dbName.db'));

  return NativeDatabase(
    file,
    setup: encryptionKey != null
        ? (db) {
            db.execute("PRAGMA key = '$encryptionKey'");
          }
        : null,
  );
}
