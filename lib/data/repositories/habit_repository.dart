import 'package:sqflite/sqflite.dart';
import '../../models/habit.dart';
import '../database/app_database.dart';

String _dateToDatabase(DateTime date) {
  final normalized = dateOnly(date);

  final year = normalized.year.toString().padLeft(4, '0');
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}

DateTime _dateFromDatabase(String value) {
  return dateOnly(DateTime.parse(value));
}


class HabitRepository {
  final AppDatabase _appDatabase;

  HabitRepository({
    AppDatabase? appDatabase,
  }) : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<List<Habit>> getHabits() async {
    final db = await _appDatabase.database;

    final habitRows = await db.query(
      'habits',
      orderBy: 'id ASC',
    );

    final repeatDayRows = await db.query('habit_repeat_days');

    final completionRows = await db.query('habit_completions');

    final repeatDaysByHabit = <int, Set<HabitDay>>{};

    for (final row in repeatDayRows) {
      final habitId = row['habit_id'] as int;
      final weekday = row['weekday'] as int;
      final habitDay = HabitDay.values[weekday - 1];

      repeatDaysByHabit
          .putIfAbsent(
            habitId,
            () => <HabitDay> {},
          )
          .add(habitDay);
    }

    final completionsByHabit = <int, Set<DateTime>>{};

    for (final row in completionRows) {
      final habitId = row['habit_id'] as int;

      final completedDate = 
          _dateFromDatabase(
            row['completed_date'] as String,
      );

      completionsByHabit
          .putIfAbsent(
            habitId,
            () => <DateTime>{},
          )
          .add(completedDate);
    }

    return habitRows.map((row) {
      final id = row['id'] as int;

      return Habit(
        id: id,
        name: row['name'] as String,
        createdAt: _dateFromDatabase(
          row['created_at'] as String,
        ),
        repeatDays: repeatDaysByHabit[id] ?? {},
        completedDates: completionsByHabit[id] ?? {},
      );
    }).toList();
  }

  Future<Habit> addHabit(Habit habit) async {
    final db = await _appDatabase.database;

    final habitId = await db.transaction(
      (transaction) async {
        final id = await transaction.insert(
          'habits',
          {
            'name': habit.name,
            'created_at': _dateToDatabase(habit.createdAt),
          },
        );

        for (final day in habit.repeatDays) {
          await transaction.insert(
            'habit_repeat_days',
            {
              'habit_id': id,
              'weekday': day.index + 1,
            },
          );
        }

        for (final completedDate in habit.completedDates) {
          await transaction.insert(
            'habit_completions',
            {
              'habit_id': id,
              'completed_date': _dateToDatabase(completedDate),
            },
          );
        }

        return id;
      }
    );

    return habit.copyWith(
      id: habitId,
    );
  }

  Future<Habit> toggleCompletion(
    Habit habit,
    DateTime date,
  ) async {
    final habitId = habit.id;

    if (habitId == null) {
      throw StateError(
        'Cannot update a habit that has no database ID.',
      );
    }

    final normalizedDate = dateOnly(date);

    if(!habit.isScheduledOn(normalizedDate)) {
      return habit;
    }

    final db = await _appDatabase.database;

    if (habit.isCompletedOn(normalizedDate)) {
      await db.delete(
        'habit_completions',
        where: 'habit_id = ? AND completed_date =?',
        whereArgs: [
          habitId,
          _dateToDatabase(normalizedDate),
        ],
      );
    } else {
      await db.insert(
        'habit_completions', 
        {
          'habit_id': habitId,
          'completed_date': _dateToDatabase(normalizedDate),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    return habit.toggleCompletionOn(normalizedDate);
  }


}