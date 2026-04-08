import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/expense_service.dart';
import 'services/analytics_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await ExpenseService.init();

  AnalyticsService.appVersion = 'B';
  AnalyticsService.initParticipant();  // Set participant ID once on app start
  
  // Enable Firebase Analytics Debug Mode for development
  // Remove this in production to see events after 24 hours
  if (kDebugMode) {
    await AnalyticsService.enableDebugMode();
    await AnalyticsService.checkFirebaseStatus();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager Version B',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1A73E8),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}