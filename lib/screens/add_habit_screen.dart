import 'package:flutter/material.dart';
import '../models/habit.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final Set<HabitDay> _selectedDays = HabitDay.values.toSet();

  void _createHabit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one day'),
        ),
      );

      return ;
    }

    final habit = Habit(
      name: _nameController.text.trim(),
      repeatDays: _selectedDays,
      streak: 0,
      isCompleted: false,
    );

    Navigator.pop(context, habit);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Habit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Habit name',
                  hintText: 'e.g. Read 30 minutes',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Please enter a habit name';
                  }
                  
                  if (name.length < 3) {
                    return 'Habit name must be atleast 3 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 28),

              Text(
                'Repeat on',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(height:12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Every day'),
                    onPressed: () {
                      setState(() {
                        _selectedDays
                          ..clear()
                          ..addAll(HabitDay.values);
                      });
                    },
                  ),

                  ActionChip(
                    label: const Text('Weekdays'),
                    onPressed: () {
                      setState(() {
                        _selectedDays
                          ..clear()
                          ..addAll({
                            HabitDay.monday,
                            HabitDay.tuesday,
                            HabitDay.wednesday,
                            HabitDay.thursday,
                            HabitDay.friday,
                          });
                      });
                    },
                  ),

                  ActionChip(
                    label: const Text('Clear'),
                    onPressed: () {
                      setState(() {
                        _selectedDays.clear();
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: HabitDay.values.map((day) {
                  final isSelected = _selectedDays.contains(day);

                  return FilterChip(
                    label: Text(day.shortLabel),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              FilledButton(
                onPressed: _createHabit,
                child: const Text('Create Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}