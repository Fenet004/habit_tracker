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
}