import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:robs_sport_club/providers/auth_provider.dart';
import 'package:robs_sport_club/screens/login_screen.dart';
import 'package:robs_sport_club/screens/register_screen.dart';
import 'package:robs_sport_club/screens/welcome_screen.dart';
import 'package:robs_sport_club/screens/home_screen.dart';
import 'package:robs_sport_club/screens/management_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final filePath = "C:/Users/hazem/AppManagement/robs_sport_club/.env";
    log('Attempting to load .env file from: $filePath');
    if (!File(filePath).existsSync()) {
      log('.env file does not exist at path: $filePath', level: 1000);
    } else {
      log('.env file found at path: $filePath');
    }
    await dotenv.load(fileName: filePath);
    log('DotEnv loaded successfully. BASE_URL: ${dotenv.env['BASE_URL']}');
  } catch (e) {
    log('Error loading DotEnv: $e', level: 1000);
    rethrow;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
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
