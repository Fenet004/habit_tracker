import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../widgets/habit_card.dart';
import 'add_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<Habit> habits;

  @override
  void initState() {
    super.initState();

    final today = dateOnly(DateTime.now());

    habits = [
      Habit(
        name: 'Drink Water',
        repeatDays: HabitDay.values.toSet(),
        createdAt: today,
        completedDates: {today},
      ),

      Habit(
        name: 'Workout',
        repeatDays: {
          HabitDay.monday,
          HabitDay.wednesday,
          HabitDay.friday,
        },
        createdAt: today,
      ),

      Habit(
        name: 'Read 30 Minutes',
        repeatDays: HabitDay.values.toSet(),
        createdAt: today,
        completedDates: {today},
      ),

      Habit(
        name: 'Practice Coding',
        repeatDays: {
          HabitDay.monday,
          HabitDay.tuesday,
          HabitDay.wednesday,
          HabitDay.thursday,
          HabitDay.friday,
        },
        createdAt: today,
      ),

      Habit(
        name: 'Meditate',
        repeatDays: HabitDay.values.toSet(),
        createdAt: today,
      ),
    ];
    
  }

  void toggleHabit(
    Habit habit,
    DateTime date,
  ) {
    final index = habits.indexOf(habit);

    if (index == -1) {
      return;
    }

    setState(() {
      habits[index] = habit.toggleCompletionOn(date);
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
    final today = dateOnly(DateTime.now());
    final formattedDate = DateFormat('EEEE, MMMM d').format(today);

    final todaysHabits = habits
        .where(
          (habit) => habit.isScheduledOn(today),
        )
        .toList();

    final completedHabits = todaysHabits
        .where(
          (habit) => habit.isCompletedOn(today),
        )
        .length;

    final totalHabits = todaysHabits.length;
    final progress = 
        totalHabits == 0 
            ? 0.0 
            : completedHabits / totalHabits;

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
              formattedDate,
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

            if (todaysHabits.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 40,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No habits scheduled today',
                      ),
                    ],
                  ),
                ),
              )

            else
              ...todaysHabits.map(
                (habit) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8,
                    ),
                    child: HabitCard(
                      habit: habit,
                      isCompleted: habit.isCompletedOn(today),
                      onTap: () {
                        toggleHabit(habit, today);
                      },
                    ),
                  );
                },
              )
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



