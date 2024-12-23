import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _tokenKey = 'auth_token';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Save the token securely
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieve the token securely
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Clear the token securely
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Check if the token exists
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null;
  }
}
