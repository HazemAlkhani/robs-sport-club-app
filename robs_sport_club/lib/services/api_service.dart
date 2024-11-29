import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class ApiService {
  // Base URL for the backend API
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'default_url';

  ApiService() {
    print('Base URL: $baseUrl'); // Debugging: Ensure correct backend URL
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
      print('Base URL: $baseUrl'); // Debugging: Ensure correct backend URL
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/login'), // Ensure the endpoint matches your backend
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      )
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
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
      print('Base URL: $baseUrl'); // Debugging: Ensure correct backend URL
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/register'), // Ensure the endpoint matches your backend
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      )
          .timeout(const Duration(seconds: 10)); // Timeout for request
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  // Example: Get user profile (optional for your app)
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      print('Base URL: $baseUrl'); // Debugging: Ensure correct backend URL
      final response = await http
          .get(
        Uri.parse('$baseUrl/user/profile'), // Replace with your endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
  }

  // Example: Logout user (optional)
  Future<void> logout(String token) async {
    try {
      print('Base URL: $baseUrl'); // Debugging: Ensure correct backend URL
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/logout'), // Replace with your endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 204) {
        throw Exception('Logout failed');
      }
    } catch (e) {
      throw Exception('Failed to log out: ${e.toString()}');
    }
  }
}
