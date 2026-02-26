class EntitySyncConfig<T, R> {
  final String boxName;
  final String logName;
  final T Function(Map<String, dynamic>) fromJson;
  final Future<void> Function(R, T, {bool fromSync}) saveEntity;
  final Future<List<T>> Function(R) loadEntityList;
  final Future<T?> Function(R, String) loadEntity;
  final Future<List<T>> Function(R) loadUnsynced;
  final Future<void> Function(R, String) markSynced;
  final int? Function(T) getUpdatedAt;

  EntitySyncConfig({
    required this.boxName,
    required this.logName,
    required this.fromJson,
    required this.saveEntity,
    required this.loadEntityList,
    required this.loadEntity,
    required this.loadUnsynced,
    required this.markSynced,
    required this.getUpdatedAt,
  });
}
