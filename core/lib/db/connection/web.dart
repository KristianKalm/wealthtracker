import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

Future<QueryExecutor> createDatabaseConnection(String? encryptionKey, {String dbName = 'app'}) async {
  final fs = await IndexedDbFileSystem.open(dbName: dbName);
  final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  sqlite3.registerVirtualFileSystem(fs, makeDefault: true);
  return WasmDatabase(sqlite3: sqlite3, path: '/$dbName.db');
}
