import 'package:flutter/material.dart';
import 'package:robs_sport_club/screens/add_participation.dart';
import 'package:robs_sport_club/screens/participation_list_screen.dart';
import 'package:robs_sport_club/screens/child_statistics_screen.dart';


class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

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
                    builder: (context) => const ParticipationListScreen(),
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
                    builder: (context) => const ChildStatisticsScreen(isAdmin: true),
                  ),
                );
              },
              child: const Text('Child Statistics'),
            ),
          ],
        ),
      ),
    );
  }
}
