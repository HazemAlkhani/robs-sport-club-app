import 'package:flutter_test/flutter_test.dart';
import 'package:robs_sport_club/main.dart';

void main() {
  testWidgets('App test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp()); // Remove `const`
    expect(find.text('Login'), findsOneWidget); // Adjust the test logic
  });
}
