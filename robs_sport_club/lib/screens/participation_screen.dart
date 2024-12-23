import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robs_sport_club/models/participation.dart';
import 'package:robs_sport_club/providers/data_provider.dart';

class ParticipationScreen extends StatelessWidget {
  const ParticipationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Participation Management'),
      ),
      body: FutureBuilder(
        future: dataProvider.fetchParticipations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final participations = dataProvider.participations;
            return ListView.builder(
              itemCount: participations.length,
              itemBuilder: (context, index) {
                final participation = participations[index];
                return ListTile(
                  title: Text('Type: ${participation.participationType}'),
                  subtitle: Text('Team: ${participation.teamNo}\nDate: ${participation.date.toLocal()}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog(context, participation, dataProvider);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context, dataProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, DataProvider dataProvider) {
    final typeController = TextEditingController();
    final teamController = TextEditingController();
    final dateController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Participation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Participation Type'),
              ),
              TextField(
                controller: teamController,
                decoration: const InputDecoration(labelText: 'Team Number'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newParticipation = Participation(
                  id: 0, // Placeholder, backend generates the ID
                  childId: 1, // Example child ID, adjust as needed
                  participationType: typeController.text,
                  teamNo: teamController.text,
                  date: DateTime.parse(dateController.text),
                  timeStart: DateTime.now(), // Example value
                  timeEnd: DateTime.now().add(const Duration(hours: 2)), // Example value
                  location: locationController.text,
                  createdBy: 1, // Example creator ID
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await dataProvider.addParticipation(newParticipation);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Participation participation, DataProvider dataProvider) {
    final typeController = TextEditingController(text: participation.participationType);
    final teamController = TextEditingController(text: participation.teamNo);
    final locationController = TextEditingController(text: participation.location);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Participation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Participation Type'),
              ),
              TextField(
                controller: teamController,
                decoration: const InputDecoration(labelText: 'Team Number'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedParticipation = Participation(
                  id: participation.id,
                  childId: participation.childId,
                  participationType: typeController.text,
                  teamNo: teamController.text,
                  date: participation.date,
                  timeStart: participation.timeStart,
                  timeEnd: participation.timeEnd,
                  location: locationController.text,
                  createdBy: participation.createdBy,
                  createdAt: participation.createdAt,
                  updatedAt: DateTime.now(),
                );
                await dataProvider.addParticipation(updatedParticipation); // Replace with update logic
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
