import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kryptic_core/kryptic_core.dart';

import '../../features/Providers.dart';
import '../db/WealthtrackerRepository.dart';
import '../models/Asset.dart';
import '../models/Comment.dart';
import '../models/MyConf.dart';
import '../prefs/WealthtrackerPrefs.dart';

const LAST_DOWNLOAD_TIME = "LAST_DOWNLOAD_TIME";
const LAST_UPLOAD_TIME = "LAST_UPLOAD_TIME";
const UPLOAD_BATCH_SIZE = 50;



final assetConfig = EntitySyncConfig<Asset, WealthtrackerRepository>(
  boxName: TABLE_ASSET,
  logName: "Asset",
  fromJson: (json) => Asset.fromJson(json),
  saveEntity: (box, entity, {bool fromSync = false}) =>
      box.assets.save(entity, fromSync: fromSync),
  loadEntityList: (box) => box.assets.loadAll(),
  loadEntity: (box, id) => box.assets.load(id),
  loadUnsynced: (box) => box.assets.loadUnsynced(),
  markSynced: (box, id) => box.assets.markSynced(id),
  deleteEntityById: (box, id) => box.assets.delete(id),
  getUpdatedAt: (e) => e.updatedAt,
);

final commentConfig = EntitySyncConfig<Comment, WealthtrackerRepository>(
  boxName: TABLE_COMMENT,
  logName: "Comment",
  fromJson: (json) => Comment.fromJson(json),
  saveEntity: (box, entity, {bool fromSync = false}) =>
      box.comments.save(entity, fromSync: fromSync),
  loadEntityList: (box) => box.comments.loadAll(),
  loadEntity: (box, id) => box.comments.load(id),
  loadUnsynced: (box) => box.comments.loadUnsynced(),
  markSynced: (box, id) => box.comments.markSynced(id),
  deleteEntityById: (box, id) => box.comments.delete(id),
  getUpdatedAt: (e) => e.updatedAt,
);

// MyConf uses specialized sync, not the generic EntitySyncConfig
// Kept for backup/restore compatibility
final myConfConfig = EntitySyncConfig<MyConf, WealthtrackerRepository>(
  boxName: TABLE_CONF,
  logName: "MyConf",
  fromJson: (json) => MyConf.fromJson(json),
  saveEntity: (box, entity, {bool fromSync = false}) =>
      box.conf.save(entity, fromSync: fromSync),
  loadEntityList: (box) async => [await box.conf.load()],
  loadEntity: (box, id) => box.conf.load(),
  loadUnsynced: (box) async {
    final unsynced = await box.conf.isUnsynced();
    if (unsynced) return [await box.conf.load()];
    return [];
  },
  markSynced: (box, id) => box.conf.markSynced(),
  deleteEntityById: (box, id) async {},
  getUpdatedAt: (e) => e.updatedAt,
);

// Generic download function
Future<void> downloadAndSaveEntityList<T>(
  WidgetRef ref,
  EntitySyncConfig<T, WealthtrackerRepository> entity, {
  int? newerThan,
}) async {
  try {
    final wealthtrackerRepository = await ref.read(wealthtrackerRepositoryProvider.future);
    final syncApi = await ref.read(wealthtrackerSyncProvider.future);
    if (syncApi == null) return;
    final pgp = await ref.read(pgpProvider.future);

    Logger.log("Download", entity.logName);

    // Use paginated API - fetch all files with their encrypted data
    final fileDataList = await syncApi.loadAllFiles(entity.boxName, newerThan: newerThan);

    for (var fileData in fileDataList) {
      try {
        // Empty file is a tombstone — delete locally if present
        if (fileData.data.isEmpty) {
          final localEntity = await entity.loadEntity(wealthtrackerRepository, fileData.name);
          if (localEntity != null) {
            await entity.deleteEntityById(wealthtrackerRepository, fileData.name);
          }
          continue;
        }

        // Decrypt the data that was already fetched
        var itemString = await pgp.decrypt(fileData.data);
        final itemEntity = entity.fromJson(jsonDecode(itemString));

        // Conflict resolution: only save if server is newer or either is null
        final itemId = (itemEntity as dynamic).id as String;
        final localEntity = await entity.loadEntity(wealthtrackerRepository, itemId);
        if (localEntity != null) {
          final localUa = entity.getUpdatedAt(localEntity);
          final serverUa = entity.getUpdatedAt(itemEntity);
          if (localUa != null && serverUa != null && serverUa < localUa) {
            continue; // local is newer, skip
          }
        }

        await entity.saveEntity(wealthtrackerRepository, itemEntity, fromSync: true);
      } catch (e, stack) {
        print('Error processing ${fileData.name}: $e $stack');
      }
    }
  } catch (e) {
    // Widget may have been disposed, silently handle
    print('downloadAndSaveEntityList error (widget may be disposed): $e');
  }
}

