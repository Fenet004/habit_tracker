import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  '3 of 5 completed',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                Text(
                  '60%',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const LinearProgressIndicator(
              value: 0.6,
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

            const HabitCard(
              name: 'Drink Water',
              frequency: 'Everyday',
              streak: 12,
              isCompleted: true,
            ),

            const SizedBox(height:8),

            const HabitCard(
              name: 'Workout',
              frequency: 'Mon • Wed • Fri',
              streak: 4,
              isCompleted: false,
            ),

            const SizedBox(height: 8),

            const HabitCard(
              name: 'Read 30 Minutes',
              frequency: 'Every day',
              streak: 7,
              isCompleted: true,
            ),

            const SizedBox(height: 8),

            const HabitCard(
              name: 'Practice Coding',
              frequency: 'Every day',
              streak: 5,
              isCompleted: true,
            ),

            const SizedBox(height: 8),

            const HabitCard(
              name: 'Meditate',
              frequency: 'Every day',
              streak: 5,
              isCompleted: false,
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

class HabitCard extends StatelessWidget {
  final String name;
  final String frequency;
  final int streak;
  final bool isCompleted;

  const HabitCard({
    super.key,
    required this.name,
    required this.frequency,
    required this.streak,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isCompleted
                ? Icons.check_circle
                : Icons.circle_outlined,
              size: 30,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    frequency,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              '🔥 $streak',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}