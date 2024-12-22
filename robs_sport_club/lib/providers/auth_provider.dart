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
      _apiService = ApiService(); // Initialize ApiService
    } catch (e) {
      log('AuthProvider initialization failed: $e', level: 1000);
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
      log('Login failed: $e', level: 1000);
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
      _isAuthenticated = true; // Assume registration also authenticates
      notifyListeners();
    } catch (e) {
      log('Registration failed: $e', level: 1000);
      rethrow;
    }
  }

  void logout() {
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
