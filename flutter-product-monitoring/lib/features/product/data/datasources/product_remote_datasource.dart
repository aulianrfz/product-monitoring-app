import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>> fetchProducts(String token, int storeId);
  Future<void> sendProductAvailability(String token, int storeId, Product product);
  Future<void> sendProductReport({
    required int storeId,
    required int productId,
    required bool available,
    required String timestamp,
    required String token,
  });
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final String baseUrl;

  ProductRemoteDataSourceImpl({required this.baseUrl});

  @override
  Future<List<Product>> fetchProducts(String token, int storeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products?store_id=$storeId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['data'];
      return products.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat produk: ${response.body}');
    }
  }

  @override
  Future<void> sendProductAvailability(String token,
      int storeId,
      Product product,) async {
    final now = DateTime.now();
    final formattedTimestamp =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(
        2, '0')}-${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(
        2, '0')}:${now.second.toString().padLeft(2, '0')}";

    final response = await http.post(
      Uri.parse('$baseUrl/report/product'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'store_id': storeId,
        'product_id': product.id,
        'available': product.available,
        'timestamp': formattedTimestamp,
      }),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
          'Gagal mengirim data ketersediaan produk: ${response.body}');
    }
  }

  @override
  Future<void> sendProductReport({
    required int storeId,
    required int productId,
    required bool available,
    required String timestamp,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/report/product'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'store_id': storeId,
        'product_id': productId,
        'available': available,
        'timestamp': timestamp,
      }),
    );
  }
}
