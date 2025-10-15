import 'package:connectivity_plus/connectivity_plus.dart';
import '../datasources/store_local_datasource.dart';
import '../datasources/store_remote_datasource.dart';
import '../models/store_model.dart';

class StoreRepository {
  final StoreRemoteDataSource remoteDataSource;
  final StoreLocalDataSource localDataSource;

  StoreRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<List<Store>> fetchStores(String token) async {
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity != ConnectivityResult.none;

    if (isOnline) {
      try {
        final stores = await remoteDataSource.fetchStores(token);
        await localDataSource.cacheStores(stores);
        await _syncPending(token);
        return stores;
      } catch (e) {
        return localDataSource.getCachedStores();
      }
    } else {
      return localDataSource.getCachedStores();
    }
  }

  Future<void> addStoreOffline(Store store) async {
    await localDataSource.cachePendingSync([store]);
  }

  Future<void> _syncPending(String token) async {
    final pending = await localDataSource.getPendingSync();
    if (pending.isEmpty) return;

    try {
      for (final s in pending) {
        await remoteDataSource.addStore(token, s);
      }
      await localDataSource.clearPendingSync();
    } catch (_) {
    }
  }
}
