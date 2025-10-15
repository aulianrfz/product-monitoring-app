import 'package:flutter/material.dart';

import '../../data/datasources/auth_remote_datasources.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  bool _isLoggedIn = false;
  bool _isChecking = true;

  bool get isLoggedIn => _isLoggedIn;
  bool get isChecking => _isChecking;

  AuthViewModel({required AuthService authService}) : _authService = authService {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final token = await _authService.getToken();
    _isLoggedIn = token != null;
    _isChecking = false;
    notifyListeners();
  }
}
