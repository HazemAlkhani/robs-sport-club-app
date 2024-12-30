import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EditParticipationScreen extends StatefulWidget {
  final Map<String, dynamic> participation;

  const EditParticipationScreen({Key? key, required this.participation}) : super(key: key);

  @override
  State<EditParticipationScreen> createState() => _EditParticipationScreenState();
}

class _EditParticipationScreenState extends State<EditParticipationScreen> {
  late TextEditingController dateController;
  late TextEditingController timeController;
  late TextEditingController locationController;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController(text: widget.participation['date']);
    timeController = TextEditingController(text: widget.participation['timeStart']);
    locationController = TextEditingController(text: widget.participation['location']);
  }

  Future<void> updateParticipation() async {
    final updatedParticipation = {
      'id': widget.participation['id'],
      'date': dateController.text,
      'timeStart': timeController.text,
      'location': locationController.text,
    };

    try {
      await ApiService.updateParticipation(updatedParticipation);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Participation updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update participation: $e')),
      );
    }
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
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Start Time (HH:MM)'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: updateParticipation,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    locationController.dispose();
    super.dispose();
  }
}
