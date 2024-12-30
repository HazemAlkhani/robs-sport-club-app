import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddChildScreen extends StatefulWidget {
  final int userId;

  const AddChildScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddChildScreenState createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final TextEditingController childNameController = TextEditingController();
  String? selectedTeam;
  String? selectedSportType;

  final List<String> teams = ["U5", "U6", "U7", "U8", "U9", "U10", "U11", "U12", "U13", "U14", "U15"];
  final List<String> sportTypes = ["Football", "Handball", "Basketball", "Gymnastic"];

  bool isLoading = false;

  Future<void> addChild() async {
    if (childNameController.text.isEmpty || selectedTeam == null || selectedSportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            childNameController.text.isEmpty
                ? 'Child Name is required.'
                : selectedTeam == null
                ? 'Please select a team.'
                : 'Please select a sport type.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.addChild({
        'ChildName': childNameController.text.trim(),
        'TeamNo': selectedTeam!,
        'SportType': selectedSportType!,
        'UserId': widget.userId, // Ensure UserId is passed
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child added successfully.')),
      );

      // Clear inputs after successful addition
      childNameController.clear();
      setState(() {
        selectedTeam = null;
        selectedSportType = null;
      });

      // Optionally navigate back
      Navigator.pop(context);
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
      body: SingleChildScrollView(
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
            DropdownButtonFormField<String>(
              value: selectedSportType,
              onChanged: (value) {
                setState(() {
                  selectedSportType = value;
                });
              },
              items: sportTypes
                  .map((sport) => DropdownMenuItem(
                value: sport,
                child: Text(sport),
              ))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Select Sport Type'),
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
