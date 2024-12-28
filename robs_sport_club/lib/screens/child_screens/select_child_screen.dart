import 'package:flutter/material.dart';
import '../child_screens/manage_child_screen.dart';
import '../participation_screens/participation_list_screen.dart';
import '../../services/api_service.dart';
import '../child_screens/child_statistics_screen.dart';


class SelectChildScreen extends StatefulWidget {
  final int userId;
  final String action; // 'manage', 'view_statistics', 'view_participation'
  final bool isAdmin;

  const SelectChildScreen({
    Key? key,
    required this.userId,
    required this.action,
    required this.isAdmin,
  }) : super(key: key);


  @override
  _SelectChildScreenState createState() => _SelectChildScreenState();
}

class _SelectChildScreenState extends State<SelectChildScreen> {
  List<Map<String, dynamic>> children = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getChildrenByUser(widget.userId);
      setState(() {
        children = List<Map<String, dynamic>>.from(result);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch children: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleChildSelection(Map<String, dynamic> child) {
    switch (widget.action) {
      case 'manage':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManageChildScreen(
              userId: widget.userId,
              childId: child['Id'],
            ),
          ),
        );
        break;
      case 'view_participation':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParticipationListScreen(
              userId: widget.userId, // Pass the user ID
              isAdmin: widget.isAdmin,
            ),
          ),
        );
        break;
      case 'view_statistics':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildStatisticsScreen(
              isAdmin: widget.isAdmin,
              userId: widget.userId,
              childId: child['Id'], // Pass the child ID
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid action selected')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Child')),
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
              onPressed: fetchChildren,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : children.isEmpty
          ? const Center(child: Text('No children available'))
          : ListView.builder(
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          return Card(
            child: ListTile(
              title: Text(child['ChildName']),
              subtitle: Text('Team: ${child['TeamNo'] ?? 'N/A'}'),
              onTap: () => handleChildSelection(child),
            ),
          );
        },
      ),
    );
  }
}
