import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/user_screen.dart';
import 'screens/add_participation.dart';
import 'screens/child_statistics_screen.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RØBS Sport Club',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/user_screen': (context) => const UserScreen(userId: 1), // Placeholder userId
        '/add_participation': (context) => const AddParticipationScreen(),
        '/child_statistics_screen': (context) => const ChildStatisticsScreen(),
      },

      debugShowCheckedModeBanner: false,
    );
  }
}
