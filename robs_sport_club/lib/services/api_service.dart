import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  late final String baseUrl;

  ApiService() {
    if (!dotenv.isInitialized) {
      throw Exception('DotEnv is not initialized. Ensure dotenv.load() is called before using ApiService.');
    }
    baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:5000';
  }

  // Common headers with optional token
  Map<String, String> _getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Handle API responses
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Unexpected error occurred');
    }
  }

  // User login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  // User registration
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _getHeaders(),
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );
    _handleResponse(response);
  }

  // Fetch children data
  Future<List<dynamic>> fetchChildren() async {
    final response = await http.get(
      Uri.parse('$baseUrl/child'),
      headers: _getHeaders(),
    );
    return _handleResponse(response);
  }

  // Add a new child
  Future<void> addChild(Map<String, dynamic> childData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/child'),
      headers: _getHeaders(),
      body: jsonEncode(childData),
    );
    _handleResponse(response);
  }

  // Fetch participation records
  Future<List<dynamic>> fetchParticipations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/participation'),
      headers: _getHeaders(),
    );
    return _handleResponse(response);
  }

  // Add a participation record
  Future<void> addParticipation(Map<String, dynamic> participationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/participation'),
      headers: _getHeaders(),
      body: jsonEncode(participationData),
    );
    _handleResponse(response);
  }

  // Fetch user data
  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: _getHeaders(),
    );
    return _handleResponse(response);
  }

  // Add a new user
  Future<void> addUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: _getHeaders(),
      body: jsonEncode(userData),
    );
    _handleResponse(response);
  }

  // Verify token
  Future<bool> verifyToken(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/verify'),
      headers: _getHeaders(token: token),
    );
    return response.statusCode == 200;
  }
}
