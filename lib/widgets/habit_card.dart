import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final int streak;
  final VoidCallback onTap;
  
  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.streak,
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
                isCompleted
                  ? Icons.check_circle
                  : Icons.circle_outlined,
                color: isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
                size: 30,
              ),
            ),
            
            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    habit.scheduleText,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              '🔥 $streak',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}