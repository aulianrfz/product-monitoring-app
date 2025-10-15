import 'package:hive/hive.dart';

import '../../../../core/models/sync_model.dart';
import '../models/promo_model.dart';

abstract class PromoLocalDataSource {
  Future<void> cachePromos(List<Promo> promos, int storeId);
  Future<List<Promo>> getCachedPromos(int storeId);
  Future<void> clearPromos(int storeId);
  Future<void> markAsSynced(int storeId, int promoId, bool synced);
  Future<bool> isPromoSynced(int storeId, int promoId);
  Future<void> updateLocalPromo(int storeId, int promoId, double normal, double promo);
  Future<void> addPromoLocal(Promo promo, int storeId);
}

class PromoLocalDataSourceImpl implements PromoLocalDataSource {
  static const _promoBox = 'promoBox';
  static const _syncBox = 'syncBox';
  static const _promoStoreListBox = 'promoStoreListBox';

  Future<void> _addStoreId(int storeId) async {
    final listBox = await Hive.openBox<int>(_promoStoreListBox);
    if (!listBox.values.contains(storeId)) {
      await listBox.add(storeId);
    }
  }

  @override
  Future<void> cachePromos(List<Promo> promos, int storeId) async {
    final promoBox = await Hive.openBox<Promo>('$_promoBox-$storeId');
    final syncBox = await Hive.openBox<SyncStatus>('$_syncBox-$storeId');

    await promoBox.clear();
    await syncBox.clear();

    await promoBox.addAll(promos);
    for (var promo in promos) {
      await syncBox.put(
        'promo-${promo.id}',
        SyncStatus(
          type: 'promo',
          id: promo.id ?? -1,
          isSynced: true,
        ),
      );
    }

    await _addStoreId(storeId);
  }

  @override
  Future<List<Promo>> getCachedPromos(int storeId) async {
    final box = await Hive.openBox<Promo>('$_promoBox-$storeId');
    return box.values.toList();
  }

  @override
  Future<void> clearPromos(int storeId) async {
    await Hive.deleteBoxFromDisk('$_promoBox-$storeId');
    await Hive.deleteBoxFromDisk('$_syncBox-$storeId');
  }

  @override
  Future<void> markAsSynced(int storeId, int promoId, bool synced) async {
    final syncBox = await Hive.openBox<SyncStatus>('$_syncBox-$storeId');
    await syncBox.put(
      'promo-$promoId',
      SyncStatus(type: 'promo', id: promoId, isSynced: synced),
    );
  }

  @override
  Future<bool> isPromoSynced(int storeId, int promoId) async {
    final syncBox = await Hive.openBox<SyncStatus>('$_syncBox-$storeId');
    return syncBox.get('promo-$promoId')?.isSynced ?? false;
  }

  @override
  Future<void> updateLocalPromo(int storeId, int promoId, double normal, double promo) async {
    final box = await Hive.openBox<Promo>('$_promoBox-$storeId');
    final index = box.values.toList().indexWhere((p) => p.id == promoId);
    if (index != -1) {
      final oldPromo = box.getAt(index)!;
      final updated = Promo(
        id: oldPromo.id,
        storeId: oldPromo.storeId,
        productId: oldPromo.productId,
        productName: oldPromo.productName,
        normalPrice: normal,
        promoPrice: promo,
      );
      await box.putAt(index, updated);
    }
  }

  @override
  Future<void> addPromoLocal(Promo promo, int storeId) async {
    final box = await Hive.openBox<Promo>('promoBox-$storeId');
    await box.add(promo);

    final syncBox = await Hive.openBox<SyncStatus>('syncBox-$storeId');
    await syncBox.put(
      'promo-${promo.id ?? -1}',
      SyncStatus(type: 'promo', id: promo.id ?? -1, isSynced: false),
    );

    await _addStoreId(storeId);
  }


}
