import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'edit_child_screen.dart'; // Import EditChildScreen to navigate to it

class ManageChildScreen extends StatelessWidget {
  final int userId; // ID of the logged-in user
  final int childId; // ID of the selected child
  final String childName; // Name of the child

  const ManageChildScreen({
    Key? key,
    required this.userId,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  Future<void> deleteChild(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete $childName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteChild(childId); // Call API to delete the child
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$childName deleted successfully.')),
        );
        Navigator.pop(context); // Navigate back after deletion
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete $childName: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Child')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditChildScreen(
                      userId: userId, // Pass the required userId
                      childId: childId, // Pass the required childId
                    ),
                  ),
                );
              },
              child: const Text('Edit Child Details'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => deleteChild(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              child: const Text('Delete Child'),
            ),
          ],
        ),
      ),
    );
  }
}
