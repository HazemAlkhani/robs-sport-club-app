import 'package:flutter_test/flutter_test.dart';
import 'package:robs_sport_club/providers/auth_provider.dart';
import 'package:robs_sport_club/services/api_service.dart';
import 'package:mockito/mockito.dart';

// Mock class for ApiService
class MockApiService extends Mock implements ApiService {}

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      authProvider = AuthProvider(apiService: mockApiService); // Inject the mock service
    });

    test('Login sets authentication state', () async {
      // Mock login to return a successful response
      when(mockApiService.login('test@example.com', 'password123'))
          .thenAnswer((_) async => {'token': 'dummy_token'});

      // Call the login method
      await authProvider.login('test@example.com', 'password123');

      // Assert that authentication state is set correctly
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.token, 'dummy_token');
    });

    test('Logout clears authentication state', () {
      authProvider.logout();

      // Assert that authentication state is cleared
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.token, isNull);
    });

    test('Check Auth Status when token is null', () async {
      authProvider.setToken(null); // Set token to null
      await authProvider.checkAuthStatus();

      // Assert that the authentication state is false
      expect(authProvider.isAuthenticated, false);
    });

    test('Check Auth Status when token is valid', () async {
      // Mock verifyToken to return true for a valid token
      when(mockApiService.verifyToken('dummy_token')).thenAnswer((_) async => true);

      authProvider.setToken('dummy_token'); // Set token
      await authProvider.checkAuthStatus();

      // Assert that the authentication state is true
      expect(authProvider.isAuthenticated, true);
    });

    test('Check Auth Status when token is invalid', () async {
      // Mock verifyToken to return false for an invalid token
      when(mockApiService.verifyToken('dummy_token')).thenAnswer((_) async => false);

      authProvider.setToken('dummy_token'); // Set token
      await authProvider.checkAuthStatus();

      // Assert that the authentication state is false
      expect(authProvider.isAuthenticated, false);
    });
  });
}
