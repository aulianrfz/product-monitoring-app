import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/store_model.dart';

abstract class StoreRemoteDataSource {
  Future<List<Store>> fetchStores(String token);
  Future<void> addStore(String token, Store store);
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final String baseUrl;

  StoreRemoteDataSourceImpl({required this.baseUrl});

  @override
  Future<List<Store>> fetchStores(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stores'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List storesJson = data['data'];
      return storesJson.map((e) => Store.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat daftar toko: ${response.body}');
    }
  }

  @override
  Future<void> addStore(String token, Store store) async {
    final response = await http.post(
      Uri.parse('$baseUrl/stores'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(store.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal mengirim store ke server');
    }
  }

}
