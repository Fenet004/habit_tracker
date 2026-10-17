import '../models/habit.dart';

class CompletionSummary {
  final int scheduled;
  final int completed;

  const CompletionSummary({
    required this.scheduled,
    required this.completed,
  });

  double get rate {
    if (scheduled == 0) {
      return 0;
    }

    return completed / scheduled;
  }

  int get percentage {
    return (rate * 100).round();
  }
}

class DayCompletionStat {
  final DateTime date;
  final int scheduled;
  final int completed;

  const DayCompletionStat({
    required this.date,
    required this.scheduled,
    required this.completed,
  });

  bool get hasScheduledHabits {
    return scheduled > 0;
  }

  double get rate {
    if (scheduled == 0) {
      return 0;
    }

    return completed / scheduled;
  }

  int get percentage {
    return (rate * 100).round();
  }
}

class HabitPerformance {
  final Habit habit;
  final CompletionSummary summary;

  const HabitPerformance({
    required this.habit,
    required this.summary,
  });

  double get rate => summary.rate;

  int get percentage => summary.percentage;
}

CompletionSummary completionSummaryForDate(
  List<Habit> habits,
  DateTime date,
) {
  final normalizedDate = dateOnly(date);

  var scheduled = 0;
  var completed = 0;

  for (final habit in habits) {
    if (!habit.isScheduledOn(normalizedDate)) {
      continue;
    }

    scheduled++;

    if (habit.isCompletedOn(normalizedDate)) {
      completed++;
    }
  }

  return CompletionSummary(
    scheduled: scheduled,
    completed: completed,
  );
}

CompletionSummary completionSummaryForWeek(
  List<Habit> habits,
  DateTime asOfDate,
) {
  final today = dateOnly(asOfDate);

  final monday = DateTime(
    today.year,
    today.month,
    today.day - (today.weekday - 1),
  );

  var scheduled = 0;
  var completed = 0;

  var currentDate = monday;

  while (!currentDate.isAfter(today)) {
    final daySummary = completionSummaryForDate(habits, currentDate);

    scheduled += daySummary.scheduled;
    completed += daySummary.completed;

    currentDate = _nextCalendarDay(currentDate);
  }

  return CompletionSummary(
    scheduled: scheduled,
    completed: completed,
  );
}

DateTime _nextCalendarDay(DateTime date) {
  return DateTime(
    date.year,
    date.month,
    date.day + 1,
  );
}

int totalCompletions(List<Habit> habits) {
  var total = 0;

  for (final habit in habits) {
    total += habit.totalCompletions;
  }

  return total;
}

int bestCurrentStreak(
  List<Habit> habits,
  DateTime asOfDate
) {
  var best = 0;

  for (final habit in habits) {
    final streak = habit.currentStreak(asOfDate);

    if (streak > best) {
      best = streak;
    }
  }

  return best;
}

int longestStreakForHabit(
  Habit habit,
  DateTime asOfDate,
) {
  final endDate = dateOnly(asOfDate);

  if (endDate.isBefore(habit.createdAt)) {
    return 0;
  }

  var currentStreak = 0;
  var longestStreak = 0;

  var currentDate = habit.createdAt;

  while (!currentDate.isAfter(endDate)) {
    if (habit.isScheduledOn(currentDate)) {
      if (habit.isCompletedOn(currentDate)) {
        currentStreak++;

        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else if (!currentDate.isAtSameMomentAs(endDate)) {
        currentStreak = 0;
      }
    }

    currentDate = _nextCalendarDay(currentDate);
  }

  return longestStreak;
}

int longestStreakAcrossHabits(
  List<Habit> habits,
  DateTime asOfDate,
) {
  var longest = 0;

  for (final habit in habits) {
    final habitLongest = longestStreakForHabit(habit, asOfDate);

    if (habitLongest > longest) {
      longest = habitLongest;
    }
  }

  return longest;
}

CompletionSummary completionSummaryForHabit(
  Habit habit,
  DateTime asOfDate,
) {
  final endDate = dateOnly(asOfDate);

  if (endDate.isBefore(habit.createdAt)) {
    return const CompletionSummary(
      scheduled: 0,
      completed: 0
    );
  }

  var scheduled = 0;
  var completed = 0;

  var currentDate = habit.createdAt;

  while (!currentDate.isAfter(endDate)) {
    if (habit.isScheduledOn(currentDate)) {
      scheduled++;

      if (habit.isCompletedOn(currentDate)) {
        completed++;
      }
    }

    currentDate = _nextCalendarDay(currentDate);
  }

  return CompletionSummary(
    scheduled: scheduled,
    completed: completed,
  );
}

HabitPerformance? bestPerformingHabit(
  List<Habit> habits,
  DateTime asOfDate,
) {
  HabitPerformance? best;

  for (final habit in habits) {
    final summary = completionSummaryForHabit(habit, asOfDate);

    if (summary.scheduled == 0) {
      continue;
    }

    final performance = HabitPerformance(
      habit: habit,
      summary: summary,
    );

    if (best == null || performance.rate > best.rate) {
      best = performance;
    }
  }

  return best;
}

List<DayCompletionStat> lastSevenDaysStats(
  List<Habit> habits,
  DateTime asOfDate,
) {
  final today = dateOnly(asOfDate);

  return List.generate(
    7,
    (index) {
      final daysAgo = 6 - index;

      final date = DateTime(
        today.year,
        today.month,
        today.day - daysAgo
      );

      final summary = completionSummaryForDate(habits, date);

      return DayCompletionStat(
        date: date,
        scheduled: summary.scheduled,
        completed: summary.completed,
      );
    },
  );
}