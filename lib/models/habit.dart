enum HabitFrequency {
  daily,
  weekdays,
  weekly,
}

class Habit {
  final String name;
  final HabitFrequency frequency;
  final int streak;
  final bool isCompleted;

  const Habit({
    required this.name,
    required this.frequency,
    required this.streak,
    required this.isCompleted,
  });

  String get frequencyText {
    switch(frequency) {
      case HabitFrequency.daily:
        return 'Every day';
      case HabitFrequency.weekdays:
        return 'Weekdays';
      case HabitFrequency.weekly:
        return 'Once a week';
    }
  }

  Habit copyWith({
    String? name,
    HabitFrequency? frequency,
    int? streak,
    bool? isCompleted,
  }) {
    return Habit(
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      streak: streak ?? this.streak,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}