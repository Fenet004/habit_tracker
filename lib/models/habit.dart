DateTime dateOnly(DateTime date) {
  return DateTime(
    date.year,
    date.month,
    date.day
  );
}

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
  final DateTime createdAt;
  final Set<DateTime> completedDates;

  Habit({
    required this.name,
    required Set<HabitDay> repeatDays,
    required DateTime createdAt,
    Set<DateTime> completedDates = const {},
  }) : repeatDays = Set.unmodifiable(repeatDays),
       createdAt = dateOnly(createdAt),
       completedDates = Set.unmodifiable(
          completedDates.map(dateOnly),
       );

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

  bool isScheduledOn(DateTime date) {
    final normalizedDate = dateOnly(date);

    if (normalizedDate.isBefore(createdAt)) {
      return false;
    }

    final habitDay = HabitDay.values[normalizedDate.weekday - 1];
    return repeatDays.contains(habitDay);
  }

  bool isCompletedOn(DateTime date) {
    return completedDates.contains(
      dateOnly(date),
    );
  }

  Habit toggleCompletionOn(DateTime date) {
    final normalizedDate = dateOnly(date);

    if(!isScheduledOn(normalizedDate)) {
      return this;
    }

    final updatedDates = Set<DateTime>.from(completedDates);

    if (updatedDates.contains(normalizedDate)) {
      updatedDates.remove(normalizedDate);
    } else {
      updatedDates.add(normalizedDate);
    }

    return copyWith(
      completedDates: updatedDates,
    );
  }

  int get totalCompletions {
    return completedDates.length;
  }

  Habit copyWith({
    String? name,
    Set<HabitDay>? repeatDays,
    DateTime? createdAt,
    Set<DateTime>? completedDates,
  }) {
    return Habit(
      name: name ?? this.name,
      repeatDays: repeatDays ?? this.repeatDays,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
    );
  }
}