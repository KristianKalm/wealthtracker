// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MyConfEntriesTable extends MyConfEntries
    with TableInfo<$MyConfEntriesTable, MyConfEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MyConfEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonDataMeta = const VerificationMeta(
    'jsonData',
  );
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
    'json_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, jsonData, updatedAt, syncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'my_conf_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MyConfEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json_data')) {
      context.handle(
        _jsonDataMeta,
        jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MyConfEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MyConfEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jsonData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_data'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $MyConfEntriesTable createAlias(String alias) {
    return $MyConfEntriesTable(attachedDatabase, alias);
  }
}

class MyConfEntry extends DataClass implements Insertable<MyConfEntry> {
  final String id;
  final String jsonData;
  final int? updatedAt;
  final int? syncedAt;
  const MyConfEntry({
    required this.id,
    required this.jsonData,
    this.updatedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json_data'] = Variable<String>(jsonData);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    return map;
  }

  MyConfEntriesCompanion toCompanion(bool nullToAbsent) {
    return MyConfEntriesCompanion(
      id: Value(id),
      jsonData: Value(jsonData),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory MyConfEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MyConfEntry(
      id: serializer.fromJson<String>(json['id']),
      jsonData: serializer.fromJson<String>(json['jsonData']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jsonData': serializer.toJson<String>(jsonData),
      'updatedAt': serializer.toJson<int?>(updatedAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
    };
  }

  MyConfEntry copyWith({
    String? id,
    String? jsonData,
    Value<int?> updatedAt = const Value.absent(),
    Value<int?> syncedAt = const Value.absent(),
  }) => MyConfEntry(
    id: id ?? this.id,
    jsonData: jsonData ?? this.jsonData,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  MyConfEntry copyWithCompanion(MyConfEntriesCompanion data) {
    return MyConfEntry(
      id: data.id.present ? data.id.value : this.id,
      jsonData: data.jsonData.present ? data.jsonData.value : this.jsonData,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MyConfEntry(')
          ..write('id: $id, ')
          ..write('jsonData: $jsonData, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, jsonData, updatedAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MyConfEntry &&
          other.id == this.id &&
          other.jsonData == this.jsonData &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class MyConfEntriesCompanion extends UpdateCompanion<MyConfEntry> {
  final Value<String> id;
  final Value<String> jsonData;
  final Value<int?> updatedAt;
  final Value<int?> syncedAt;
  final Value<int> rowid;
  const MyConfEntriesCompanion({
    this.id = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MyConfEntriesCompanion.insert({
    required String id,
    required String jsonData,
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       jsonData = Value(jsonData);
  static Insertable<MyConfEntry> custom({
    Expression<String>? id,
    Expression<String>? jsonData,
    Expression<int>? updatedAt,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jsonData != null) 'json_data': jsonData,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MyConfEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? jsonData,
    Value<int?>? updatedAt,
    Value<int?>? syncedAt,
    Value<int>? rowid,
  }) {
    return MyConfEntriesCompanion(
      id: id ?? this.id,
      jsonData: jsonData ?? this.jsonData,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jsonData.present) {
      map['json_data'] = Variable<String>(jsonData.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MyConfEntriesCompanion(')
          ..write('id: $id, ')
          ..write('jsonData: $jsonData, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetEntriesTable extends AssetEntries
    with TableInfo<$AssetEntriesTable, AssetEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagIdsMeta = const VerificationMeta('tagIds');
  @override
  late final GeneratedColumn<String> tagIds = GeneratedColumn<String>(
    'tag_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthlyValuesMeta = const VerificationMeta(
    'monthlyValues',
  );
  @override
  late final GeneratedColumn<String> monthlyValues = GeneratedColumn<String>(
    'monthly_values',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    tagIds,
    groupId,
    monthlyValues,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('tag_ids')) {
      context.handle(
        _tagIdsMeta,
        tagIds.isAcceptableOrUnknown(data['tag_ids']!, _tagIdsMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('monthly_values')) {
      context.handle(
        _monthlyValuesMeta,
        monthlyValues.isAcceptableOrUnknown(
          data['monthly_values']!,
          _monthlyValuesMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      tagIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_ids'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      monthlyValues: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}monthly_values'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $AssetEntriesTable createAlias(String alias) {
    return $AssetEntriesTable(attachedDatabase, alias);
  }
}

class AssetEntry extends DataClass implements Insertable<AssetEntry> {
  final String id;
  final String name;
  final String tagIds;
  final String? groupId;
  final String monthlyValues;
  final int? updatedAt;
  final int? syncedAt;
  const AssetEntry({
    required this.id,
    required this.name,
    required this.tagIds,
    this.groupId,
    required this.monthlyValues,
    this.updatedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['tag_ids'] = Variable<String>(tagIds);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['monthly_values'] = Variable<String>(monthlyValues);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    return map;
  }

  AssetEntriesCompanion toCompanion(bool nullToAbsent) {
    return AssetEntriesCompanion(
      id: Value(id),
      name: Value(name),
      tagIds: Value(tagIds),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      monthlyValues: Value(monthlyValues),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory AssetEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      tagIds: serializer.fromJson<String>(json['tagIds']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      monthlyValues: serializer.fromJson<String>(json['monthlyValues']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'tagIds': serializer.toJson<String>(tagIds),
      'groupId': serializer.toJson<String?>(groupId),
      'monthlyValues': serializer.toJson<String>(monthlyValues),
      'updatedAt': serializer.toJson<int?>(updatedAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
    };
  }

  AssetEntry copyWith({
    String? id,
    String? name,
    String? tagIds,
    Value<String?> groupId = const Value.absent(),
    String? monthlyValues,
    Value<int?> updatedAt = const Value.absent(),
    Value<int?> syncedAt = const Value.absent(),
  }) => AssetEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    tagIds: tagIds ?? this.tagIds,
    groupId: groupId.present ? groupId.value : this.groupId,
    monthlyValues: monthlyValues ?? this.monthlyValues,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  AssetEntry copyWithCompanion(AssetEntriesCompanion data) {
    return AssetEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      tagIds: data.tagIds.present ? data.tagIds.value : this.tagIds,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      monthlyValues: data.monthlyValues.present
          ? data.monthlyValues.value
          : this.monthlyValues,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tagIds: $tagIds, ')
          ..write('groupId: $groupId, ')
          ..write('monthlyValues: $monthlyValues, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    tagIds,
    groupId,
    monthlyValues,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.tagIds == this.tagIds &&
          other.groupId == this.groupId &&
          other.monthlyValues == this.monthlyValues &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class AssetEntriesCompanion extends UpdateCompanion<AssetEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> tagIds;
  final Value<String?> groupId;
  final Value<String> monthlyValues;
  final Value<int?> updatedAt;
  final Value<int?> syncedAt;
  final Value<int> rowid;
  const AssetEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.tagIds = const Value.absent(),
    this.groupId = const Value.absent(),
    this.monthlyValues = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetEntriesCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.tagIds = const Value.absent(),
    this.groupId = const Value.absent(),
    this.monthlyValues = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<AssetEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? tagIds,
    Expression<String>? groupId,
    Expression<String>? monthlyValues,
    Expression<int>? updatedAt,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (tagIds != null) 'tag_ids': tagIds,
      if (groupId != null) 'group_id': groupId,
      if (monthlyValues != null) 'monthly_values': monthlyValues,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? tagIds,
    Value<String?>? groupId,
    Value<String>? monthlyValues,
    Value<int?>? updatedAt,
    Value<int?>? syncedAt,
    Value<int>? rowid,
  }) {
    return AssetEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      tagIds: tagIds ?? this.tagIds,
      groupId: groupId ?? this.groupId,
      monthlyValues: monthlyValues ?? this.monthlyValues,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tagIds.present) {
      map['tag_ids'] = Variable<String>(tagIds.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (monthlyValues.present) {
      map['monthly_values'] = Variable<String>(monthlyValues.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tagIds: $tagIds, ')
          ..write('groupId: $groupId, ')
          ..write('monthlyValues: $monthlyValues, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommentEntriesTable extends CommentEntries
    with TableInfo<$CommentEntriesTable, CommentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommentEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMonthMeta = const VerificationMeta(
    'yearMonth',
  );
  @override
  late final GeneratedColumn<int> yearMonth = GeneratedColumn<int>(
    'year_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _netSalaryMeta = const VerificationMeta(
    'netSalary',
  );
  @override
  late final GeneratedColumn<double> netSalary = GeneratedColumn<double>(
    'net_salary',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grossSalaryMeta = const VerificationMeta(
    'grossSalary',
  );
  @override
  late final GeneratedColumn<double> grossSalary = GeneratedColumn<double>(
    'gross_salary',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bonusNetMeta = const VerificationMeta(
    'bonusNet',
  );
  @override
  late final GeneratedColumn<double> bonusNet = GeneratedColumn<double>(
    'bonus_net',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salaryCommentMeta = const VerificationMeta(
    'salaryComment',
  );
  @override
  late final GeneratedColumn<String> salaryComment = GeneratedColumn<String>(
    'salary_comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    yearMonth,
    comment,
    updatedAt,
    syncedAt,
    netSalary,
    grossSalary,
    bonusNet,
    position,
    company,
    salaryComment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comment_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommentEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('year_month')) {
      context.handle(
        _yearMonthMeta,
        yearMonth.isAcceptableOrUnknown(data['year_month']!, _yearMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMonthMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('net_salary')) {
      context.handle(
        _netSalaryMeta,
        netSalary.isAcceptableOrUnknown(data['net_salary']!, _netSalaryMeta),
      );
    }
    if (data.containsKey('gross_salary')) {
      context.handle(
        _grossSalaryMeta,
        grossSalary.isAcceptableOrUnknown(
          data['gross_salary']!,
          _grossSalaryMeta,
        ),
      );
    }
    if (data.containsKey('bonus_net')) {
      context.handle(
        _bonusNetMeta,
        bonusNet.isAcceptableOrUnknown(data['bonus_net']!, _bonusNetMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('salary_comment')) {
      context.handle(
        _salaryCommentMeta,
        salaryComment.isAcceptableOrUnknown(
          data['salary_comment']!,
          _salaryCommentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommentEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      yearMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_month'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      ),
      netSalary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}net_salary'],
      ),
      grossSalary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gross_salary'],
      ),
      bonusNet: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bonus_net'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position'],
      ),
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      ),
      salaryComment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salary_comment'],
      ),
    );
  }

  @override
  $CommentEntriesTable createAlias(String alias) {
    return $CommentEntriesTable(attachedDatabase, alias);
  }
}

class CommentEntry extends DataClass implements Insertable<CommentEntry> {
  final String id;
  final int yearMonth;
  final String comment;
  final int? updatedAt;
  final int? syncedAt;
  final double? netSalary;
  final double? grossSalary;
  final double? bonusNet;
  final String? position;
  final String? company;
  final String? salaryComment;
  const CommentEntry({
    required this.id,
    required this.yearMonth,
    required this.comment,
    this.updatedAt,
    this.syncedAt,
    this.netSalary,
    this.grossSalary,
    this.bonusNet,
    this.position,
    this.company,
    this.salaryComment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['year_month'] = Variable<int>(yearMonth);
    map['comment'] = Variable<String>(comment);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(syncedAt);
    }
    if (!nullToAbsent || netSalary != null) {
      map['net_salary'] = Variable<double>(netSalary);
    }
    if (!nullToAbsent || grossSalary != null) {
      map['gross_salary'] = Variable<double>(grossSalary);
    }
    if (!nullToAbsent || bonusNet != null) {
      map['bonus_net'] = Variable<double>(bonusNet);
    }
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<String>(position);
    }
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    if (!nullToAbsent || salaryComment != null) {
      map['salary_comment'] = Variable<String>(salaryComment);
    }
    return map;
  }

  CommentEntriesCompanion toCompanion(bool nullToAbsent) {
    return CommentEntriesCompanion(
      id: Value(id),
      yearMonth: Value(yearMonth),
      comment: Value(comment),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      netSalary: netSalary == null && nullToAbsent
          ? const Value.absent()
          : Value(netSalary),
      grossSalary: grossSalary == null && nullToAbsent
          ? const Value.absent()
          : Value(grossSalary),
      bonusNet: bonusNet == null && nullToAbsent
          ? const Value.absent()
          : Value(bonusNet),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      salaryComment: salaryComment == null && nullToAbsent
          ? const Value.absent()
          : Value(salaryComment),
    );
  }

  factory CommentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommentEntry(
      id: serializer.fromJson<String>(json['id']),
      yearMonth: serializer.fromJson<int>(json['yearMonth']),
      comment: serializer.fromJson<String>(json['comment']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
      syncedAt: serializer.fromJson<int?>(json['syncedAt']),
      netSalary: serializer.fromJson<double?>(json['netSalary']),
      grossSalary: serializer.fromJson<double?>(json['grossSalary']),
      bonusNet: serializer.fromJson<double?>(json['bonusNet']),
      position: serializer.fromJson<String?>(json['position']),
      company: serializer.fromJson<String?>(json['company']),
      salaryComment: serializer.fromJson<String?>(json['salaryComment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'yearMonth': serializer.toJson<int>(yearMonth),
      'comment': serializer.toJson<String>(comment),
      'updatedAt': serializer.toJson<int?>(updatedAt),
      'syncedAt': serializer.toJson<int?>(syncedAt),
      'netSalary': serializer.toJson<double?>(netSalary),
      'grossSalary': serializer.toJson<double?>(grossSalary),
      'bonusNet': serializer.toJson<double?>(bonusNet),
      'position': serializer.toJson<String?>(position),
      'company': serializer.toJson<String?>(company),
      'salaryComment': serializer.toJson<String?>(salaryComment),
    };
  }

  CommentEntry copyWith({
    String? id,
    int? yearMonth,
    String? comment,
    Value<int?> updatedAt = const Value.absent(),
    Value<int?> syncedAt = const Value.absent(),
    Value<double?> netSalary = const Value.absent(),
    Value<double?> grossSalary = const Value.absent(),
    Value<double?> bonusNet = const Value.absent(),
    Value<String?> position = const Value.absent(),
    Value<String?> company = const Value.absent(),
    Value<String?> salaryComment = const Value.absent(),
  }) => CommentEntry(
    id: id ?? this.id,
    yearMonth: yearMonth ?? this.yearMonth,
    comment: comment ?? this.comment,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    netSalary: netSalary.present ? netSalary.value : this.netSalary,
    grossSalary: grossSalary.present ? grossSalary.value : this.grossSalary,
    bonusNet: bonusNet.present ? bonusNet.value : this.bonusNet,
    position: position.present ? position.value : this.position,
    company: company.present ? company.value : this.company,
    salaryComment: salaryComment.present
        ? salaryComment.value
        : this.salaryComment,
  );
  CommentEntry copyWithCompanion(CommentEntriesCompanion data) {
    return CommentEntry(
      id: data.id.present ? data.id.value : this.id,
      yearMonth: data.yearMonth.present ? data.yearMonth.value : this.yearMonth,
      comment: data.comment.present ? data.comment.value : this.comment,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      netSalary: data.netSalary.present ? data.netSalary.value : this.netSalary,
      grossSalary: data.grossSalary.present
          ? data.grossSalary.value
          : this.grossSalary,
      bonusNet: data.bonusNet.present ? data.bonusNet.value : this.bonusNet,
      position: data.position.present ? data.position.value : this.position,
      company: data.company.present ? data.company.value : this.company,
      salaryComment: data.salaryComment.present
          ? data.salaryComment.value
          : this.salaryComment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommentEntry(')
          ..write('id: $id, ')
          ..write('yearMonth: $yearMonth, ')
          ..write('comment: $comment, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('netSalary: $netSalary, ')
          ..write('grossSalary: $grossSalary, ')
          ..write('bonusNet: $bonusNet, ')
          ..write('position: $position, ')
          ..write('company: $company, ')
          ..write('salaryComment: $salaryComment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    yearMonth,
    comment,
    updatedAt,
    syncedAt,
    netSalary,
    grossSalary,
    bonusNet,
    position,
    company,
    salaryComment,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentEntry &&
          other.id == this.id &&
          other.yearMonth == this.yearMonth &&
          other.comment == this.comment &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt &&
          other.netSalary == this.netSalary &&
          other.grossSalary == this.grossSalary &&
          other.bonusNet == this.bonusNet &&
          other.position == this.position &&
          other.company == this.company &&
          other.salaryComment == this.salaryComment);
}

class CommentEntriesCompanion extends UpdateCompanion<CommentEntry> {
  final Value<String> id;
  final Value<int> yearMonth;
  final Value<String> comment;
  final Value<int?> updatedAt;
  final Value<int?> syncedAt;
  final Value<double?> netSalary;
  final Value<double?> grossSalary;
  final Value<double?> bonusNet;
  final Value<String?> position;
  final Value<String?> company;
  final Value<String?> salaryComment;
  final Value<int> rowid;
  const CommentEntriesCompanion({
    this.id = const Value.absent(),
    this.yearMonth = const Value.absent(),
    this.comment = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.netSalary = const Value.absent(),
    this.grossSalary = const Value.absent(),
    this.bonusNet = const Value.absent(),
    this.position = const Value.absent(),
    this.company = const Value.absent(),
    this.salaryComment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommentEntriesCompanion.insert({
    required String id,
    required int yearMonth,
    this.comment = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.netSalary = const Value.absent(),
    this.grossSalary = const Value.absent(),
    this.bonusNet = const Value.absent(),
    this.position = const Value.absent(),
    this.company = const Value.absent(),
    this.salaryComment = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       yearMonth = Value(yearMonth);
  static Insertable<CommentEntry> custom({
    Expression<String>? id,
    Expression<int>? yearMonth,
    Expression<String>? comment,
    Expression<int>? updatedAt,
    Expression<int>? syncedAt,
    Expression<double>? netSalary,
    Expression<double>? grossSalary,
    Expression<double>? bonusNet,
    Expression<String>? position,
    Expression<String>? company,
    Expression<String>? salaryComment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (yearMonth != null) 'year_month': yearMonth,
      if (comment != null) 'comment': comment,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (netSalary != null) 'net_salary': netSalary,
      if (grossSalary != null) 'gross_salary': grossSalary,
      if (bonusNet != null) 'bonus_net': bonusNet,
      if (position != null) 'position': position,
      if (company != null) 'company': company,
      if (salaryComment != null) 'salary_comment': salaryComment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommentEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? yearMonth,
    Value<String>? comment,
    Value<int?>? updatedAt,
    Value<int?>? syncedAt,
    Value<double?>? netSalary,
    Value<double?>? grossSalary,
    Value<double?>? bonusNet,
    Value<String?>? position,
    Value<String?>? company,
    Value<String?>? salaryComment,
    Value<int>? rowid,
  }) {
    return CommentEntriesCompanion(
      id: id ?? this.id,
      yearMonth: yearMonth ?? this.yearMonth,
      comment: comment ?? this.comment,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      netSalary: netSalary ?? this.netSalary,
      grossSalary: grossSalary ?? this.grossSalary,
      bonusNet: bonusNet ?? this.bonusNet,
      position: position ?? this.position,
      company: company ?? this.company,
      salaryComment: salaryComment ?? this.salaryComment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (yearMonth.present) {
      map['year_month'] = Variable<int>(yearMonth.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (netSalary.present) {
      map['net_salary'] = Variable<double>(netSalary.value);
    }
    if (grossSalary.present) {
      map['gross_salary'] = Variable<double>(grossSalary.value);
    }
    if (bonusNet.present) {
      map['bonus_net'] = Variable<double>(bonusNet.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (salaryComment.present) {
      map['salary_comment'] = Variable<String>(salaryComment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommentEntriesCompanion(')
          ..write('id: $id, ')
          ..write('yearMonth: $yearMonth, ')
          ..write('comment: $comment, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('netSalary: $netSalary, ')
          ..write('grossSalary: $grossSalary, ')
          ..write('bonusNet: $bonusNet, ')
          ..write('position: $position, ')
          ..write('company: $company, ')
          ..write('salaryComment: $salaryComment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$WealthtrackerDatabase extends GeneratedDatabase {
  _$WealthtrackerDatabase(QueryExecutor e) : super(e);
  $WealthtrackerDatabaseManager get managers =>
      $WealthtrackerDatabaseManager(this);
  late final $MyConfEntriesTable myConfEntries = $MyConfEntriesTable(this);
  late final $AssetEntriesTable assetEntries = $AssetEntriesTable(this);
  late final $CommentEntriesTable commentEntries = $CommentEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    myConfEntries,
    assetEntries,
    commentEntries,
  ];
}

typedef $$MyConfEntriesTableCreateCompanionBuilder =
    MyConfEntriesCompanion Function({
      required String id,
      required String jsonData,
      Value<int?> updatedAt,
      Value<int?> syncedAt,
      Value<int> rowid,
    });
typedef $$MyConfEntriesTableUpdateCompanionBuilder =
    MyConfEntriesCompanion Function({
      Value<String> id,
      Value<String> jsonData,
      Value<int?> updatedAt,
      Value<int?> syncedAt,
      Value<int> rowid,
    });

class $$MyConfEntriesTableFilterComposer
    extends Composer<_$WealthtrackerDatabase, $MyConfEntriesTable> {
  $$MyConfEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MyConfEntriesTableOrderingComposer
    extends Composer<_$WealthtrackerDatabase, $MyConfEntriesTable> {
  $$MyConfEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MyConfEntriesTableAnnotationComposer
    extends Composer<_$WealthtrackerDatabase, $MyConfEntriesTable> {
  $$MyConfEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jsonData =>
      $composableBuilder(column: $table.jsonData, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$MyConfEntriesTableTableManager
    extends
        RootTableManager<
          _$WealthtrackerDatabase,
          $MyConfEntriesTable,
          MyConfEntry,
          $$MyConfEntriesTableFilterComposer,
          $$MyConfEntriesTableOrderingComposer,
          $$MyConfEntriesTableAnnotationComposer,
          $$MyConfEntriesTableCreateCompanionBuilder,
          $$MyConfEntriesTableUpdateCompanionBuilder,
          (
            MyConfEntry,
            BaseReferences<
              _$WealthtrackerDatabase,
              $MyConfEntriesTable,
              MyConfEntry
            >,
          ),
          MyConfEntry,
          PrefetchHooks Function()
        > {
  $$MyConfEntriesTableTableManager(
    _$WealthtrackerDatabase db,
    $MyConfEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MyConfEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MyConfEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MyConfEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> jsonData = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MyConfEntriesCompanion(
                id: id,
                jsonData: jsonData,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String jsonData,
                Value<int?> updatedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MyConfEntriesCompanion.insert(
                id: id,
                jsonData: jsonData,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MyConfEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$WealthtrackerDatabase,
      $MyConfEntriesTable,
      MyConfEntry,
      $$MyConfEntriesTableFilterComposer,
      $$MyConfEntriesTableOrderingComposer,
      $$MyConfEntriesTableAnnotationComposer,
      $$MyConfEntriesTableCreateCompanionBuilder,
      $$MyConfEntriesTableUpdateCompanionBuilder,
      (
        MyConfEntry,
        BaseReferences<
          _$WealthtrackerDatabase,
          $MyConfEntriesTable,
          MyConfEntry
        >,
      ),
      MyConfEntry,
      PrefetchHooks Function()
    >;
typedef $$AssetEntriesTableCreateCompanionBuilder =
    AssetEntriesCompanion Function({
      required String id,
      Value<String> name,
      Value<String> tagIds,
      Value<String?> groupId,
      Value<String> monthlyValues,
      Value<int?> updatedAt,
      Value<int?> syncedAt,
      Value<int> rowid,
    });
typedef $$AssetEntriesTableUpdateCompanionBuilder =
    AssetEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> tagIds,
      Value<String?> groupId,
      Value<String> monthlyValues,
      Value<int?> updatedAt,
      Value<int?> syncedAt,
      Value<int> rowid,
    });

class $$AssetEntriesTableFilterComposer
    extends Composer<_$WealthtrackerDatabase, $AssetEntriesTable> {
  $$AssetEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagIds => $composableBuilder(
    column: $table.tagIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monthlyValues => $composableBuilder(
    column: $table.monthlyValues,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssetEntriesTableOrderingComposer
    extends Composer<_$WealthtrackerDatabase, $AssetEntriesTable> {
  $$AssetEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagIds => $composableBuilder(
    column: $table.tagIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monthlyValues => $composableBuilder(
    column: $table.monthlyValues,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetEntriesTableAnnotationComposer
    extends Composer<_$WealthtrackerDatabase, $AssetEntriesTable> {
  $$AssetEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get tagIds =>
      $composableBuilder(column: $table.tagIds, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get monthlyValues => $composableBuilder(
    column: $table.monthlyValues,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$AssetEntriesTableTableManager
    extends
        RootTableManager<
          _$WealthtrackerDatabase,
          $AssetEntriesTable,
          AssetEntry,
          $$AssetEntriesTableFilterComposer,
          $$AssetEntriesTableOrderingComposer,
          $$AssetEntriesTableAnnotationComposer,
          $$AssetEntriesTableCreateCompanionBuilder,
          $$AssetEntriesTableUpdateCompanionBuilder,
          (
            AssetEntry,
            BaseReferences<
              _$WealthtrackerDatabase,
              $AssetEntriesTable,
              AssetEntry
            >,
          ),
          AssetEntry,
          PrefetchHooks Function()
        > {
  $$AssetEntriesTableTableManager(
    _$WealthtrackerDatabase db,
    $AssetEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> tagIds = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String> monthlyValues = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetEntriesCompanion(
                id: id,
                name: name,
                tagIds: tagIds,
                groupId: groupId,
                monthlyValues: monthlyValues,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> name = const Value.absent(),
                Value<String> tagIds = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String> monthlyValues = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetEntriesCompanion.insert(
                id: id,
                name: name,
                tagIds: tagIds,
                groupId: groupId,
                monthlyValues: monthlyValues,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssetEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$WealthtrackerDatabase,
      $AssetEntriesTable,
      AssetEntry,
      $$AssetEntriesTableFilterComposer,
      $$AssetEntriesTableOrderingComposer,
      $$AssetEntriesTableAnnotationComposer,
      $$AssetEntriesTableCreateCompanionBuilder,
      $$AssetEntriesTableUpdateCompanionBuilder,
      (
        AssetEntry,
        BaseReferences<_$WealthtrackerDatabase, $AssetEntriesTable, AssetEntry>,
      ),
      AssetEntry,
      PrefetchHooks Function()
    >;
typedef $$CommentEntriesTableCreateCompanionBuilder =
    CommentEntriesCompanion Function({
      required String id,
      required int yearMonth,
      Value<String> comment,
      Value<int?> updatedAt,
      Value<int?> syncedAt,
      Value<double?> netSalary,
      Value<double?> grossSalary,
      Value<double?> bonusNet,
      Value<String?> position,
      Value<String?> company,
      Value<String?> salaryComment,
      Value<int> rowid,
    });
typedef $$CommentEntriesTableUpdateCompanionBuilder =
    CommentEntriesCompanion Function({
      Value<String> id,
      Value<int> yearMonth,
      Value<String> comment,
      Value<int?> updatedAt,
      Value<int?> syncedAt,
      Value<double?> netSalary,
      Value<double?> grossSalary,
      Value<double?> bonusNet,
      Value<String?> position,
      Value<String?> company,
      Value<String?> salaryComment,
      Value<int> rowid,
    });

class $$CommentEntriesTableFilterComposer
    extends Composer<_$WealthtrackerDatabase, $CommentEntriesTable> {
  $$CommentEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearMonth => $composableBuilder(
    column: $table.yearMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get netSalary => $composableBuilder(
    column: $table.netSalary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grossSalary => $composableBuilder(
    column: $table.grossSalary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bonusNet => $composableBuilder(
    column: $table.bonusNet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salaryComment => $composableBuilder(
    column: $table.salaryComment,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CommentEntriesTableOrderingComposer
    extends Composer<_$WealthtrackerDatabase, $CommentEntriesTable> {
  $$CommentEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearMonth => $composableBuilder(
    column: $table.yearMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get netSalary => $composableBuilder(
    column: $table.netSalary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grossSalary => $composableBuilder(
    column: $table.grossSalary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bonusNet => $composableBuilder(
    column: $table.bonusNet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salaryComment => $composableBuilder(
    column: $table.salaryComment,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CommentEntriesTableAnnotationComposer
    extends Composer<_$WealthtrackerDatabase, $CommentEntriesTable> {
  $$CommentEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get yearMonth =>
      $composableBuilder(column: $table.yearMonth, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<double> get netSalary =>
      $composableBuilder(column: $table.netSalary, builder: (column) => column);

  GeneratedColumn<double> get grossSalary => $composableBuilder(
    column: $table.grossSalary,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bonusNet =>
      $composableBuilder(column: $table.bonusNet, builder: (column) => column);

  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get salaryComment => $composableBuilder(
    column: $table.salaryComment,
    builder: (column) => column,
  );
}

class $$CommentEntriesTableTableManager
    extends
        RootTableManager<
          _$WealthtrackerDatabase,
          $CommentEntriesTable,
          CommentEntry,
          $$CommentEntriesTableFilterComposer,
          $$CommentEntriesTableOrderingComposer,
          $$CommentEntriesTableAnnotationComposer,
          $$CommentEntriesTableCreateCompanionBuilder,
          $$CommentEntriesTableUpdateCompanionBuilder,
          (
            CommentEntry,
            BaseReferences<
              _$WealthtrackerDatabase,
              $CommentEntriesTable,
              CommentEntry
            >,
          ),
          CommentEntry,
          PrefetchHooks Function()
        > {
  $$CommentEntriesTableTableManager(
    _$WealthtrackerDatabase db,
    $CommentEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommentEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommentEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommentEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> yearMonth = const Value.absent(),
                Value<String> comment = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<double?> netSalary = const Value.absent(),
                Value<double?> grossSalary = const Value.absent(),
                Value<double?> bonusNet = const Value.absent(),
                Value<String?> position = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> salaryComment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommentEntriesCompanion(
                id: id,
                yearMonth: yearMonth,
                comment: comment,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                netSalary: netSalary,
                grossSalary: grossSalary,
                bonusNet: bonusNet,
                position: position,
                company: company,
                salaryComment: salaryComment,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int yearMonth,
                Value<String> comment = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int?> syncedAt = const Value.absent(),
                Value<double?> netSalary = const Value.absent(),
                Value<double?> grossSalary = const Value.absent(),
                Value<double?> bonusNet = const Value.absent(),
                Value<String?> position = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> salaryComment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommentEntriesCompanion.insert(
                id: id,
                yearMonth: yearMonth,
                comment: comment,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                netSalary: netSalary,
                grossSalary: grossSalary,
                bonusNet: bonusNet,
                position: position,
                company: company,
                salaryComment: salaryComment,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CommentEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$WealthtrackerDatabase,
      $CommentEntriesTable,
      CommentEntry,
      $$CommentEntriesTableFilterComposer,
      $$CommentEntriesTableOrderingComposer,
      $$CommentEntriesTableAnnotationComposer,
      $$CommentEntriesTableCreateCompanionBuilder,
      $$CommentEntriesTableUpdateCompanionBuilder,
      (
        CommentEntry,
        BaseReferences<
          _$WealthtrackerDatabase,
          $CommentEntriesTable,
          CommentEntry
        >,
      ),
      CommentEntry,
      PrefetchHooks Function()
    >;

class $WealthtrackerDatabaseManager {
  final _$WealthtrackerDatabase _db;
  $WealthtrackerDatabaseManager(this._db);
  $$MyConfEntriesTableTableManager get myConfEntries =>
      $$MyConfEntriesTableTableManager(_db, _db.myConfEntries);
  $$AssetEntriesTableTableManager get assetEntries =>
      $$AssetEntriesTableTableManager(_db, _db.assetEntries);
  $$CommentEntriesTableTableManager get commentEntries =>
      $$CommentEntriesTableTableManager(_db, _db.commentEntries);
}
