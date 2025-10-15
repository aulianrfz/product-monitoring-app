import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository repository;

  ProductViewModel({required this.repository});

  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _products = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Product> get products => _products;

  Future<void> loadProducts(String token, int storeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await repository.fetchProducts(token, storeId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAvailability(
      String token,
      int storeId,
      Product product,
      ) async {
    final newAvailability = !product.available;

    final updatedProduct = Product(
      id: product.id,
      name: product.name,
      barcode: product.barcode,
      size: product.size,
      available: newAvailability,
    );

    try {
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }

      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      if (isOnline) {
        await repository.remoteDataSource.sendProductAvailability(
          token,
          storeId,
          updatedProduct,
        );
      } else {
        await repository.updateAvailabilityOffline(storeId, updatedProduct);
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

}
