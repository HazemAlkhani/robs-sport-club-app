import 'package:flutter/material.dart';
import 'package:robs_sport_club/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _token; // Declare _token as a private field
  String? get token => _token; // Provide a getter for _token

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    _token = response['token']; // Assign value to _token
    _isAuthenticated = true;
    notifyListeners();
  }
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    // Call the API to register a new user
    await _apiService.register(email: email, password: password, name: name);
    // Optionally set any authentication state if needed
  }

  void logout() {
    _token = null; // Clear _token on logout
    _isAuthenticated = false;
    notifyListeners();
  }
}
