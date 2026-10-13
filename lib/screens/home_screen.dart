import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../widgets/habit_card.dart';
import 'habit_form_screen.dart';
import '../data/repositories/habit_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HabitRepository _habitRepository = HabitRepository();
  List<Habit> habits = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadHabits();
  }

  Future<void> _loadHabits() async {
    try {
      final loadedHabits = await _habitRepository.getHabits();

      if (!mounted) {
        return;
      }

      setState(() {
        habits = loadedHabits;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load habits.';
      });
    }
  }

  Future<void> toggleHabit(
    Habit habit,
    DateTime date,
  ) async {
    try {
      final updatedHabit =
          await _habitRepository.toggleCompletion(habit, date);
      
      if (!mounted) {
        return;
      }

      final index = habits.indexWhere(
        (item) => item.id == updatedHabit.id,
      );

      if (index == -1) {
        return;
      }

      setState(() {
        habits[index] = updatedHabit;
      });
    } catch (error) {
      if(!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not update habit',
          ),
        ),
      );
    }
  }

  Future<void> addHabit() async {
    final result = await Navigator.push<HabitFormResult>(
      context,
      MaterialPageRoute(
        builder: (context) => const HabitFormScreen(),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result.action != HabitFormAction.save) {
      return;
    }

    try {
      final savedHabit = await _habitRepository.addHabit(result.habit);

      if(!mounted) {
        return;
      }

      setState(() {
        habits.add(savedHabit);
      });
    } catch (error) {
      if(!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save habit',
          ),
        ),
      );
    }
  }

  Future<void> editHabit(Habit habit) async {
    final result = await Navigator.push<HabitFormResult>(
      context,
      MaterialPageRoute(
        builder: (context) => HabitFormScreen(habit: habit),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    switch (result.action) {
      case HabitFormAction.save:
        await _saveHabitChanges(result.habit);
      case HabitFormAction.delete:
        await _deleteHabit(result.habit);
    }
  }

  Future<void> _saveHabitChanges(Habit habit) async {
    try {
      final updatedHabit = await _habitRepository.updateHabit(habit);

      if (!mounted) {
        return;
      }

      final index = habits.indexWhere(
        (item) => item.id == updatedHabit.id,
      );

      if (index == -1) {
        return;
      }

      setState(() {
        habits[index] = updatedHabit;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not update habit',
          ),
        ),
      );
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    final id = habit.id;

    if (id == null) {
      return;
    }

    try {
      await _habitRepository.deleteHabit(id);

      if (!mounted) {
        return;
      }

      setState(() {
        habits.removeWhere(
          (item) => item.id == id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${habit.name} deleted',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not delete habit',
          ),
        ),
      );
    }
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!),
                )
              : Padding(
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
                                streak: habit.currentStreak(today),
                                onToggle: () {
                                  toggleHabit(habit, today);
                                },
                                onOpen: () {
                                  editHabit(habit);
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



