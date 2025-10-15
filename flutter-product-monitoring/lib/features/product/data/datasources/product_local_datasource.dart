import 'package:hive/hive.dart';

import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<Product>> getCachedProducts(int storeId);
  Future<void> cacheProducts(int storeId, List<Product> products);
  Future<void> cachePendingSync(int storeId, List<Product> products);
  Future<List<Product>> getPendingSync(int storeId);
  Future<void> clearPendingSync(int storeId);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  String _cacheBox(int storeId) => 'product_cache_$storeId';
  String _pendingBox(int storeId) => 'product_pending_$storeId';

  @override
  Future<List<Product>> getCachedProducts(int storeId) async {
    final box = await Hive.openBox<Product>(_cacheBox(storeId));
    return box.values.toList();
  }

  @override
  Future<void> cacheProducts(int storeId, List<Product> products) async {
    final box = await Hive.openBox<Product>(_cacheBox(storeId));
    await box.clear();
    await box.addAll(products);
  }

  @override
  Future<void> cachePendingSync(int storeId, List<Product> products) async {
    final box = await Hive.openBox<Product>(_pendingBox(storeId));
    await box.addAll(products);
  }

  @override
  Future<List<Product>> getPendingSync(int storeId) async {
    final box = await Hive.openBox<Product>(_pendingBox(storeId));
    return box.values.toList();
  }

  @override
  Future<void> clearPendingSync(int storeId) async {
    final box = await Hive.openBox<Product>(_pendingBox(storeId));
    await box.clear();
  }
}
