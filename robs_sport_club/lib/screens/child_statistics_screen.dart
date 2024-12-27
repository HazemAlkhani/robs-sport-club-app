import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChildStatisticsScreen extends StatefulWidget {
  final bool isAdmin; // Admin or user role
  final int? userId; // User ID for filtering, null for admin

  const ChildStatisticsScreen({Key? key, this.isAdmin = false, this.userId}) : super(key: key);

  @override
  _ChildStatisticsScreenState createState() => _ChildStatisticsScreenState();
}

class _ChildStatisticsScreenState extends State<ChildStatisticsScreen> {
  List<Map<String, dynamic>> statistics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (widget.isAdmin) {
        // Fetch all statistics for admin
        statistics = (await ApiService.fetchAllChildStatistics()).cast<Map<String, dynamic>>();
      } else {
        // Fetch statistics for a specific user
        statistics = (await ApiService.fetchChildStatisticsByUser(widget.userId!))
            .cast<Map<String, dynamic>>();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading statistics: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Child Statistics')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : statistics.isEmpty
          ? const Center(
        child: Text(
          'No statistics available at the moment. Please try again later.',
          textAlign: TextAlign.center,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: statistics.length,
          itemBuilder: (context, index) {
            final stat = statistics[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(stat['childName']),
                subtitle: Text(
                  'Training Hours: ${stat['trainingHours']}\n'
                      'Match Hours: ${stat['matchHours']}',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
