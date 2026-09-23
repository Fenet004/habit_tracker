import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              onPressed: onTap,
              icon: Icon(
                habit.isCompleted
                  ? Icons.check_circle
                  : Icons.circle_outlined,
                color: habit.isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
                size: 30,
              ),
            ),
            
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      decoration: habit.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    habit.frequencyText,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              habit.streak!=0
                ? '🔥 ${habit.streak}'
                : 'No streak yet',
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