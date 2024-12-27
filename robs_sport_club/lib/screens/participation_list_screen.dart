import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ParticipationListScreen extends StatelessWidget {
  final int? userId; // Optional, null for admin

  const ParticipationListScreen({Key? key, this.userId}) : super(key: key);

  Future<List<dynamic>> fetchParticipation() async {
    if (userId == null) {
      return await ApiService.getAllParticipations();
    } else {
      return await ApiService.getParticipationByUser(userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userId == null ? 'All Participation Records' : 'My Participation Records'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchParticipation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No participation records found.'));
          }

          final participationList = snapshot.data!;
          return ListView.builder(
            itemCount: participationList.length,
            itemBuilder: (context, index) {
              final participation = participationList[index];
              return Card(
                child: ListTile(
                  title: Text('${participation['childName']} - ${participation['participationType']}'),
                  subtitle: Text(
                    'Date: ${participation['date']}\n'
                        'Time: ${participation['timeStart']}\n'
                        'Duration: ${participation['duration']} minutes\n'
                        'Location: ${participation['location']}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
