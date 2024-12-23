import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:robs_sport_club/providers/auth_provider.dart';
import 'package:robs_sport_club/screens/login_screen.dart';

void main() {
  group('LoginScreen Tests', () {
    testWidgets('Login form renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: LoginScreen(),
          ),
        ),
      );

      // Verify presence of email and password fields
      expect(find.byType(TextField), findsNWidgets(2));

      // Verify presence of Login button
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('Displays error dialog on failed login', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: LoginScreen(),
          ),
        ),
      );

      // Enter invalid credentials
      await tester.enterText(find.byType(TextField).first, 'invalid@example.com');
      await tester.enterText(find.byType(TextField).last, 'wrongpassword');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      // Expect error dialog
      expect(find.text('Login Failed'), findsOneWidget);
    });
  });
}
