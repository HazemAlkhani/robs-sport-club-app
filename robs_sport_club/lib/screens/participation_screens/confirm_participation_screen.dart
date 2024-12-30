import 'package:flutter/material.dart';

class ConfirmParticipationScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  ConfirmParticipationScreen({required this.data, Key? key}) : super(key: key);

  void submitParticipation(BuildContext context) {
    // Here you can call an API or perform any action to finalize the participation
    print('Submitting participation data: $data');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Participation confirmed successfully!')),
    );

    // Navigate back to the previous screen or to another screen after confirmation
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Participation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participation Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Children: ${data['children'].join(', ')}'),
            Text('Participation Type: ${data['participationType']}'),
            Text('Date: ${data['date']}'),
            Text('Start Time: ${data['startTime']}'),
            Text('Duration: ${data['duration']} minutes'),
            Text('Location: ${data['location']}'),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => submitParticipation(context),
                child: const Text('Confirm and Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
