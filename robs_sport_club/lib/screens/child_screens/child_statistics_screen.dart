import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/statistics.dart';
import '../../utils/utils.dart';

class ChildStatisticsScreen extends StatefulWidget {
  final bool isAdmin;
  final int? userId;
  final int? childId;

  const ChildStatisticsScreen({
    Key? key,
    required this.isAdmin,
    this.userId,
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
        if (widget.childId != null) {
          // Fetch statistics for a specific child
          final stat = await ApiService.getChildStatistics(widget.childId!);
          setState(() {
            statistics = [Statistics.fromJson(stat)];
          });
        } else {
          // Fetch all statistics for admin
          final statsList = await ApiService.getAllStatistics();
          setState(() {
            statistics = statsList.map((stat) => Statistics.fromJson(stat)).toList();
          });
        }
      } else {
        // Fetch statistics for the user's children
        final userStats = await ApiService.getUserStatistics(); // Existing backend endpoint
        setState(() {
          statistics = userStats.map((stat) => Statistics.fromJson(stat)).toList();
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load statistics. Error: $e';
      });
      showError(context, 'Failed to load statistics. Error: $e');
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
              onPressed: () {
                setState(() => errorMessage = null);
                fetchStatistics();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : statistics.isEmpty
          ? const Center(child: Text('No statistics available.'))
          : ListView.builder(
        itemCount: statistics.length,
        itemBuilder: (context, index) {
          final stat = statistics[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                stat.childName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Training Hours: ${stat.trainingHours}\nMatch Hours: ${stat.matchHours}',
              ),
            ),
          );
        },
      ),
    );
  }
}
