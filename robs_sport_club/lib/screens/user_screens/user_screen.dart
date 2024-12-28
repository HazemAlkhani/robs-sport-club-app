import 'package:flutter/material.dart';
import '../child_screens/select_child_screen.dart';

class UserScreen extends StatelessWidget {
  final int userId;

  const UserScreen({Key? key, required this.userId}) : super(key: key);

  // Navigate to the SelectChildScreen based on the action
  void navigateToSelectChildScreen(BuildContext context, String action) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectChildScreen(
          userId: userId,
          action: action,
          isAdmin: false, // Specify that this is a user, not admin
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => navigateToSelectChildScreen(context, 'manage'),
              child: const Text('Manage Children'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => navigateToSelectChildScreen(context, 'view_statistics'),
              child: const Text('View Statistics'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => navigateToSelectChildScreen(context, 'view_participation'),
              child: const Text('View Participation'),
            ),
          ],
        ),
      ),
    );
  }
}
