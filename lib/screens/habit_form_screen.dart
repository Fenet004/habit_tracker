import 'package:flutter/material.dart';
import '../models/habit.dart';

enum HabitFormAction {
  save,
  delete,
}

class HabitFormResult {
  final HabitFormAction action;
  final Habit habit;

  const HabitFormResult._({
    required this.action,
    required this.habit,
  });

  factory HabitFormResult.saved(
    Habit habit,
  ) {
    return HabitFormResult._(
      action: HabitFormAction.save,
      habit: habit,
    );
  }

  factory HabitFormResult.deleted(
    Habit habit,
  ) {
    return HabitFormResult._(
      action: HabitFormAction.delete,
      habit: habit,
    );
  }
}

class HabitFormScreen extends StatefulWidget {
  final Habit? habit;

  const HabitFormScreen({
    super.key,
    this.habit,
  });

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late Set<HabitDay> _selectedDays;

  bool get isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();

    final habit = widget.habit;

    _nameController = TextEditingController(
      text: habit?.name ?? '',
    );

    _selectedDays = habit == null
        ? HabitDay.values.toSet()
        : Set<HabitDay>.from(habit.repeatDays);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
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

    final existingHabit = widget.habit;

    final habit = Habit(
      id: existingHabit?.id,
      name: _nameController.text.trim(),
      repeatDays: _selectedDays,
      createdAt: existingHabit?.createdAt ?? DateTime.now(),
      completedDates: existingHabit?.completedDates ?? const {},
    );

    Navigator.pop(
      context,
      HabitFormResult.saved(habit),
    );
  }

  Future<void> _confirmDelete() async {
    final habit = widget.habit;

    if (habit == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete habit?'),
          content: Text(
            'Delete "${habit.name}" and its completion history?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    Navigator.pop(
      context,
      HabitFormResult.deleted(habit),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Habit'
              : 'Create Habit',
        ),
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
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  _submit();
                },
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
                onPressed: _submit,
                child: Text(
                  isEditing
                      ? 'Save Changes'
                      : 'Create Habit',
                ),
              ),

              if (isEditing) ... [
                const SizedBox(height: 16),

                TextButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Habit'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}