import 'package:flutter/material.dart';
import '../child_screens/select_child_screen.dart';
import '../user_screens/manage_user_screen.dart';

class UserScreen extends StatelessWidget {
  final int userId;

  const UserScreen({Key? key, required this.userId}) : super(key: key);

  // Navigate to the SelectChildScreen based on the action
  void navigateToSelectChildScreen(BuildContext context, String action) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectChildScreen(
          userId: userId,
          action: action,
          isAdmin: false, // Specify that this is a user, not admin
        ),
      ),
    );
  }

  // Navigate to ManageUserScreen
  void navigateToManageUserScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageUserScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDashboardCard(
              context,
              icon: Icons.group,
              title: 'Manage Children',
              subtitle: 'Add, edit, or remove children details',
              onTap: () => navigateToSelectChildScreen(context, 'manage'),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context,
              icon: Icons.bar_chart,
              title: 'View Statistics',
              subtitle: 'Check children’s performance stats',
              onTap: () => navigateToSelectChildScreen(context, 'view_statistics'),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context,
              icon: Icons.list_alt,
              title: 'View Participation',
              subtitle: 'See participation history',
              onTap: () => navigateToSelectChildScreen(context, 'view_participation'),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              context,
              icon: Icons.person,
              title: 'Manage User',
              subtitle: 'Update personal details',
              onTap: () => navigateToManageUserScreen(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.teal.withOpacity(0.2),
                child: Icon(icon, size: 28, color: Colors.teal),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
