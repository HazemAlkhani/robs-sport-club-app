import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:robs_sport_club/providers/auth_provider.dart';
import 'package:robs_sport_club/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen displays and logs in', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: LoginScreen(),
        ),
      ),
    );

    // Enter text into email and password fields
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password');

    // Tap on the login button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Check if login was successful (based on UI or provider state)
    // Add relevant expectations based on your app's behavior
  });
}
