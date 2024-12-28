import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screens/login_screen.dart';
import 'screens/auth_screens/register_screen.dart';
import 'screens/admin_screens/admin_dashboard.dart';
import 'screens/user_screens/user_screen.dart';
import 'screens/participation_screens/add_participation.dart';
import 'screens/child_screens/child_statistics_screen.dart';

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
        '/admin_dashboard': (context) =>
            AdminDashboard(userId: 1, isAdmin: true),
        '/user_screen': (context) => UserScreen(userId: 1),
        '/add_participation': (context) => const AddParticipationScreen(),
        '/child_statistics_screen': (context) =>
            ChildStatisticsScreen(userId: 1, childId: 1, isAdmin: false),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
