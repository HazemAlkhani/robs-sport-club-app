import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robs_sport_club/providers/auth_provider.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
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

                try {
                  await authProvider.register(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                    name: nameController.text.trim(),
                  );

                  if (authProvider.isAuthenticated && context.mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                } catch (e) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Registration Failed'),
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
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
