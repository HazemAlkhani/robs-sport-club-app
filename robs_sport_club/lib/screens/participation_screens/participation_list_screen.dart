import 'package:flutter/material.dart';
import 'participation_table_screen.dart';
import '../../services/api_service.dart';


class ParticipationListScreen extends StatefulWidget {
  final bool isAdmin;
  final int? userId;

  const ParticipationListScreen({
    Key? key,
    required this.isAdmin,
    this.userId,
  }) : super(key: key);

  @override
  State<ParticipationListScreen> createState() => _ParticipationListScreenState();
}

class _ParticipationListScreenState extends State<ParticipationListScreen> {
  late Future<List<Map<String, dynamic>>> _participationsFuture;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _participationsFuture = fetchParticipations();
  }

  Future<List<Map<String, dynamic>>> fetchParticipations() async {
    try {
      final participations = await ApiService.getAllParticipations();
      participations.sort((a, b) {
        final dateA = DateTime.parse(a['date']);
        final dateB = DateTime.parse(b['date']);
        return dateA.compareTo(dateB);
      });
      return participations.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch participations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasNavigated) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ParticipationTableScreen(),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Participations'),
      ),
      body: const Center(
        child: CircularProgressIndicator(), // Optional: Indicates processing
      ),
    );
  }
}
