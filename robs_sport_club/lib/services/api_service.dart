import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'token_manager.dart';

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

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = _handleResponse(response);
      if (data.containsKey('token')) {
        await TokenManager.saveToken(data['token']);
      }
      return data;
    } catch (e) {
      log('Login error: $e', level: 1000);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );
      return _handleResponse(response);
    } catch (e) {
      log('Register error: $e', level: 1000);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _getHeaders(token: token),
      );
      return _handleResponse(response);
    } catch (e) {
      log('Fetch data error: $e', level: 1000);
      rethrow;
    }
  }
}
