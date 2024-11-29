import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TokenUtil {
  static const _tokenKey = 'auth_token';

  /// Save the token in SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Retrieve the token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Clear the token from SharedPreferences (e.g., during logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Check if a token exists in SharedPreferences
  static Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  /// Decode the payload of a JWT token (optional)
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token format');
      }
      final payload = _decodeBase64(parts[1]);
      return payload;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  /// Helper method to decode Base64-encoded strings
  static Map<String, dynamic> _decodeBase64(String str) {
    final normalized = base64Url.normalize(str);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded);
  }
}
