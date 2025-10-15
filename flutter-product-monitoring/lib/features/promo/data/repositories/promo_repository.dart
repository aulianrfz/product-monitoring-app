import 'package:hive/hive.dart';

import '../../../../core/repositories/sync_repository.dart';
import '../../../attendance/data/repositories/attendance_repository.dart';
import '../datasources/promo_local_datasource.dart';
import '../datasources/promo_remote_datasource.dart';
import '../models/promo_model.dart';

class PromoRepository implements SyncableRepository {
  final PromoRemoteDataSource remoteDataSource;
  final PromoLocalDataSource localDataSource;

  PromoRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<List<Promo>> fetchPromos(int storeId, String token) async {
    try {
      final promos = await remoteDataSource.fetchPromos(storeId, token);
      await localDataSource.cachePromos(promos, storeId);
      return promos;
    } catch (_) {
      return await localDataSource.getCachedPromos(storeId);
    }
  }

  Future<void> updatePromo(
      int storeId, int promoId, double normalPrice, double promoPrice, String token) async {
    await localDataSource.updateLocalPromo(storeId, promoId, normalPrice, promoPrice);
    try {
      await remoteDataSource.updatePromo(promoId, normalPrice, promoPrice, token);
      await localDataSource.markAsSynced(storeId, promoId, true);
    } catch (_) {
      await localDataSource.markAsSynced(storeId, promoId, false);
    }
  }

  Future<void> deletePromo(int storeId, int promoId, String token) async {
    try {
      await remoteDataSource.deletePromo(promoId, token);
      await localDataSource.markAsSynced(storeId, promoId, true);
    } catch (_) {
      await localDataSource.markAsSynced(storeId, promoId, false);
    }
  }

  Future<void> submitPromo(int storeId, Promo promo, String token) async {
    try {
      await remoteDataSource.sendPromo(promo, token);
      await localDataSource.markAsSynced(storeId, promo.id ?? -1, true);
    } catch (_) {
      final cached = await localDataSource.getCachedPromos(storeId);
      await localDataSource.cachePromos([...cached, promo], storeId);
      await localDataSource.markAsSynced(storeId, promo.id ?? -1, false);
    }
  }

  @override
  Future<void> syncPending(String token) async {
    // final storeIdList = await Hive.boxKeys('promoBox'); // opsional kalau lu punya banyak toko
    // for (var storeKey in storeIdList) {
    //   final storeId = int.parse(storeKey.split('-').last);
    //   final promos = await localDataSource.getCachedPromos(storeId);
    //   for (var promo in promos) {
    //     final synced = await localDataSource.isPromoSynced(storeId, promo.id ?? -1);
    //     if (!synced) {
    //       try {
    //         await remoteDataSource.sendPromo(promo, token);
    //         await localDataSource.markAsSynced(storeId, promo.id ?? -1, true);
    //       } catch (_) {}
    //     }
    //   }
    // }
  }

}
