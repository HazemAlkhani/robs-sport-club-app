import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robs_sport_club/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                bool isAuthenticated = false;

                try {
                  // Start login process
                  await authProvider.login(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                  isAuthenticated = authProvider.isAuthenticated;
                } catch (e) {
                  // Show error message if login fails
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Login Failed'),
                        content: Text(e.toString()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }

                // Navigate to home screen on success
                if (isAuthenticated && context.mounted) {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
