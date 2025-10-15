import '../datasources/auth_remote_datasources.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<User?> login(String email, String password) async {
    try {
      return await _authService.login(email, password);
    } catch (e) {
      rethrow;
    }
  }
}
