import 'package:flutter/material.dart';
import 'participation_table_screen.dart'; // Ensure this import is correct

class ManageParticipationScreen extends StatelessWidget {
  const ManageParticipationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Participation')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ParticipationTableScreen(),
              ),
            );
          },
          child: const Text('View Participation Table'),
        ),
      ),
    );
  }
}
