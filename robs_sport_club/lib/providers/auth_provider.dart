import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:robs_sport_club/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  late final ApiService _apiService;
  String? _token;
  bool _isAuthenticated = false;

  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;

  // Constructor accepts an optional ApiService for testing
  AuthProvider({ApiService? apiService}) {
    try {
      _apiService = apiService ?? ApiService(); // Use the mock if provided
    } catch (e) {
      log('AuthProvider initialization failed: $e', level: 1000);
      rethrow;
    }
  }

  // User login
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

  // User registration
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _apiService.register(email: email, password: password, name: name);
      _isAuthenticated = true; // Assume successful registration also authenticates
      notifyListeners();
    } catch (e) {
      log('Registration failed: $e', level: 1000);
      rethrow;
    }
  }

  // User logout
  void logout() {
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Check authentication status
  Future<void> checkAuthStatus() async {
    if (_token != null) {
      try {
        final isValid = await _apiService.verifyToken(_token!);
        _isAuthenticated = isValid;
      } catch (e) {
        _isAuthenticated = false;
        log('Authentication check failed: $e', level: 1000);
      }
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  // Setter for testing _token
  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }
}
