import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/statistics.dart'; // Ensure you have the correct import path

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

  // =====================
  // User-specific methods
  // =====================

  // Register a user
  static Future<void> registerUser(Map<String, dynamic> userData) async {
    print('Registering user: $userData');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: getHeaders(),
      body: jsonEncode(userData),
    );
    logResponse(response);
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

  // Fetch children by user ID
  static Future<List<dynamic>> getChildrenByUser(int userId) async {
    try {
      print('Fetching children for user: $userId');
      final response = await http.get(
          Uri.parse('$baseUrl/children/all'),
          headers: getHeaders(),
      );
      logResponse(response);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']; // Adjust based on your API's response structure
      } else {
        throw Exception('Failed to fetch children: ${response.body}');
      }
    } catch (e) {
      print('Error fetching children: $e');
      rethrow;
    }
  }


  // Fetch participation for a specific user
  static Future<List<Map<String, dynamic>>> getParticipationsForUserChildren() async {
    try {
      print('Fetching participations for user children...');
      final response = await http.get(
        Uri.parse('$baseUrl/participations/my-children'),
        headers: getHeaders(),
      );
      logResponse(response);

      if (response.statusCode == 200) {
        return (jsonDecode(response.body)['data'] as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else if (response.statusCode == 404) {
        return []; // No participation records found
      } else {
        throw Exception('Failed to fetch participations: ${response.body}');
      }
    } catch (e) {
      print('Error fetching participations for user children: $e');
      rethrow;
    }
  }

  // Update user details
  static Future<void> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      print('Updating user: $userId');
      final response = await http.put(
        Uri.parse('$baseUrl/users/update/$userId'),
        headers: getHeaders(),
        body: jsonEncode(userData),
      );
      logResponse(response);
      if (response.statusCode != 200) {
        throw Exception('Failed to update user: ${response.body}');
      }
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUserById(int userId) async {
    try {
      print('Fetching user details for user ID: $userId');
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: getHeaders(),
      );
      logResponse(response); // Log the response for debugging
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']; // Assuming your API returns a "data" field
      } else {
        throw Exception('Failed to fetch user details: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      rethrow;
    }
  }


  // =====================
  // Admin-specific methods
  // =====================

  // Register an admin
  static Future<void> registerAdmin(Map<String, dynamic> adminData) async {
    print('Registering admin: $adminData');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: getHeaders(),
      body: jsonEncode(adminData),
    );
    logResponse(response);
    if (response.statusCode != 201) {
      throw Exception('Failed to register admin: ${response.body}');
    }
  }



  // =====================
  // Shared methods
  // =====================

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

  // Update child details
  static Future<void> updateChild(Map<String, dynamic> childData) async {
    try {
      print('Updating child: ${childData['ChildId']}');
      final response = await http.put(
        Uri.parse('$baseUrl/children/update/${childData['ChildId']}'),
        headers: getHeaders(),
        body: jsonEncode(childData),
      );
      logResponse(response);
      if (response.statusCode != 200) {
        throw Exception('Failed to update child: ${response.body}');
      }
    } catch (e) {
      print('Error updating child: $e');
      rethrow;
    }
  }

  // Fetch children by team and sport
  static Future<List<dynamic>> getChildrenByTeamAndSport(String teamNo, String sportType) async {
    try {
      print('Fetching children for team $teamNo and sport $sportType');
      final response = await http.get(
        Uri.parse('$baseUrl/children/by-team-and-sport?teamNo=$teamNo&sportType=$sportType'),
        headers: getHeaders(),
      );
      logResponse(response);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch children: ${response.body}');
      }
    } catch (e) {
      print('Error fetching children: $e');
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

  //Fetch Participations (User or Admin)
  static Future<List<Statistics>> getAllParticipations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/participations/all'),
        headers: getHeaders(),
      );

      logResponse(response);

      if (response.statusCode == 200) {
        return (jsonDecode(response.body)['data'] as List)
            .map((item) => Statistics.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to fetch participations: ${response.body}');
      }
    } catch (e) {
      print('Error fetching participations: $e');
      rethrow;
    }
  }


  static Future<void> deleteChild(int childId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/children/delete/$childId'),
        headers: getHeaders(),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete child: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting child: $e');
    }
  }


  //etches statistics for children associated with the logged-in user
  static Future<List<Map<String, dynamic>>> getUserStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/user'),
        headers: getHeaders(),
      );

      logResponse(response);

      if (response.statusCode == 200) {
        return (jsonDecode(response.body)['data'] as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else {
        throw Exception('Failed to fetch user statistics: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user statistics: $e');
      rethrow;
    }
  }

  // Fetch statistics for the logged-in user
  static Future<Statistics> fetchChildStatisticsById(int childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/$childId'),
        headers: getHeaders(),
      );

      logResponse(response);

      if (response.statusCode == 200) {
        return Statistics.fromJson(jsonDecode(response.body)['data']);
      } else {
        throw Exception('Failed to fetch statistics for child: ${response.body}');
      }
    } catch (e) {
      print('Error fetching statistics by child ID: $e');
      throw Exception('Error while fetching statistics for child.');
    }
  }
// Fetch all child statistics (Admin)
  static Future<List<Statistics>> fetchAllChildStatistics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/statistics/all'),
      headers: getHeaders(),
    );

    logResponse(response);

    if (response.statusCode == 200) {
      return (jsonDecode(response.body)['data'] as List)
          .map((item) => Statistics.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to fetch all statistics: ${response.body}');
    }
  }

  // Fetch statistics for a specific child by name
  static Future<Map<String, dynamic>> fetchChildStatisticsByName(String childName) async {
    final response = await http.get(
      Uri.parse('$baseUrl/statistics/$childName'),
      headers: getHeaders(),
    );

    logResponse(response);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body)['data']);
    } else if (response.statusCode == 404) {
      throw Exception('Statistics not found for the child.');
    } else {
      throw Exception('Failed to fetch statistics for the child: ${response.body}');
    }
  }





}
