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
  HabitFrequency _selectedFrequency = HabitFrequency.daily;

  String _frequencyLabel(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Every day';
      case HabitFrequency.weekdays:
        return 'Weekdays';
      case HabitFrequency.weekly:
        return 'Once a week';
    }
  }

  void _createHabit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final habit = Habit(
      name: _nameController.text.trim(),
      frequency: _selectedFrequency,
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
      body: Padding(
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a habit name';
                  }
                  
                  if (value.trim().length < 3) {
                    return 'Habit name must be atleast 3 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              DropdownButtonFormField<HabitFrequency>(
                initialValue: _selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: HabitFrequency.values.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(_frequencyLabel(frequency)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedFrequency = value;
                  });
                },
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