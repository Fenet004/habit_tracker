import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../widgets/habit_card.dart';
import 'habit_form_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _addHabit(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result =
        await Navigator.push<HabitFormResult>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const HabitFormScreen(),
      ),
    );

    if (!context.mounted ||
        result == null) {
      return;
    }

    if (result.action !=
        HabitFormAction.save) {
      return;
    }

    try {
      await ref
          .read(
            habitControllerProvider
                .notifier,
          )
          .addHabit(
            result.habit,
          );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save habit',
          ),
        ),
      );
    }
  }

  Future<void> _editHabit(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) async {
    final result =
        await Navigator.push<HabitFormResult>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HabitFormScreen(
          habit: habit,
        ),
      ),
    );

    if (!context.mounted ||
        result == null) {
      return;
    }

    final controller = ref.read(
      habitControllerProvider.notifier,
    );

    try {
      switch (result.action) {
        case HabitFormAction.save:
          await controller.updateHabit(
            result.habit,
          );
          break;

        case HabitFormAction.delete:
          await controller.deleteHabit(
            result.habit,
          );

          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                '${result.habit.name} deleted',
              ),
            ),
          );

          break;
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Could not update habit',
          ),
        ),
      );
    }
  }

  Future<void> _toggleHabit(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
    DateTime date,
  ) async {
    try {
      await ref
          .read(
            habitControllerProvider
                .notifier,
          )
          .toggleCompletion(
            habit,
            date,
          );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Could not update habit',
          ),
        ),
      );
    }
  }

  Widget _buildHome(
    BuildContext context,
    WidgetRef ref,
    List<Habit> habits,
  ) {
    final today =
        dateOnly(DateTime.now());

    final formattedDate =
        DateFormat(
      'EEEE, MMMM d',
    ).format(today);

    final todaysHabits = habits
        .where(
          (habit) =>
              habit.isScheduledOn(today),
        )
        .toList();

    final completedHabits =
        todaysHabits
            .where(
              (habit) =>
                  habit.isCompletedOn(
                today,
              ),
            )
            .length;

    final totalHabits =
        todaysHabits.length;

    final progress =
        totalHabits == 0
            ? 0.0
            : completedHabits /
                totalHabits;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Habit Tracker',
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Good morning 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 15,
                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            const Text(
              "Today's Progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text(
                  '$completedHabits of '
                  '$totalHabits completed',
                  style:
                      const TextStyle(
                    fontSize: 15,
                  ),
                ),

                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors
                        .grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
            ),

            const SizedBox(
              height: 32,
            ),

            const Text(
              'Today',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            if (todaysHabits.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  vertical: 40,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons
                            .check_circle_outline,
                        size: 48,
                      ),

                      SizedBox(
                        height: 12,
                      ),

                      Text(
                        'No habits '
                        'scheduled today',
                      ),
                    ],
                  ),
                ),
              )
            else
              ...todaysHabits.map(
                (habit) {
                  return Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      bottom: 8,
                    ),
                    child: HabitCard(
                      habit: habit,

                      isCompleted:
                          habit
                              .isCompletedOn(
                        today,
                      ),

                      streak:
                          habit.currentStreak(
                        today,
                      ),

                      onToggle: () {
                        _toggleHabit(
                          context,
                          ref,
                          habit,
                          today,
                        );
                      },

                      onOpen: () {
                        _editHabit(
                          context,
                          ref,
                          habit,
                        );
                      },
                    ),
                  );
                },
              ),

            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),

      floatingActionButton:
          FloatingActionButton
              .extended(
        onPressed: () {
          _addHabit(
            context,
            ref,
          );
        },
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Add Habit',
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final habitsAsync =
        ref.watch(
      habitControllerProvider,
    );

    return habitsAsync.when(
      loading: () {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Habit Tracker',
            ),
          ),
          body: const Center(
            child:
                CircularProgressIndicator(),
          ),
        );
      },

      error: (
        error,
        stackTrace,
      ) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Habit Tracker',
            ),
          ),
          body: Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(
                24,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  const Text(
                    'Could not load habits',
                    textAlign:
                        TextAlign.center,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  FilledButton.icon(
                    onPressed: () {
                      ref.invalidate(
                        habitControllerProvider,
                      );
                    },
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    label:
                        const Text(
                      'Retry',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      data: (habits) {
        return _buildHome(
          context,
          ref,
          habits,
        );
      },
    );
  }
}