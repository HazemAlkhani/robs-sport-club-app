import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddChildScreen extends StatefulWidget {
  final int userId;

  const AddChildScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddChildScreenState createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController sportTypeController = TextEditingController();
  String? selectedTeam;

  final List<String> teams = ["Team A", "Team B", "Team C"]; // Example teams

  bool isLoading = false;

  Future<void> addChild() async {
    if (childNameController.text.isEmpty ||
        sportTypeController.text.isEmpty ||
        selectedTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.addChild({
        'ChildName': childNameController.text,
        'TeamNo': selectedTeam!,
        'SportType': sportTypeController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child added successfully.')),
      );

      Navigator.pop(context); // Navigate back after adding
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding child: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Child')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: childNameController,
              decoration: const InputDecoration(labelText: 'Child Name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedTeam,
              onChanged: (value) {
                setState(() {
                  selectedTeam = value;
                });
              },
              items: teams
                  .map((team) => DropdownMenuItem(
                value: team,
                child: Text(team),
              ))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Select Team'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sportTypeController,
              decoration: const InputDecoration(labelText: 'Sport Type'),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: addChild,
              child: const Text('Add Child'),
            ),
          ],
        ),
      ),
    );
  }
}
