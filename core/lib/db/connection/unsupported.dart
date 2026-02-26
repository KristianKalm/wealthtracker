import 'package:drift/drift.dart';

Future<QueryExecutor> createDatabaseConnection(String? encryptionKey, {String dbName = 'app'}) {
  throw UnsupportedError(
    'No suitable database implementation found for this platform.',
  );
}
