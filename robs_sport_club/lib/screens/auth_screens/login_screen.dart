import 'package:flutter/material.dart';
import 'package:robs_sport_club/services/api_service.dart';
import '../user_screens/user_screen.dart';
import '../admin_screens/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Call the login API
      final response = await ApiService.login(
        emailController.text,
        passwordController.text,
      );

      print('Login Response: $response'); // Debugging log

      // Validate the response structure
      if (response.containsKey('token') && response.containsKey('user')) {
        final String role = response['user']['role'];
        final int userId = response['user']['id'];

        if (role == 'user') {
          // Navigate to UserScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserScreen(userId: userId),
            ),
          );
        } else if (role == 'admin') {
          // Navigate to AdminDashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDashboard(
                userId: userId,
                isAdmin: true,
              ),
            ),
          );
        } else {
          _showSnackBar('Unknown role, cannot proceed.');
        }
      } else {
        _showSnackBar('Unexpected response structure.');
      }
    } catch (e) {
      // Handle any errors during login
      print('Error during login: $e');
      _showSnackBar('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
