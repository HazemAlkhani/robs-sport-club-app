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
      return 'N/A'; // Fallback to "N/A" if parsing fails
    }
  }

  String formatTime(String? time) {
    if (time == null || time.isEmpty) {
      return 'N/A';
    }
    try {
      if (RegExp(r'^\d{2}:\d{2}$').hasMatch(time)) {
        return time; // Time already in correct format
      }
      return DateFormat('HH:mm').format(DateTime.parse(time));
    } catch (e) {
      return 'N/A'; // Fallback to "N/A" if parsing fails
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
                      '${participation['ChildName'] ?? "N/A"} - ${participation['ParticipationType'] ?? "N/A"}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${formatDate(participation['Date'])}'),
                      Text('Time: ${formatTime(participation['TimeStart'])}'),
                      Text('Duration: ${participation['Duration'] ?? "N/A"} minutes'),
                      Text('Location: ${participation['Location'] ?? "N/A"}'),
                      Text('Coach: ${participation['Coach'] ?? "N/A"}'),
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
