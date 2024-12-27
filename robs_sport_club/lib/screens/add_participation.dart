import 'package:flutter/material.dart';
import '../widgets/multi_select_dropdown.dart'; // Import for multi-select functionality

class AddParticipationScreen extends StatefulWidget {
  const AddParticipationScreen({Key? key}) : super(key: key);

  @override
  AddParticipationScreenState createState() => AddParticipationScreenState();
}

class AddParticipationScreenState extends State<AddParticipationScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String? selectedTeam;
  List<String> selectedChildren = [];
  String participationType = "Match";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Participation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedTeam,
              onChanged: (value) {
                setState(() {
                  selectedTeam = value;
                });
              },
              items: ["Team A", "Team B", "Team C"]
                  .map((team) => DropdownMenuItem(
                value: team,
                child: Text(team),
              ))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Select Team'),
            ),
            const SizedBox(height: 16),
            MultiSelectDropdown(
              items: ["Child 1", "Child 2", "Child 3"],
              onSelectionChanged: (selected) {
                setState(() {
                  selectedChildren = selected;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: participationType,
              onChanged: (value) {
                setState(() {
                  participationType = value!;
                });
              },
              items: ["Match", "Training"]
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Participation Type'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date'),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null) {
                  dateController.text = pickedDate.toIso8601String();
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Start Time (HH:mm)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: 'Duration (minutes)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Save participation logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Participation added successfully!')),
                );
              },
              child: const Text('Add Participation'),
            ),
          ],
        ),
      ),
    );
  }
}
