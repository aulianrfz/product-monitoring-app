import 'package:flutter/material.dart';
import '../../../../core/services/sync_services.dart';
import '../../../authentication/data/datasources/auth_remote_datasources.dart';
import '../../data/models/promo_model.dart';
import '../../data/repositories/promo_repository.dart';

class PromoViewModel extends ChangeNotifier {
  final PromoRepository repository;
  final SyncManager syncManager;

  bool isLoading = false;
  String? errorMessage;
  List<Promo> promos = [];

  PromoViewModel({required this.repository, required this.syncManager}) {
    syncManager.isSyncing.addListener(() async {
      if (!syncManager.isSyncing.value) {
        final token = await AuthService().getToken();
        if (token != null && promos.isNotEmpty) {
          final storeId = promos.first.storeId;
          await loadPromos(storeId, token);
        }
      }
    });
  }

  Future<void> loadPromos(int storeId, String token) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      promos = await repository.fetchPromos(storeId, token);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPromo(int storeId, Promo promo, String token) async {
    isLoading = true;
    notifyListeners();

    try {
      await repository.submitPromo(storeId, promo, token);
      await loadPromos(storeId, token);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePromo(
      int storeId, int promoId, double normalPrice, double promoPrice, String token) async {
    try {
      isLoading = true;
      notifyListeners();
      await repository.updatePromo(storeId, promoId, normalPrice, promoPrice, token);
      await loadPromos(storeId, token);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePromo(int storeId, int promoId, String token) async {
    try {
      await repository.deletePromo(storeId, promoId, token);
      await loadPromos(storeId, token);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> isPromoSynced(int storeId, int promoId) async {
    return repository.localDataSource.isPromoSynced(storeId, promoId);
  }
}
