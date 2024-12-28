import 'package:flutter/material.dart';
import 'package:robs_sport_club/screens/participation_screens/add_participation.dart';
import 'package:robs_sport_club/screens/participation_screens/participation_list_screen.dart';
import 'package:robs_sport_club/screens/child_screens/child_statistics_screen.dart';

class AdminDashboard extends StatelessWidget {
  final int userId;
  final bool isAdmin;

  const AdminDashboard({
    Key? key,
    required this.userId,
    required this.isAdmin,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddParticipationScreen(),
                  ),
                );
              },
              child: const Text('Add Participation'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParticipationListScreen(
                      userId: userId,
                      isAdmin: isAdmin,
                    ),
                  ),
                );
              },
              child: const Text('Participation List'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChildStatisticsScreen(
                      isAdmin: isAdmin,
                      userId: userId,
                      childId: null, // Passing `null` for admin
                    ),
                  ),
                );
              },
              child: const Text('View Child Statistics'),
            ),
          ],
        ),
      ),
    );
  }
}
