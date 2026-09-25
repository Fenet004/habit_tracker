enum HabitDay {
  monday('M', 'Mon', 'Monday'),
  tuesday('T', 'Tue', 'Tuesday'),
  wednesday('W', 'Wed', 'Wednesday'),
  thursday('T', 'Thu', 'Thursday'),
  friday('F', 'Fri', 'Friday'),
  saturday('S', 'Sat', 'Saturday'),
  sunday('S', 'Sun', 'Sunday');

  const HabitDay(
    this.shortLabel,
    this.mediumLabel,
    this.fullLabel,
  );

  final String shortLabel;
  final String mediumLabel;
  final String fullLabel;
}

class Habit {
  final String name;
  final Set<HabitDay> repeatDays;
  final int streak;
  final bool isCompleted;

  Habit({
    required this.name,
    required Set<HabitDay> repeatDays,
    required this.streak,
    required this.isCompleted,
  }) : repeatDays = Set.unmodifiable(repeatDays);

  Habit copyWith({
    String? name,
    Set<HabitDay>? repeatDays,
    int? streak,
    bool? isCompleted,
  }) {
    return Habit(
      name: name ?? this.name,
      repeatDays: repeatDays ?? this.repeatDays,
      streak: streak ?? this.streak,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  String get scheduleText {
    if (repeatDays.length == 7) {
      return 'Everyday';
    }

    final isWeekdays = 
        repeatDays.length == 5 &&
        repeatDays.contains(HabitDay.monday) &&
        repeatDays.contains(HabitDay.tuesday) &&
        repeatDays.contains(HabitDay.wednesday) &&
        repeatDays.contains(HabitDay.thursday) &&
        repeatDays.contains(HabitDay.friday);
    
    if (isWeekdays) {
      return 'Weekdays';
    }

    final isWeekends =
        repeatDays.length == 2 &&
        repeatDays.contains(HabitDay.saturday) &&
        repeatDays.contains(HabitDay.sunday);

    if (isWeekends) {
      return 'Weekends';
    }

    return HabitDay.values
        .where((day) => repeatDays.contains(day))
        .map((day) => day.mediumLabel)
        .join(' • ');
    
  }

  bool isScheduledOn(HabitDay day) {
    return repeatDays.contains(day);
  }
}