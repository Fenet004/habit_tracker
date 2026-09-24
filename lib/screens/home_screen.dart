import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../widgets/habit_card.dart';
import 'add_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final List<Habit> habits = [
    const Habit(
      name: 'Drink Water',
      frequency: HabitFrequency.daily,
      streak: 12,
      isCompleted: true,
    ),

    const Habit(
      name: 'Workout',
      frequency: HabitFrequency.weekdays,
      streak: 4,
      isCompleted: false,
    ),

    const Habit(
      name: 'Read 30 Minutes',
      frequency: HabitFrequency.daily,
      streak: 7,
      isCompleted: true,
    ),

    const Habit(
      name: 'Practice Coding',
      frequency: HabitFrequency.daily,
      streak: 5,
      isCompleted: false,
    ),

    const Habit(
      name: 'Meditate',
      frequency: HabitFrequency.daily,
      streak: 0,
      isCompleted: false,
    ),
  ];

  void toggleHabit(int index) {
    setState(() {
      final habit = habits[index];

      habits[index] = habit.copyWith(
        isCompleted: !habit.isCompleted,
      ); 
    });
  }

  Future<void> addHabit() async {
    final newHabit = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddHabitScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (newHabit == null) {
      return;
    }

    setState(() {
      habits.add(newHabit);
    });
  }

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

            ...List.generate(
              habits.length,
              (index) {
                final habit = habits[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom:8),
                  child: HabitCard(
                    habit: habit,
                    onTap: () {
                      toggleHabit(index);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addHabit,
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
      ),
    );
  }
}



