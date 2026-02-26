import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/Providers.dart';
import '../db/WealthtrackerRepository.dart';
import '../models/Asset.dart';
import '../models/Comment.dart';
import 'package:kryptic_core/kryptic_core.dart';
import 'WealthtrackerSync.dart';

// Generic restore function for an entity type
Future<void> _restoreEntityFile<T>(
  WealthtrackerRepository wealthtrackerRepository,
  EntitySyncConfig<T, WealthtrackerRepository> config,
  String folderName,
  ArchiveFile file,
) async {
  Logger.log("Restore", config.logName);
  try {
    final entityString = utf8.decode(file.content as List<int>);
    final entity = config.fromJson(jsonDecode(entityString));
    await config.saveEntity(wealthtrackerRepository, entity);
  } catch (e, stack) {
    print('Error: $e $stack');
  }
}

Future<List<String>> restoreWealthtrackerData(WidgetRef ref, List<int> zipBytes) async {
  final wealthtrackerRepository = await ref.read(wealthtrackerRepositoryProvider.future);
  final archive = ZipDecoder().decodeBytes(zipBytes);
  final contents = <String>[];

  Logger.log("Restore", "Start");
  for (final file in archive) {
    if (file.isFile) {
      if (file.name.startsWith("asset/")) {
        await _restoreEntityFile(wealthtrackerRepository, assetConfig, "asset", file);
      }
      else if (file.name.startsWith("comment/")) {
        await _restoreEntityFile(wealthtrackerRepository, commentConfig, "comment", file);
      }
      else if (file.name.startsWith("myconf/")) {
        await _restoreEntityFile(wealthtrackerRepository, myConfConfig, "myconf", file);
      }
    }
  }
  return contents;
}

// Generic backup function for an entity type
Future<void> _backupEntityList<T>(
  WealthtrackerRepository wealthtrackerRepository,
  EntitySyncConfig<T, WealthtrackerRepository> entity,
  Map<String, Uint8List> files,
  String folderName,
) async {
  Logger.log("Backup", entity.logName);
  try {
    var itemList = await entity.loadEntityList(wealthtrackerRepository);
    for (final item in itemList) {
      final itemId = (item as dynamic).id as String;
      final itemEntity = await entity.loadEntity(wealthtrackerRepository, itemId);
      if (itemEntity != null) {
        final itemString = jsonEncode((itemEntity as dynamic).toJson());
        files["$folderName/$itemId.json"] = Uint8List.fromList(
          utf8.encode(itemString),
        );
      }
    }
  } catch (e, stack) {
    print('Error: $e $stack');
  }
}

/// Import legacy JSON from the old wealthtracker app.
/// Format: {"assets": [{"i": yearMonth, "n": name, "x": value}, ...],
///          "comments": [{"i": yearMonth, "c": comment}, ...]}
Future<int> restoreLegacyJson(WidgetRef ref, String jsonString) async {
  final repo = await ref.read(wealthtrackerRepositoryProvider.future);
  final json = jsonDecode(jsonString) as Map<String, dynamic>;
  int count = 0;

  if (json['assets'] != null) {
    // Group legacy items by name, build single Asset per name with merged monthlyValues
    final grouped = <String, Map<String, dynamic>>{};
    for (final item in json['assets'] as List) {
      final yearMonth = item['i'] as int?;
      final name = item['n'] as String?;
      final value = item['x'] as num?;
      if (yearMonth == null || name == null) continue;

      if (!grouped.containsKey(name)) {
        grouped[name] = {
          'name': name,
          'monthly_values': <String, double>{},
        };
      }
      (grouped[name]!['monthly_values'] as Map<String, double>)[yearMonth.toString()] = (value ?? 0).toDouble();
      count++;
    }

    for (final entry in grouped.values) {
      final name = entry['name'] as String;
      final mv = entry['monthly_values'] as Map<String, double>;

      // Find existing asset by name to avoid duplicates
      final existing = await repo.assets.loadByName(name);
      final id = existing?.id ?? WealthtrackerRepository.generateId();

      // Merge with existing monthlyValues if any
      final mergedMv = Map<String, double>.from(existing?.monthlyValues ?? {});
      mergedMv.addAll(mv);

      final asset = Asset(
        id: id,
        name: name,
        monthlyValues: mergedMv,
      );
      await repo.assets.save(asset);
    }
  }

  if (json['comments'] != null) {
    for (final item in json['comments'] as List) {
      final yearMonth = item['i'] as int?;
      final commentText = item['c'] as String?;
      if (yearMonth == null || commentText == null || commentText.isEmpty) continue;

      // Find existing comment by yearMonth to avoid duplicates
      final existing = await repo.comments.loadByMonth(yearMonth);
      final id = existing?.id ?? WealthtrackerRepository.generateId();

      final comment = Comment(
        id: id,
        yearMonth: yearMonth,
        comment: commentText,
      );
      await repo.comments.save(comment);
      count++;
    }
  }

  return count;
}

Future<Uint8List> backupWealthtrackerData(WidgetRef ref) async {
  Logger.log("Backup", "Start");
  final wealthtrackerRepository = await ref.read(wealthtrackerRepositoryProvider.future);
  final files = <String, Uint8List>{};

  await _backupEntityList(wealthtrackerRepository, assetConfig, files, "asset");
  await _backupEntityList(wealthtrackerRepository, commentConfig, files, "comment");
  await _backupEntityList(wealthtrackerRepository, myConfConfig, files, "myconf");

  Logger.log("Backup", "Zipping");
  final archive = Archive();
  files.forEach((name, data) {
    archive.addFile(ArchiveFile.noCompress(name, data.lengthInBytes, data));
  });
  return Uint8List.fromList(ZipEncoder().encode(archive));
}
