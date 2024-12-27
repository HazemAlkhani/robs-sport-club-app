import 'package:flutter/material.dart';

class ManageParticipationScreen extends StatelessWidget {
  const ManageParticipationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Participation')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchParticipations(), // Replace with your API/service method
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No participation records found.'));
          }

          final participations = snapshot.data!;
          return ListView.builder(
            itemCount: participations.length,
            itemBuilder: (context, index) {
              final participation = participations[index];
              return Card(
                child: ListTile(
                  title: Text(
                      '${participation['childName']} - ${participation['participationType']}'),
                  subtitle: Text(
                      'Date: ${participation['date']}, Location: ${participation['location']}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.pushNamed(context, '/edit_participation',
                            arguments: participation);
                      } else if (value == 'delete') {
                        deleteParticipation(participation['id']); // Replace with your delete method
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchParticipations() async {
    // Implement your API call to fetch participations
    return [];
  }

  void deleteParticipation(int id) {
    // Implement your API call to delete participation
  }
}
