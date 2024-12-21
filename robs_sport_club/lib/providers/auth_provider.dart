import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:robs_sport_club/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  late final ApiService _apiService;
  String? _token;
  bool _isAuthenticated = false;

  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    try {
      _apiService = ApiService(); // Initialize here after DotEnv is loaded
    } catch (e) {
      print('AuthProvider initialization failed: $e');
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      _token = response['token'];
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      log('Login failed: $e', level: 1000); // Replaced print with log
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _apiService.register(email: email, password: password, name: name);
    } catch (e) {
      log('Registration failed: $e', level: 1000); // Replaced print with log
      rethrow;
    }
  }

  void logout() {
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
