import 'package:drift/drift.dart';

@DataClassName('MyConfEntry')
class MyConfEntries extends Table {
  TextColumn get id => text()();
  TextColumn get jsonData => text()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get syncedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AssetEntry')
class AssetEntries extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get tagIds => text().withDefault(const Constant('[]'))();
  TextColumn get groupId => text().nullable()();
  TextColumn get monthlyValues => text().withDefault(const Constant('{}'))();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get syncedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CommentEntry')
class CommentEntries extends Table {
  TextColumn get id => text()();
  IntColumn get yearMonth => integer()();
  TextColumn get comment => text().withDefault(const Constant(''))();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get syncedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SalaryEntry')
class SalaryEntries extends Table {
  TextColumn get id => text()();
  IntColumn get yearMonth => integer()();
  RealColumn get netSalary => real().nullable()();
  RealColumn get grossSalary => real().nullable()();
  RealColumn get bonusNet => real().nullable()();
  TextColumn get position => text().nullable()();
  TextColumn get company => text().nullable()();
  TextColumn get comment => text().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get syncedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