// Generic upload single entity function
Future<void> uploadEntity<T>(
  WidgetRef ref,
  EntitySyncConfig<T, WealthtrackerRepository> entity,
  String itemId,
) async {
  try {
    // Check if token exists before attempting upload
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    final token = await wealthtrackerPrefs.get(PREFS_TOKEN);
    if (token == null || token.isEmpty) {
      // Skip upload if no token is provided
      return;
    }

    final wealthtrackerRepository = await ref.read(wealthtrackerRepositoryProvider.future);
    final syncApi = await ref.read(wealthtrackerSyncProvider.future);
    if (syncApi == null) return;
    final pgp = await ref.read(pgpProvider.future);

    try {
      var itemEntity = await entity.loadEntity(wealthtrackerRepository, itemId);
      if (itemEntity != null) {
        var itemString = jsonEncode((itemEntity as dynamic).toJson());
        var encryptedData = await pgp.encrypt(itemString);
        final result = await syncApi.saveFiles(entity.boxName, [FileData(name: itemId, data: encryptedData)]);
        if (result['detail'] == 'success') {
          await entity.markSynced(wealthtrackerRepository, itemId);
          final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
          await wealthtrackerPrefs.set(LAST_UPLOAD_TIME, now.toString());
        }
      }
    } catch (e, stack) {
      print('Error: $e $stack');
    }
  } catch (e) {
    // Widget may have been disposed, silently handle
    print('uploadEntity error (widget may be disposed): $e');
  }
}

// Generic upload entity list function
Future<void> uploadEntityList<T>(
  WidgetRef ref,
  EntitySyncConfig<T, WealthtrackerRepository> entity,
) async {
  try {
    // Check if token exists before attempting upload
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    final token = await wealthtrackerPrefs.get(PREFS_TOKEN);
    if (token == null || token.isEmpty) {
      // Skip upload if no token is provided
      return;
    }

    final wealthtrackerRepository = await ref.read(wealthtrackerRepositoryProvider.future);
    final syncApi = await ref.read(wealthtrackerSyncProvider.future);
    if (syncApi == null) return;
    final pgp = await ref.read(pgpProvider.future);

    Logger.log("Upload", entity.logName);
    var itemList = await entity.loadEntityList(wealthtrackerRepository);
    List<FileData> files = [];
    for (final item in itemList) {
      try {
        final itemId = (item as dynamic).id as String;
        var itemEntity = await entity.loadEntity(wealthtrackerRepository, itemId);
        if (itemEntity != null) {
          var itemString = jsonEncode((itemEntity as dynamic).toJson());
          var encryptedData = await pgp.encrypt(itemString);
          files.add(FileData(name: itemId, data: encryptedData));
        }
      } catch (e, stack) {
        print('Error: $e $stack');
      }
    }
    for (var i = 0; i < files.length; i += UPLOAD_BATCH_SIZE) {
      final batch = files.sublist(i, i + UPLOAD_BATCH_SIZE > files.length ? files.length : i + UPLOAD_BATCH_SIZE);
      await syncApi.saveFiles(entity.boxName, batch);
    }
  } catch (e) {
    // Widget may have been disposed, silently handle
    print('uploadEntityList error (widget may be disposed): $e');
  }
}

Future<void> fullDownload(WidgetRef ref) async {
  await downloadAndSaveMyConf(ref);
  await downloadAndSaveEntityList(ref, assetConfig);
  await downloadAndSaveEntityList(ref, commentConfig);

  try {
    final wealthtrackerRepository = await ref.read(wealthtrackerRepositoryProvider.future);
    await wealthtrackerRepository.stampUnstampedEntities();

    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    await wealthtrackerPrefs.set(LAST_DOWNLOAD_TIME, now.toString());
  } catch (e) {
    print('fullDownload finalize error (widget may be disposed): $e');
  }
}

Future<void> downloadFrom(WidgetRef ref, int timestamp) async {
  await downloadAndSaveMyConf(ref);
  await downloadAndSaveEntityList(ref, assetConfig, newerThan: timestamp);
  await downloadAndSaveEntityList(ref, commentConfig, newerThan: timestamp);
}

