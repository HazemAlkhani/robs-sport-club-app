import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000';
  static String? authToken; // To store the JWT token

  // Set the auth token after login
  static void setAuthToken(String token) {
    authToken = token;
    print('Auth token set: $authToken'); // Debug print
  }

  // Common headers for requests
  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  // Utility function for logging response details
  static void logResponse(http.Response response) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  // Fetch all participations
  static Future<List<dynamic>> getAllParticipations() async {
    try {
      print('Fetching all participations...');
      final response = await http.get(Uri.parse('$baseUrl/participations/all'), headers: getHeaders());
      logResponse(response);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch participations: ${response.body}');
      }
    } catch (e) {
      print('Error fetching participations: $e');
      rethrow;
    }
  }

  // Fetch all teams
  static Future<List<String>> getAllTeams() async {
    try {
      print('Fetching all teams...');
      final response = await http.get(Uri.parse('$baseUrl/participations/teams'), headers: getHeaders());
      logResponse(response);
      if (response.statusCode == 200) {
        return List<String>.from(jsonDecode(response.body).map((e) => e['TeamNo']));
      } else {
        throw Exception('Failed to fetch teams: ${response.body}');
      }
    } catch (e) {
      print('Error fetching teams: $e');
      rethrow;
    }
  }

  // Fetch participation by user ID
  static Future<List<dynamic>> getParticipationByUser(int userId) async {
    try {
      print('Fetching participation for user: $userId');
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/participations'),
        headers: getHeaders(),
      );
      logResponse(response);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception('Failed to fetch user participations: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user participations: $e');
      rethrow;
    }
  }

  // Register an admin
  static Future<void> registerAdmin(Map<String, dynamic> adminData) async {
    print('Registering admin: $adminData');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: getHeaders(),
      body: jsonEncode(adminData),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode != 201) {
      throw Exception('Failed to register admin: ${response.body}');
    }
  }

  // Register a user
  static Future<void> registerUser(Map<String, dynamic> userData) async {
    print('Registering user: $userData');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: getHeaders(),
      body: jsonEncode(userData),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode != 201) {
      throw Exception('Failed to register user: ${response.body}');
    }
  }

  // User login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Logging in with email: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      logResponse(response);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setAuthToken(data['token']); // Automatically set the auth token after login
        return data;
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      print('Error during login: $e');
      rethrow;
    }
  }

  // Add a child
  static Future<void> addChild(Map<String, dynamic> childData) async {
    try {
      print('Adding child: $childData');
      final response = await http.post(
        Uri.parse('$baseUrl/children/add'),
        headers: getHeaders(),
        body: jsonEncode(childData),
      );
      logResponse(response);
      if (response.statusCode != 201) {
        throw Exception('Failed to add child: ${response.body}');
      }
    } catch (e) {
      print('Error adding child: $e');
      rethrow;
    }
  }

  // Fetch all child statistics (admin view)
  static Future<List<dynamic>> fetchAllChildStatistics() async {
    try {
      print('Fetching all child statistics...');
      final response = await http.get(Uri.parse('$baseUrl/child-statistics'), headers: getHeaders());
      logResponse(response);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception('Failed to fetch all child statistics: ${response.body}');
      }
    } catch (e) {
      print('Error fetching child statistics: $e');
      rethrow;
    }
  }

  // Fetch child statistics for a specific user
  static Future<List<dynamic>> fetchChildStatisticsByUser(int userId) async {
    try {
      print('Fetching child statistics for user: $userId');
      final response = await http.get(
        Uri.parse('$baseUrl/child-statistics?userId=$userId'),
        headers: getHeaders(),
      );
      logResponse(response);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception('Failed to fetch child statistics for user: ${response.body}');
      }
    } catch (e) {
      print('Error fetching child statistics by user: $e');
      rethrow;
    }
  }

  // Fetch children by team
  static Future<List<dynamic>> getChildrenByTeam(String teamNo) async {
    try {
      print('Fetching children for team: $teamNo');
      final response = await http.get(
        Uri.parse('$baseUrl/participations/children/$teamNo'),
        headers: getHeaders(),
      );
      logResponse(response);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception('Failed to fetch children: ${response.body}');
      }
    } catch (e) {
      print('Error fetching children by team: $e');
      rethrow;
    }
  }

  // Add participation
  static Future<void> addParticipation(Map<String, dynamic> participationData) async {
    try {
      print('Adding participation: $participationData');
      final response = await http.post(
        Uri.parse('$baseUrl/participations/add'),
        headers: getHeaders(),
        body: jsonEncode(participationData),
      );
      logResponse(response);
      if (response.statusCode != 201) {
        throw Exception('Failed to add participation: ${response.body}');
      }
    } catch (e) {
      print('Error adding participation: $e');
      rethrow;
    }
  }
}
