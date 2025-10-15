import 'package:hive/hive.dart';

import '../models/store_model.dart';

abstract class StoreLocalDataSource {
  Future<List<Store>> getCachedStores();
  Future<void> cacheStores(List<Store> stores);
  Future<void> cachePendingSync(List<Store> stores);
  Future<List<Store>> getPendingSync();
  Future<void> clearPendingSync();
}

class StoreLocalDataSourceImpl implements StoreLocalDataSource {
  static const _cacheBox = 'store_cache';
  static const _pendingBox = 'store_pending';

  @override
  Future<List<Store>> getCachedStores() async {
    final box = await Hive.openBox<Store>(_cacheBox);
    return box.values.toList();
  }

  @override
  Future<void> cacheStores(List<Store> stores) async {
    final box = await Hive.openBox<Store>(_cacheBox);
    await box.clear();
    await box.addAll(stores);
  }

  @override
  Future<void> cachePendingSync(List<Store> stores) async {
    final box = await Hive.openBox<Store>(_pendingBox);
    await box.addAll(stores);
  }

  @override
  Future<List<Store>> getPendingSync() async {
    final box = await Hive.openBox<Store>(_pendingBox);
    return box.values.toList();
  }

  @override
  Future<void> clearPendingSync() async {
    final box = await Hive.openBox<Store>(_pendingBox);
    await box.clear();
  }
}
