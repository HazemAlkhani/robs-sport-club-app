import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/statistics.dart';

class ChildStatisticsScreen extends StatefulWidget {
  final bool isAdmin;
  final int? userId; // Add userId as a field
  final int? childId;

  const ChildStatisticsScreen({
    Key? key,
    required this.isAdmin,
    this.userId, // Include userId in the constructor
    this.childId,
  }) : super(key: key);

  @override
  _ChildStatisticsScreenState createState() => _ChildStatisticsScreenState();
}

class _ChildStatisticsScreenState extends State<ChildStatisticsScreen> {
  List<Statistics> statistics = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (widget.isAdmin) {
        if (widget.childId == null) {
          // Admin fetching all statistics
          statistics = await ApiService.fetchAllChildStatistics();
        } else {
          // Admin fetching statistics for a specific child
          final stat = await ApiService.fetchChildStatisticsById(widget.childId!);
          statistics = [Statistics.fromJson(stat as Map<String, dynamic>)];
        }
      } else {
        // Parent fetching statistics for their children
        statistics = (await ApiService.getUserStatistics())
            .map((json) => Statistics.fromJson(json))
            .toList();
      }
    } catch (e) {
      errorMessage = 'Failed to load statistics. Please check your connection and try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
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
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchStatistics,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
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
                title: Text(
                  stat.childName ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Training Hours: ${stat.trainingHours ?? 0}\n'
                      'Match Hours: ${stat.matchHours ?? 0}',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
