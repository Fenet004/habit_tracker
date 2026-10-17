import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: HabitTrackerApp(),
    ),
  );
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false ,
      title: 'Habit Tracker',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}