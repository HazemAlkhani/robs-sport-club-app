import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robs_sport_club/models/child.dart';
import 'package:robs_sport_club/providers/data_provider.dart';

class ChildScreen extends StatelessWidget {
  const ChildScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Children Management'),
      ),
      body: FutureBuilder(
        future: dataProvider.fetchChildren(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final children = dataProvider.children;
            return ListView.builder(
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return ListTile(
                  title: Text(child.childName),
                  subtitle: Text('Team: ${child.teamNo}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog(context, child, dataProvider);
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
    final nameController = TextEditingController();
    final teamController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Child'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Child Name'),
              ),
              TextField(
                controller: teamController,
                decoration: const InputDecoration(labelText: 'Team Number'),
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
                final newChild = Child(
                  id: 0, // Placeholder, backend generates the ID
                  childName: nameController.text,
                  userId: 1, // Example userId, adjust as needed
                  teamNo: teamController.text,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await dataProvider.addChild(newChild);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Child child, DataProvider dataProvider) {
    final nameController = TextEditingController(text: child.childName);
    final teamController = TextEditingController(text: child.teamNo);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Child'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Child Name'),
              ),
              TextField(
                controller: teamController,
                decoration: const InputDecoration(labelText: 'Team Number'),
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
                final updatedChild = Child(
                  id: child.id,
                  childName: nameController.text,
                  userId: child.userId,
                  teamNo: teamController.text,
                  createdAt: child.createdAt,
                  updatedAt: DateTime.now(),
                );
                await dataProvider.addChild(updatedChild); // Update logic can replace addChild
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
