import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/promo_model.dart';

abstract class PromoRemoteDataSource {
  Future<List<Promo>> fetchPromos(int storeId, String token);
  Future<void> updatePromo(int id, double normal, double promo, String token);
  Future<void> deletePromo(int promoId, String token);
  Future<Promo> sendPromo(Promo promo, String token);
}

class PromoRemoteDataSourceImpl implements PromoRemoteDataSource {
  final String baseUrl;

  PromoRemoteDataSourceImpl({required this.baseUrl});

  @override
  Future<List<Promo>> fetchPromos(int storeId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/promos?store_id=$storeId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['data'] ?? [];
      return list.map((json) => Promo.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat promo: ${response.body}');
    }
  }

  @override
  Future<void> updatePromo(
      int id, double normal, double promo, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/promos/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: {
        'normal_price': normal.toString(),
        'promo_price': promo.toString(),
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal update promo: ${response.body}');
    }
  }

  @override
  Future<void> deletePromo(int promoId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/promos/$promoId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal hapus promo: ${response.body}');
    }
  }

  @override
  Future<Promo> sendPromo(Promo promo, String token) async {
    final url = Uri.parse('$baseUrl/report/promo');

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode(promo.toJson());

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final newPromo = Promo.fromJson(data['data'] ?? data);
          return newPromo;
        } catch (jsonErr) {
          throw Exception('Gagal parse response server: $jsonErr');
        }
      } else {
        throw Exception('Gagal kirim promo: ${response.body}');
      }
    } catch (e, st) {
      rethrow;
    }
  }

}
