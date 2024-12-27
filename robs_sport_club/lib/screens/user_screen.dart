import 'package:flutter/material.dart';
import 'participation_list_screen.dart';
import 'child_statistics_screen.dart';
import 'add_child_screen.dart';

class UserScreen extends StatelessWidget {
  final int userId; // Pass the user's ID to fetch user-specific data

  const UserScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParticipationListScreen(userId: userId),
                  ),
                );
              },
              child: const Text('View Participation'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChildStatisticsScreen(
                      isAdmin: false, // Set to false for user-specific data
                      userId: userId,
                    ),
                  ),
                );
              },
              child: const Text('View Child Statistics'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddChildScreen(userId: userId),
                  ),
                );
              },
              child: const Text('Add Child'),
            ),
          ],
        ),
      ),
    );
  }
}
