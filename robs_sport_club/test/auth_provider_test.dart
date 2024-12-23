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
      // Inject mockApiService into AuthProvider
      authProvider = AuthProvider(apiService: mockApiService);
    });

    test('Login sets authentication state', () async {
      // Simulate successful login response
      when(mockApiService.login('test@example.com', 'password123'))
          .thenAnswer((_) async => {'token': 'dummy_token'});

      await authProvider.login('test@example.com', 'password123');

      expect(authProvider.isAuthenticated, true);
      expect(authProvider.token, 'dummy_token');
    });

    test('Logout clears authentication state', () {
      authProvider.logout();

      expect(authProvider.isAuthenticated, false);
      expect(authProvider.token, isNull);
    });

    test('Check Auth Status when token is null', () async {
      authProvider.setToken(null); // Set token to null
      await authProvider.checkAuthStatus();

      expect(authProvider.isAuthenticated, false);
    });

    test('Check Auth Status when token is valid', () async {
      // Simulate token verification
      when(mockApiService.verifyToken('dummy_token')).thenAnswer((_) async => true);

      authProvider.setToken('dummy_token'); // Set token
      await authProvider.checkAuthStatus();

      expect(authProvider.isAuthenticated, true);
    });

    test('Check Auth Status when token is invalid', () async {
      // Simulate token verification failure
      when(mockApiService.verifyToken('dummy_token')).thenAnswer((_) async => false);

      authProvider.setToken('dummy_token'); // Set token
      await authProvider.checkAuthStatus();

      expect(authProvider.isAuthenticated, false);
    });
  });
}
