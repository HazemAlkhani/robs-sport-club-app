import 'package:flutter/material.dart';
import 'package:robs_sport_club/services/api_service.dart'; // Ensure your API integration here
import 'user_screen.dart'; // User-specific screen
import 'admin_dashboard.dart'; // Admin-specific screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void login() async {
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

      // Check if the response contains the expected data
      if (response.containsKey('token') && response.containsKey('user')) {
        String role = response['user']['role'];
        if (role == 'user') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserScreen(userId: response['user']['id']),
            ),
          );
        } else if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDashboard(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unknown role, cannot proceed')),
          );
        }
      } else {
        // Show an error if the response doesn't contain expected data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected response structure')),
        );
      }
    } catch (e) {
      // Handle errors
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
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
