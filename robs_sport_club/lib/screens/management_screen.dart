import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robs_sport_club/providers/auth_provider.dart';
import 'package:robs_sport_club/screens/child_screen.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Management Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChildScreen()),
                );
              },
              child: const Text('Manage Children'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to Participation Management Screen
                Navigator.pushNamed(context, '/participation');
              },
              child: const Text('Manage Participation'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to User Management Screen
                Navigator.pushNamed(context, '/users');
              },
              child: const Text('Manage Users'),
            ),
          ],
        ),
      ),
    );
  }
}
