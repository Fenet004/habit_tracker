import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../widgets/habit_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Habit> habits = [
    Habit(
      name: 'Drink Water',
      frequency: HabitFrequency.daily,
      streak: 12,
      isCompleted: true,
    ),

    Habit(
      name: 'Workout',
      frequency: HabitFrequency.weekdays,
      streak: 4,
      isCompleted: false,
    ),

    Habit(
      name: 'Read 30 Minutes',
      frequency: HabitFrequency.daily,
      streak: 7,
      isCompleted: true,
    ),

    Habit(
      name: 'Practice Coding',
      frequency: HabitFrequency.daily,
      streak: 5,
      isCompleted: false,
    ),

    Habit(
      name: 'Meditate',
      frequency: HabitFrequency.daily,
      streak: 3,
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final completedHabits = habits.where((habit) => habit.isCompleted).length;
    final totalHabits = habits.length;
    final progress = totalHabits == 0 ? 0.0 : completedHabits / totalHabits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Good morning 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Saturday, September 19',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              "Today's Progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completedHabits of $totalHabits completed',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
            ),

            const SizedBox(height: 32),

            const Text(
              'Today',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ...habits.map(
              (habit) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: HabitCard(
                  habit: habit,
                ),
              ),
            ), 
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print('Add habit pressed');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
      ),
    );
  }
}