Future<void> fullUpload(WidgetRef ref) async {
  await uploadMyConf(ref);
  await uploadEntityList(ref, assetConfig);
  await uploadEntityList(ref, commentConfig);
}

// Upload unsynced entities (where syncedAt is null or updatedAt > syncedAt)
Future<void> uploadUnsyncedEntityList<T>(
  WidgetRef ref,
  EntitySyncConfig<T, WealthtrackerRepository> entity,
) async {
  try {
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    final token = await wealthtrackerPrefs.get(PREFS_TOKEN);
    if (token == null || token.isEmpty) return;

    final wealthtrackerRepository = await ref.read(wealthtrackerRepositoryProvider.future);
    final syncApi = await ref.read(wealthtrackerSyncProvider.future);
    if (syncApi == null) return;
    final pgp = await ref.read(pgpProvider.future);

    Logger.log("Upload unsynced", entity.logName);
    var unsyncedItems = await entity.loadUnsynced(wealthtrackerRepository);
    List<FileData> files = [];
    List<String> itemIds = [];
    for (final item in unsyncedItems) {
      try {
        final itemId = (item as dynamic).id as String;
        var itemString = jsonEncode((item as dynamic).toJson());
        var encryptedData = await pgp.encrypt(itemString);
        files.add(FileData(name: itemId, data: encryptedData));
        itemIds.add(itemId);
      } catch (e, stack) {
        print('Error: $e $stack');
      }
    }
    for (var i = 0; i < files.length; i += UPLOAD_BATCH_SIZE) {
      final end = i + UPLOAD_BATCH_SIZE > files.length ? files.length : i + UPLOAD_BATCH_SIZE;
      final batch = files.sublist(i, end);
      final result = await syncApi.saveFiles(entity.boxName, batch);
      if (result['detail'] == 'success') {
        for (var j = i; j < end; j++) {
          await entity.markSynced(wealthtrackerRepository, itemIds[j]);
        }
      }
    }
  } catch (e) {
    print('uploadUnsyncedEntityList error (widget may be disposed): $e');
  }
}

Future<void> uploadUnsyncedMyConf(WidgetRef ref) async {
  try {
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    final token = await wealthtrackerPrefs.get(PREFS_TOKEN);
    if (token == null || token.isEmpty) return;

    final wealthtrackerRepository = await ref.read(wealthtrackerRepositoryProvider.future);
    final syncApi = await ref.read(wealthtrackerSyncProvider.future);
    if (syncApi == null) return;
    final pgp = await ref.read(pgpProvider.future);

    final unsynced = await wealthtrackerRepository.conf.isUnsynced();
    if (!unsynced) return;

    Logger.log("Upload unsynced", "MyConf");
    try {
      final conf = await wealthtrackerRepository.conf.load();
      final confString = jsonEncode(conf.toJson());
      var encryptedData = await pgp.encrypt(confString);
      final result = await syncApi.saveFiles(TABLE_CONF, [FileData(name: 'my_config', data: encryptedData)]);
      if (result['detail'] == 'success') {
        await wealthtrackerRepository.conf.markSynced();
      }
    } catch (e, stack) {
      print('Error uploading MyConf: $e $stack');
    }
  } catch (e) {
    print('uploadUnsyncedMyConf error (widget may be disposed): $e');
  }
}

Future<void> uploadUnsynced(WidgetRef ref) async {
  await uploadUnsyncedMyConf(ref);
  await uploadUnsyncedEntityList(ref, assetConfig);
  await uploadUnsyncedEntityList(ref, commentConfig);
}

// Convenience wrappers for specific entity types

Future<void> uploadAsset(WidgetRef ref, Asset item) =>
    uploadEntity(ref, assetConfig, item.id);

Future<void> uploadComment(WidgetRef ref, Comment item) =>
    uploadEntity(ref, commentConfig, item.id);

Future<void> uploadTombstone<T>(
  WidgetRef ref,
  EntitySyncConfig<T, WealthtrackerRepository> entity,
  String itemId,
) async {
  try {
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    final token = await wealthtrackerPrefs.get(PREFS_TOKEN);
    if (token == null || token.isEmpty) return;

    final syncApi = await ref.read(wealthtrackerSyncProvider.future);
    if (syncApi == null) return;

    await syncApi.saveFiles(entity.boxName, [FileData(name: itemId, data: '')]);
  } catch (e) {
    print('uploadTombstone error (widget may be disposed): $e');
  }
}

