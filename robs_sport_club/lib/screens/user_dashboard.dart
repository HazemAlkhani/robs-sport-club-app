import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Your Dashboard!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/view-participation');
              },
              child: const Text('View Participation Records'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/view-statistics');
              },
              child: const Text('View Training Statistics'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/update-profile');
              },
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
