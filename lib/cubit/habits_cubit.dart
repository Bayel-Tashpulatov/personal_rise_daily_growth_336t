// cubit/habits_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_entry.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/add_good_habit_flow.dart';

class HabitsState {
  final List<HabitItem> good;
  final List<HabitItem> bad;

  /// Процент выполнения good на сегодня (0..100)
  final int todayGoodPercent;

  /// За текущую неделю: заработано/потеряно
  final int weekEarned; // >=0
  final int weekLost; // >=0

  final List<HabitEntry> entries;

  const HabitsState({
    required this.good,
    required this.bad,
    required this.todayGoodPercent,
    required this.weekEarned,
    required this.weekLost,
    this.entries = const [],
  });

  bool get hasGood => good.isNotEmpty;
  bool get hasBad => bad.isNotEmpty;

  // помощники получения по habitId
  List<HabitEntry> entriesOf(String habitId) =>
      entries.where((e) => e.habitId == habitId).toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // сначала свежие

  HabitsState copyWith({
    List<HabitItem>? good,
    List<HabitItem>? bad,
    int? todayGoodPercent,
    int? weekEarned,
    int? weekLost,
    List<HabitEntry>? entries,
  }) => HabitsState(
    good: good ?? this.good,
    bad: bad ?? this.bad,
    todayGoodPercent: todayGoodPercent ?? this.todayGoodPercent,
    weekEarned: weekEarned ?? this.weekEarned,
    weekLost: weekLost ?? this.weekLost,
    entries: entries ?? this.entries,
  );
}

class HabitsCubit extends Cubit<HabitsState> {
  HabitsCubit()
    : super(
        const HabitsState(
          good: [],
          bad: [],
          todayGoodPercent: 0,
          weekEarned: 0,
          weekLost: 0,
        ),
      );

  void addGood({
    required String name,
    required String description,
    String goal = '',
    HabitFrequency? frequency, // если хранишь
  }) {
    final newItem = HabitItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: name,
      subtitle: description,
      kind: HabitKind.good,
      streak: 0,
      money: 0,
      todayCount: 0,
    );

    final newList = List<HabitItem>.from(state.good)..insert(0, newItem);
    emit(state.copyWith(good: newList));
  }

  void addBad({required String name, required String description}) {
    final newItem = HabitItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: name,
      subtitle: description,
      kind: HabitKind.bad,
      streak: 0,
      money: 0,
      todayCount: 0,
    );
    final newList = List<HabitItem>.from(state.bad)..insert(0, newItem);
    emit(state.copyWith(bad: newList));
  }

  // good: отметить как выполненную
  void markGoodDone({
    required String habitId,
    required int amount, // сколько сэкономил (+)
    String note = '',
  }) {
    final now = DateTime.now();
    final entry = HabitEntry(
      id: '${now.microsecondsSinceEpoch}',
      habitId: habitId,
      date: now,
      type: EntryType.goodDone,
      amount: amount, // положительное
      note: note,
    );

    // обновляем карточку: streak +1 (при необходимости), money += amount, todayCount +1
    final idx = state.good.indexWhere((h) => h.id == habitId);
    if (idx != -1) {
      final h = state.good[idx];
      final updated = h.copyWith(
        streak: h.streak + 1,
        money: h.money + amount,
        todayCount: h.todayCount + 1,
      );
      final goodList = List<HabitItem>.from(state.good)..[idx] = updated;
      final newEntries = List<HabitEntry>.from(state.entries)..add(entry);
      emit(state.copyWith(good: goodList, entries: newEntries));
    }
  }

  // bad: отметить “сорвался”
  void markBadSlip({
    required String habitId,
    required int
    amountLost, // сколько потерял (передаём положительное, сохраним как минус)
    String note = '',
  }) {
    final now = DateTime.now();
    final entry = HabitEntry(
      id: '${now.microsecondsSinceEpoch}',
      habitId: habitId,
      date: now,
      type: EntryType.badSlip,
      amount: -amountLost, // храним как отрицательное
      note: note,
    );

    final idx = state.bad.indexWhere((h) => h.id == habitId);
    if (idx != -1) {
      final h = state.bad[idx];
      final updated = h.copyWith(
        streak: h.streak + 1, // стрик «провалов»
        money: h.money + amountLost, // суммарно потеряно (показываем как $793)
        todayCount: h.todayCount + 1,
      );
      final badList = List<HabitItem>.from(state.bad)..[idx] = updated;
      final newEntries = List<HabitEntry>.from(state.entries)..add(entry);
      emit(state.copyWith(bad: badList, entries: newEntries));
    }
  }

  // редактирование записи
  void editEntry(String entryId, {required int amount, required String note}) {
    final i = state.entries.indexWhere((e) => e.id == entryId);
    if (i == -1) return;
    final old = state.entries[i];
    final newEntry = old.copyWith(
      amount: old.type == EntryType.goodDone ? amount : -amount,
      note: note,
    );

    // скорректируем агрегаты (money) в карточке
    if (old.type == EntryType.goodDone) {
      final idx = state.good.indexWhere((h) => h.id == old.habitId);
      if (idx != -1) {
        final h = state.good[idx];
        final corrected = h.copyWith(
          money: h.money - old.amount + newEntry.amount,
        );
        final list = List<HabitItem>.from(state.good)..[idx] = corrected;
        final entries = List<HabitEntry>.from(state.entries)..[i] = newEntry;
        emit(state.copyWith(good: list, entries: entries));
        return;
      }
    } else {
      final idx = state.bad.indexWhere((h) => h.id == old.habitId);
      if (idx != -1) {
        // для bad в карточке money — сумма потерь как положительное
        final prevLoss = -old.amount; // было положительное для UI
        final newLoss = -newEntry.amount; // тоже положительное
        final h = state.bad[idx];
        final corrected = h.copyWith(money: h.money - prevLoss + newLoss);
        final list = List<HabitItem>.from(state.bad)..[idx] = corrected;
        final entries = List<HabitEntry>.from(state.entries)..[i] = newEntry;
        emit(state.copyWith(bad: list, entries: entries));
        return;
      }
    }

    // запасной путь
    final entries = List<HabitEntry>.from(state.entries)..[i] = newEntry;
    emit(state.copyWith(entries: entries));
  }

}
