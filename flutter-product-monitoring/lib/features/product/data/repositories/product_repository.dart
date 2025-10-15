import 'package:connectivity_plus/connectivity_plus.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepository  {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<List<Product>> fetchProducts(String token, int storeId) async {
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity != ConnectivityResult.none;

    if (isOnline) {
      try {
        final products = await remoteDataSource.fetchProducts(token, storeId);
        await localDataSource.cacheProducts(storeId, products);
        await _syncPending(token, storeId);
        return products;
      } catch (_) {
        return localDataSource.getCachedProducts(storeId);
      }
    } else {
      return localDataSource.getCachedProducts(storeId);
    }
  }

  Future<void> updateAvailabilityOffline(int storeId, Product product) async {
    await localDataSource.cachePendingSync(storeId, [product]);
  }

  Future<void> _syncPending(String token, int storeId) async {
    final pending = await localDataSource.getPendingSync(storeId);
    if (pending.isEmpty) return;

    try {
      for (final product in pending) {
        await remoteDataSource.sendProductAvailability(token, storeId, product);
      }
      await localDataSource.clearPendingSync(storeId);
    } catch (_) {
    }
  }
}