// MyConf sync - single object (not a list)
Future<void> downloadAndSaveMyConf(WidgetRef ref) async {
  try {
    final wealthtrackerRepository = await ref.read(wealthtrackerRepositoryProvider.future);
    final syncApi = await ref.read(wealthtrackerSyncProvider.future);
    if (syncApi == null) return;
    final pgp = await ref.read(pgpProvider.future);

    Logger.log("Download", "MyConf");
    try {
      var confString = await syncApi.loadData(TABLE_CONF, 'my_config', pgp);
      if (confString != null) {
        final serverConf = MyConf.fromJson(jsonDecode(confString));
        final localConf = await wealthtrackerRepository.conf.load();
        final localUa = localConf.updatedAt;
        final serverUa = serverConf.updatedAt;
        // Only save if server is newer or either is null
        if (localUa == null || serverUa == null || serverUa >= localUa) {
          await wealthtrackerRepository.conf.save(serverConf, fromSync: true);
        }
      }
    } catch (e, stack) {
      print('Error downloading MyConf: $e $stack');
    }
  } catch (e) {
    // Widget may have been disposed, silently handle
    print('downloadAndSaveMyConf error (widget may be disposed): $e');
  }
}

Future<void> uploadMyConf(WidgetRef ref) async {
  try {
    // Check if token exists before attempting upload
    final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
    final token = await wealthtrackerPrefs.get(PREFS_TOKEN);
    if (token == null || token.isEmpty) {
      // Skip upload if no token is provided
      return;
    }

    final wealthtrackerRepository = await ref.read(wealthtrackerRepositoryProvider.future);
    final syncApi = await ref.read(wealthtrackerSyncProvider.future);
    if (syncApi == null) return;
    final pgp = await ref.read(pgpProvider.future);

    Logger.log("Upload", "MyConf");
    try {
      final conf = await wealthtrackerRepository.conf.load();
      final confString = jsonEncode(conf.toJson());
      var encryptedData = await pgp.encrypt(confString);
      final result = await syncApi.saveFiles(TABLE_CONF, [FileData(name: 'my_config', data: encryptedData)]);
      if (result['detail'] == 'success') {
        await wealthtrackerRepository.conf.markSynced();
        final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        await wealthtrackerPrefs.set(LAST_UPLOAD_TIME, now.toString());
      }
    } catch (e, stack) {
      print('Error uploading MyConf: $e $stack');
    }
  } catch (e) {
    // Widget may have been disposed, silently handle
    print('uploadMyConf error (widget may be disposed): $e');
  }
}

Future<void> syncNow(WidgetRef ref) async {
  final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
  final lastSync = await wealthtrackerPrefs.get(LAST_DOWNLOAD_TIME);
  final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  int? lastSyncTimestamp;

  if (lastSync != null) {
    lastSyncTimestamp = int.tryParse(lastSync);
    if (lastSyncTimestamp != null) {
      await downloadFrom(ref, lastSyncTimestamp);
    } else {
      await fullDownload(ref);
    }
  } else {
    await fullDownload(ref);
  }

  await uploadUnsynced(ref);

  final wealthtrackerRepository = await ref.read(wealthtrackerRepositoryProvider.future);
  await wealthtrackerRepository.stampUnstampedEntities();

  await wealthtrackerPrefs.set(LAST_DOWNLOAD_TIME, now.toString());

  // Fetch and save usage info
  try {
    final syncApi = await ref.read(wealthtrackerSyncProvider.future);
    if (syncApi == null) return;
    final usage = await syncApi.getUsage();
    if (usage != null) {
      final sizeBytes = usage['usage_size_bytes'];
      final maxMb = usage['max_mb'];
      if (sizeBytes != null) {
        await wealthtrackerPrefs.set(PREFS_USAGE_SIZE_BYTES, sizeBytes.toString());
      }
      if (maxMb != null) {
        await wealthtrackerPrefs.set(PREFS_USAGE_MAX_MB, maxMb.toString());
      }
    }
  } catch (e) {
    print('Error fetching usage: $e');
  }
}

Future<void> logOut(WidgetRef ref) async {
  await clearCache(ref);
}

Future<void> clearCache(WidgetRef ref) async {
  final wealthtrackerRepository = await ref.read(wealthtrackerRepositoryProvider.future);
  await wealthtrackerRepository.deleteDatabase();

  final wealthtrackerPrefs = ref.read(wealthtrackerPrefsProvider);
  await wealthtrackerPrefs.deleteAll();

  ref.invalidate(wealthtrackerRepositoryProvider);
  ref.invalidate(wealthtrackerSyncProvider);
  ref.invalidate(pgpProvider);
}
