import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class ParticipationListScreen extends StatelessWidget {
  final bool isAdmin;
  final int? userId;
  final int? childId;

  const ParticipationListScreen({
    Key? key,
    required this.isAdmin,
    this.userId,
    this.childId,
  }) : super(key: key);

  Future<List<dynamic>> fetchParticipation() async {
    try {
      // Fetch participations filtered by childId if provided
      if (childId != null) {
        return await ApiService.getParticipationsByChild(childId!);
      }
      // Fetch all participations if no childId is specified
      return await ApiService.getAllParticipations();
    } catch (e) {
      throw Exception('Failed to fetch participations: $e');
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return 'N/A';
    }
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    } catch (e) {
      print('Error parsing date: $date');
      return 'N/A';
    }
  }

  String formatTime(String? time) {
    if (time == null || time.isEmpty) {
      return 'N/A';
    }
    try {
      // Handle unformatted time like '1155' by inserting a colon
      if (RegExp(r'^\d{4}$').hasMatch(time)) {
        time = '${time.substring(0, 2)}:${time.substring(2)}';
      }
      return time; // Assume the time is now formatted correctly
    } catch (e) {
      print('Error parsing time: $time');
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'All Participation Records' : 'My Participation Records'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchParticipation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  Text('Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No participation records found.'));
          }

          final participationList = snapshot.data!;
          return ListView.builder(
            itemCount: participationList.length,
            itemBuilder: (context, index) {
              final participation = participationList[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    '${participation['childName'] ?? "N/A"} - ${participation['participationType'] ?? "N/A"}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${formatDate(participation['date'])}'),
                      Text('Time: ${formatTime(participation['timeStart'])}'),
                      Text('Duration: ${participation['duration'] ?? "N/A"} minutes'),
                      Text('Location: ${participation['location'] ?? "N/A"}'),
                      Text('Coach: ${participation['coach'] ?? "N/A"}'),
                    ],
                  ),
                  trailing: isAdmin
                      ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Navigate to edit participation screen
                    },
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
