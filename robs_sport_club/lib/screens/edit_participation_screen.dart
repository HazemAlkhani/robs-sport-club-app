import 'package:flutter/material.dart';

class EditParticipationScreen extends StatefulWidget {
  final Map<String, dynamic> participation;

  const EditParticipationScreen({Key? key, required this.participation}) : super(key: key);

  @override
  EditParticipationScreenState createState() =>
      EditParticipationScreenState();
}

class EditParticipationScreenState extends State<EditParticipationScreen> {
  late TextEditingController childNameController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  late TextEditingController durationController;
  late TextEditingController locationController;

  @override
  void initState() {
    super.initState();
    final participation = widget.participation;
    childNameController = TextEditingController(text: participation['childName']);
    dateController = TextEditingController(text: participation['date']);
    timeController = TextEditingController(text: participation['timeStart']);
    durationController = TextEditingController(text: participation['duration'].toString());
    locationController = TextEditingController(text: participation['location']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Participation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: childNameController,
              decoration: const InputDecoration(labelText: 'Child Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date'),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(dateController.text),
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
                updateParticipation(); // Replace with your API/service method
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void updateParticipation() {
    // Implement your API call to update participation
  }
}
