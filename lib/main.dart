import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/expense_service.dart';
import 'services/analytics_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await ExpenseService.init();

  AnalyticsService.appVersion = 'B';
  AnalyticsService.initParticipant();  // Set participant ID once on app start

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