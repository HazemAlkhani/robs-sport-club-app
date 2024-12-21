import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  late final String baseUrl;

  ApiService() {
    if (dotenv.isInitialized) {
      baseUrl = dotenv.env['BASE_URL'] ?? 'http://default_url';
    } else {
      throw Exception('DotEnv is not initialized. Ensure dotenv.load() is called before using ApiService.');
    }
    print('ApiService initialized with Base URL: $baseUrl');
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
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
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
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      ).timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Failed to register: ${e.toString()}');
    }
  }
}
