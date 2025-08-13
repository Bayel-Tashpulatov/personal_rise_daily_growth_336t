import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:personal_rise_daily_growth_336t/cubit/level_cubit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_log.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/widgets/habit_editor_widgets.dart';

class HabitsState {
  final List<Habit> habits;
  final List<HabitLog> logs;

  const HabitsState({required this.habits, required this.logs});

  List<Habit> get good =>
      habits.where((h) => h.kind == HabitKind.good).toList();
  List<Habit> get bad => habits.where((h) => h.kind == HabitKind.bad).toList();

  // ==== агрегаты для UI “Habits Main” ====
  int get todayGoodPercent {
    final today = DateTime.now();
    final todayLogs = logs.where(
      (l) =>
          l.date.year == today.year &&
          l.date.month == today.month &&
          l.date.day == today.day,
    );
    // простая модель: % = min(100, countGood * 10).
    final goodCount = todayLogs.where((l) => l.amount > 0).length;
    return (goodCount * 10).clamp(0, 100);
  }

  int get weekEarned {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));
    return logs
        .where((l) => l.amount > 0 && !_isBefore(l.date, start))
        .fold(0, (s, l) => s + l.amount);
  }

  int get weekLost {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));
    return logs
        .where((l) => l.amount < 0 && !_isBefore(l.date, start))
        .fold(0, (s, l) => s + (-l.amount));
  }

  // Вспомогалка
  static bool _isBefore(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return da.isBefore(db);
  }

  HabitsState copyWith({List<Habit>? habits, List<HabitLog>? logs}) =>
      HabitsState(habits: habits ?? this.habits, logs: logs ?? this.logs);
}

class HabitsCubit extends Cubit<HabitsState> {
  final LevelCubit levelCubit;
  late final Box<Habit> _habitBox;
  late final Box<HabitLog> _logBox;
  StreamSubscription? _hSub, _lSub;

  HabitsCubit(this.levelCubit)
    : super(const HabitsState(habits: [], logs: [])) {
    _habitBox = Hive.box<Habit>('habits');
    _logBox = Hive.box<HabitLog>('habit_logs');

    // начальная загрузка
    emit(
      HabitsState(
        habits: _habitBox.values.toList(),
        logs: _logBox.values.toList()..sort((a, b) => b.date.compareTo(a.date)),
      ),
    );

    // подписки
    _hSub = _habitBox.watch().listen((_) {
      emit(state.copyWith(habits: _habitBox.values.toList()));
    });
    _lSub = _logBox.watch().listen((_) {
      final fresh = _logBox.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      emit(state.copyWith(logs: fresh));
    });
  }

  @override
  Future<void> close() async {
    await _hSub?.cancel();
    await _lSub?.cancel();
    return super.close();
  }

  // ===== CRUD привычек =====

  /// Добавить хорошую привычку
  Future<void> addGood({
    required String name,
    required String description,
    required String goal,
    required HabitFrequency? frequency, // из UI
  }) async {
    final freqIndex = switch (frequency) {
      HabitFrequency.daily => 0,
      HabitFrequency.weekly => 1,
      HabitFrequency.biweekly => 2,
      HabitFrequency.monthly => 3,
      null => null,
    };

    final h = Habit(
      id: UniqueKey().toString(),
      name: name,
      description: description,
      kind: HabitKind.good,
      goal: goal.isEmpty ? null : goal,
      frequencyIndex: freqIndex,
    );
    await _habitBox.put(h.id, h);
  }

  /// Добавить плохую привычку
  Future<void> addBad({
    required String name,
    required String description,
    required String goal,
  }) async {
    final h = Habit(
      id: UniqueKey().toString(),
      name: name,
      description: description,
      kind: HabitKind.bad,
      goal: goal.isEmpty ? null : goal,
      frequencyIndex: null, // не используется для bad
    );
    await _habitBox.put(h.id, h);
  }

  Future<void> updateHabit(Habit habit) async => _habitBox.put(habit.id, habit);

  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);
    // удаляем связанные логи
    final forDelete = _logBox.values.where((l) => l.habitId == id).toList();
    for (final l in forDelete) {
      await _logBox.delete(l.id);
    }
  }

  // ===== ЛОГИ =====

  Future<HabitLog> addLogRaw({
    required String habitId,
    required DateTime date,
    required int amount,
    String? note,
  }) async {
    final log = HabitLog(
      id: UniqueKey().toString(),
      habitId: habitId,
      date: DateTime(date.year, date.month, date.day),
      amount: amount,
      note: note,
    );
    await _logBox.put(log.id, log);

    // 🔑 вот это нужно для Level Up тоста
    levelCubit.applyLog(log);

    return log;
  }

  Future<HabitLog> markGoodDone({
    required String habitId,
    required int amount,
    String? note,
  }) => addLogRaw(
    habitId: habitId,
    date: DateTime.now(),
    amount: amount > 0 ? amount : 1,
    note: note,
  );

  Future<HabitLog> markBadSlip({
    required String habitId,
    required int amountLost,
    String? note,
  }) => addLogRaw(
    habitId: habitId,
    date: DateTime.now(),
    amount: -amountLost.abs(),
    note: note,
  );

  Future<void> editLog(
    String id, {
    required int newAmount,
    String? newNote,
  }) async {
    final old = _logBox.get(id);
    if (old == null) return;
    await _logBox.put(
      id,
      old.copyWith(amount: newAmount, note: newNote ?? old.note),
    );
  }

  Future<void> deleteLog(String id) async => _logBox.delete(id);

  // Для деталей привычки
  List<HabitLog> entriesOf(String habitId) =>
      state.logs.where((l) => l.habitId == habitId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
}
