import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000';
  static String? authToken;

  static void setAuthToken(String token) {
    authToken = token;
    print('Auth token set: $authToken');
  }

  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  static void logResponse(http.Response response) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  // ===================
  // Authentication
  // ===================
  static Future<void> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: getHeaders(),
      body: jsonEncode(userData),
    );
    logResponse(response);
    if (response.statusCode != 201) {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    logResponse(response);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setAuthToken(data['token']);
      return data;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // ===================
  // User Management
  // ===================
  static Future<List<dynamic>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/all'),
      headers: getHeaders(),
    );
    logResponse(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch users: ${response.body}');
    }
  }

  static Future<void> updateUser(int userId, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/update/$userId'),
      headers: getHeaders(),
      body: jsonEncode(userData),
    );
    logResponse(response);
    if (response.statusCode != 200) {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getUserById(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: getHeaders(),
    );
    logResponse(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch user details: ${response.body}');
    }
  }

  static Future<List<dynamic>> getUserStatistics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/statistics/user'), // Matches the existing backend route
      headers: getHeaders(),
    );

    logResponse(response);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data']; // Parse data from the response
    } else {
      throw Exception('Failed to fetch user statistics: ${response.body}');
    }
  }

  static Future<void> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/delete/$userId'),
      headers: getHeaders(),
    );
    logResponse(response);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }

  // ===================
  // Child Management
  // ===================
  static Future<void> addChild(Map<String, dynamic> childData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/children/add'),
      headers: getHeaders(),
      body: jsonEncode(childData),
    );
    logResponse(response);
    if (response.statusCode != 201) {
      throw Exception('Failed to add child: ${response.body}');
    }
  }

  static Future<List<dynamic>> getAllChildren({int? userId}) async {
    final response = await http.get(
      Uri.parse(userId != null
          ? '$baseUrl/children/all?userId=$userId'
          : '$baseUrl/children/all'),
      headers: getHeaders(),
    );

    logResponse(response);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch children: ${response.body}');
    }
  }


  static Future<void> updateChild(int childId, Map<String, dynamic> childData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/children/update/$childId'),
      headers: getHeaders(),
      body: jsonEncode(childData),
    );
    logResponse(response);
    if (response.statusCode != 200) {
      throw Exception('Failed to update child: ${response.body}');
    }
  }

  static Future<List<dynamic>> getChildrenByTeamAndSport(String teamNo, String sportType) async {
    final response = await http.get(
      Uri.parse('$baseUrl/children/by-team-and-sport?teamNo=$teamNo&sportType=$sportType'),
      headers: getHeaders(),
    );

    logResponse(response);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch children: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getChildStatistics(int childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/statistics/child/$childId'),
      headers: getHeaders(),
    );

    logResponse(response);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch child statistics: ${response.body}');
    }
  }



  static Future<void> deleteChild(int childId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/children/delete/$childId'),
      headers: getHeaders(),
    );
    logResponse(response);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete child: ${response.body}');
    }
  }

  // ===================
  // Participation Management
  // ===================
  static Future<void> addParticipation(Map<String, dynamic> participationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/participations/add'),
      headers: getHeaders(),
      body: jsonEncode(participationData),
    );
    logResponse(response);
    if (response.statusCode != 201) {
      throw Exception('Failed to add participation: ${response.body}');
    }
  }

  static Future<List<dynamic>> getAllParticipations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/participations/all'),
      headers: getHeaders(),
    );
    logResponse(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch participations: ${response.body}');
    }
  }

  static Future<List<dynamic>> getParticipationsByChild(int childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/participations/child/$childId'),
      headers: getHeaders(),
    );

    logResponse(response);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch participations for child: ${response.body}');
    }
  }


  // ===================
  // Statistics Management
  // ===================
  static Future<Map<String, dynamic>> getUserChildStatistics(int childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/statistics/child/$childId'),
      headers: getHeaders(),
    );

    logResponse(response);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch child statistics: ${response.body}');
    }
  }



  static Future<List<dynamic>> getAllStatistics({int page = 1, int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/statistics/all?page=$page&limit=$limit'),
      headers: getHeaders(),
    );
    logResponse(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch all statistics: ${response.body}');
    }
  }

}
