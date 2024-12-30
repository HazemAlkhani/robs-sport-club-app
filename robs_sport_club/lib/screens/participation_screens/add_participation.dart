import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/multi_select_dropdown.dart';

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

  String? selectedSportType;
  String? selectedTeam;
  List<String> childNames = [];
  List<String> selectedChildren = [];
  String participationType = "Match";

  bool isLoading = false;

  Future<void> fetchChildren() async {
    if (selectedSportType == null || selectedTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select sport type and team first.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final children = await ApiService.getChildrenByTeamAndSport(
        selectedTeam!,
        selectedSportType!,
      );
      setState(() {
        childNames = children.map<String>((child) => child['ChildName'].toString()).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching children: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submitParticipation() async {
    if (selectedChildren.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        durationController.text.isEmpty ||
        locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    final data = {
      'children': selectedChildren,
      'participationType': participationType,
      'date': dateController.text,
      'startTime': timeController.text,
      'duration': int.tryParse(durationController.text) ?? 0,
      'location': locationController.text,
    };

    try {
      await ApiService.addParticipation(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Participation added successfully')),
      );
      Navigator.pop(context); // Go back after success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add participation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Participation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: selectedSportType,
              onChanged: (value) {
                setState(() {
                  selectedSportType = value;
                  selectedTeam = null;
                  childNames = [];
                  selectedChildren = [];
                });
              },
              items: ["Football", "Handball", "Basketball", "Gymnastic"]
                  .map((sport) => DropdownMenuItem(
                value: sport,
                child: Text(sport),
              ))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Sport Type'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedTeam,
              onChanged: (value) {
                setState(() {
                  selectedTeam = value;
                  fetchChildren();
                });
              },
              items: ["U5", "U6", "U7", "U8", "U9", "U10", "U11", "U12", "U13", "U14", "U15"]
                  .map((team) => DropdownMenuItem(
                value: team,
                child: Text(team),
              ))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Team'),
            ),
            const SizedBox(height: 16),
            MultiSelectDropdown(
              items: childNames,
              onSelectionChanged: (selected) {
                setState(() {
                  selectedChildren = selected;
                });
              },
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
                  dateController.text = pickedDate.toIso8601String().split('T').first;
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
              onPressed: submitParticipation,
              child: const Text('Add Participation'),
            ),
          ],
        ),
      ),
    );
  }
}
