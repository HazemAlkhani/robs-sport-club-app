import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // Ensure ApiService has the necessary methods
import 'confirm_participation_screen.dart'; // Import for navigation to the confirmation screen
import '../../widgets/multi_select_dropdown.dart'; // Import for multi-select dropdown

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
        const SnackBar(content: Text('Please select sport type and team first.')),
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
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch children: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToConfirmParticipation() {
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

    final participationData = {
      'children': selectedChildren,
      'participationType': participationType,
      'date': dateController.text,
      'startTime': timeController.text,
      'duration': int.tryParse(durationController.text) ?? 0,
      'location': locationController.text,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmParticipationScreen(data: participationData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Participation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              decoration: const InputDecoration(labelText: 'Select Sport Type'),
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
              decoration: const InputDecoration(labelText: 'Select Team'),
            ),
            const SizedBox(height: 16),
            if (isLoading) const CircularProgressIndicator(),
            if (!isLoading && childNames.isNotEmpty)
              MultiSelectDropdown(
                items: childNames,
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
              onPressed: navigateToConfirmParticipation,
              child: const Text('Confirm Participation'),
            ),
          ],
        ),
      ),
    );
  }
}
