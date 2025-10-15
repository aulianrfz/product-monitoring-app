import 'package:flutter/foundation.dart';
import '../../data/models/store_model.dart';
import '../../data/repositories/store_repository.dart';


class StoreViewModel extends ChangeNotifier {
  final StoreRepository repository;

  StoreViewModel({required this.repository});

  List<Store> _stores = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Store> get stores => _stores;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStores(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _stores = await repository.fetchStores(token);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
