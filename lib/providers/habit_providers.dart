import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/habit_repository.dart';
import '../models/habit.dart';

final habitRepositoryProvider = Provider<HabitRepository>(
  (ref) {
    return HabitRepository();
  }
);

class HabitController extends AsyncNotifier<List<Habit>> {
  late final HabitRepository _repository;

  @override
  Future<List<Habit>> build() async {
    _repository = ref.read(habitRepositoryProvider);

    return _repository.getHabits();
  }

  Future<void> addHabit(Habit habit) async {
    final savedHabit = await _repository.addHabit(habit);

    final currentHabits = state.value ?? [];

    state = AsyncData(
      [
        ...currentHabits,
        savedHabit,
      ],
    );
  }

  Future<void> toggleCompletion(Habit habit, DateTime date) async {
    final updatedHabit = await _repository.toggleCompletion(habit, date);

    final currentHabits = state.value ?? [];

    state = AsyncData(
      currentHabits.map(
        (currentHabit) {
          if (currentHabit.id == updatedHabit.id) {
            return updatedHabit;
          }

          return currentHabit;
        }
      ).toList()
    );
  }

  Future<void> updateHabit(Habit habit) async {
    final updatedHabit = await _repository.updateHabit(habit);

    final currentHabits = state.value ?? [];

    state = AsyncData(currentHabits.map(
      (currentHabit) {
        if (currentHabit.id == updatedHabit.id) {
          return updatedHabit;
        }

        return currentHabit;
      },
      ).toList(),
    );
  }

  Future<void> deleteHabit(Habit habit) async {
    final id = habit.id;

    if (id == null) {
      throw StateError(
        'Cannot delete a habit without an ID.',
      );
    }

    await _repository.deleteHabit(id);

    final currentHabits = state.value ?? [];

    state = AsyncData(
      currentHabits
          .where(
            (currentHabit) => currentHabit.id != id,
          )
          .toList(),
    );
  }
}

final habitControllerProvider = AsyncNotifierProvider<HabitController, List<Habit>> (
  HabitController.new,
);

