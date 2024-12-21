import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:robs_sport_club/providers/auth_provider.dart';
import 'package:robs_sport_club/screens/login_screen.dart';
import 'package:robs_sport_club/screens/register_screen.dart';
import 'package:robs_sport_club/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure dotenv is loaded before proceeding
  try {
    await dotenv.load(fileName: ".env");
    print('DotEnv loaded successfully. Base URL: ${dotenv.env['BASE_URL']}');
  } catch (e) {
    print('Error loading DotEnv: $e');
    rethrow; // Ensure any initialization issue is logged.
  }


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        log('Initializing AuthProvider...');
        return AuthProvider();
      },
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false, // Remove debug banner
            title: 'RØBS Sport Club Management App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            initialRoute: auth.isAuthenticated ? '/home' : '/',
            routes: {
              '/': (context) => const WelcomeScreen(),
              '/login': (context) => LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/register': (context) => RegisterScreen(),
              '/management': (context) => const ManagementScreen(),
            },
          );
        },
      ),
    );
  }
}

// HomeScreen.dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the RØBS Sport Club Management App!'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/management');
              },
              child: const Text('Go to Management Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

// ManagementScreen.dart
class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Management Screen Features'),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
