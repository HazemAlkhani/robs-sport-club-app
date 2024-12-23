import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:robs_sport_club/providers/auth_provider.dart';
import 'package:robs_sport_club/screens/home_screen.dart';
import 'package:robs_sport_club/screens/login_screen.dart';
import 'package:robs_sport_club/screens/register_screen.dart';
import 'package:robs_sport_club/screens/management_screen.dart';
import 'package:robs_sport_club/screens/participation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final filePath = "C:/Users/hazem/AppManagement/robs_sport_club/.env";
    log('Attempting to load .env file from: $filePath');

    final envFile = File(filePath);
    if (!envFile.existsSync()) {
      throw FileSystemException('The .env file does not exist', filePath);
    } else {
      log('File found at: $filePath');
      log('File content:\n${await envFile.readAsString()}');
    }

    await dotenv.load(fileName: filePath);
    log('DotEnv loaded successfully. BASE_URL: ${dotenv.env['BASE_URL']}');
  } catch (e, stackTrace) {
    log('Error loading .env: $e', level: 1000);
    log('Stack trace: $stackTrace', level: 1000);
    return; // Prevent app from launching if .env loading fails
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'RØBS Sport Club',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/management': (context) => const ManagementScreen(),
          '/participation': (context) => const ParticipationScreen(),
        },
      ),
    );
  }
}
