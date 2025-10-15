import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/app_config.dart';
import '../models/user_model.dart';

class AuthService {
  final String baseUrl = AppConfig.baseUrl;

  Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['user']['token']);
        return User.fromJson(data['user']);
      }

      final data = json.decode(response.body);
      final message = data['message'] ?? 'Terjadi kesalahan';
      throw Exception(message);
    } on SocketException {
      throw Exception("Tidak ada koneksi internet. Periksa jaringan Anda.");
    } on FormatException {
      throw Exception("Format respons tidak valid dari server.");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", "").trim());
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
