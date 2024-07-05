import 'package:flutter/material.dart';
import 'package:smart_door_ms_app/services/auth_services.dart';

class AuthProvider with ChangeNotifier {
  String _token = '';
  bool _isAuthenticated = false;

  String get token => _token;
  bool get isAuthenticated => _isAuthenticated;

  final AuthService _authService = AuthService();

  Future<void> register(String name, String email, String password,
      String passwordConfirmation) async {
    final response = await _authService.register(
        name, email, password, passwordConfirmation);
    if (response['message'] == 'User registered successfully') {
      // Handle registration success
    } else {
      // Handle registration failure
    }
  }

  Future<void> login(String email, String password) async {
    final response = await _authService.login(email, password);
    if (response.containsKey('token')) {
      _token = response['token'];
      _isAuthenticated = true;
      notifyListeners();
    } else {
      // Handle login failure
    }
  }

  Future<void> logout() async {
    await _authService.logout(_token);
    _token = '';
    _isAuthenticated = false;
    notifyListeners();
  }
}
