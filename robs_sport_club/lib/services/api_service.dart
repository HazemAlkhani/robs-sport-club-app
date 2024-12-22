import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  late final String baseUrl;

  ApiService() {
    if (!dotenv.isInitialized) {
      throw Exception('DotEnv is not initialized. Ensure dotenv.load() is called before using ApiService.');
    }
    baseUrl = dotenv.env['BASE_URL'] ?? 'http://default_url';
  }

  Map<String, String> _getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Unexpected error occurred');
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  // Register user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _getHeaders(),
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );
    return _handleResponse(response);
  }
}
