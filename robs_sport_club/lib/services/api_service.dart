import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:io';

class ApiService {
  // Base URL for the backend API
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'default_url';

  ApiService() {
    if (baseUrl == 'default_url') {
      print('Warning: BASE_URL not set in .env file.');
    }
    print('Base URL: $baseUrl'); // Debugging: Ensure correct backend URL
  }

  // Common headers
  Map<String, String> _getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method to handle responses
  dynamic _handleResponse(http.Response response) {
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Unexpected error occurred');
      }
    } catch (_) {
      throw Exception('Failed to process response');
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      )
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Failed to log in: ${e.toString()}');
    }
  }

  // Register user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      )
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/user/profile'),
        headers: _getHeaders(token: token),
      )
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout(String token) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _getHeaders(token: token),
      )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 204) {
        throw Exception('Logout failed');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Failed to log out: ${e.toString()}');
    }
  }

  // Check health of the backend
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/health'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));
      final data = _handleResponse(response);
      return data['status'] == 'healthy';
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Failed to check backend health: ${e.toString()}');
    }
  }
}
