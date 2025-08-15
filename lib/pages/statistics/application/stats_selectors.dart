import 'package:personal_rise_daily_growth_336t/cubit/habits_cubit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_log.dart';
import 'package:personal_rise_daily_growth_336t/pages/statistics/statistics_page.dart';

extension StatsSelectors on HabitsCubit {
  List<MonthKey> availableMonths() {
    final set = <MonthKey>{};
    for (final l in state.logs) {
      set.add(MonthKey(l.date.year, l.date.month));
    }
    final list = set.toList()
      ..sort((a, b) => a.y != b.y ? a.y.compareTo(b.y) : a.m.compareTo(b.m));
    return list;
  }

  ({int saved, int lost}) totalsFor(MonthKey mk) {
    var saved = 0, lost = 0;
    for (final l in state.logs) {
      if (l.date.year == mk.y && l.date.month == mk.m) {
        if (l.amount > 0) {
          saved += l.amount;
        } else {
          lost += -l.amount;
        }
      }
    }
    return (saved: saved, lost: lost);
  }

  List<({String label, int saved, int lost})> seriesForYear(int year) {
    final res = <({String label, int saved, int lost})>[];
    for (int m = 1; m <= 12; m++) {
      var s = 0, l = 0;
      for (final x in state.logs) {
        if (x.date.year == year && x.date.month == m) {
          if (x.amount > 0) {
            s += x.amount;
          } else {
            l += -x.amount;
          }
        }
      }
      res.add((label: MonthKey.monthShort(m), saved: s, lost: l));
    }
    return res;
  }

  List<({Habit habit, int total})> topHabits({
    required MonthKey mk,
    required bool positive,
    int limit = 3,
  }) {
    final map = <String, int>{};
    for (final l in state.logs) {
      if (l.date.year == mk.y && l.date.month == mk.m) {
        if (positive && l.amount > 0) {
          map[l.habitId] = (map[l.habitId] ?? 0) + l.amount;
        } else if (!positive && l.amount < 0) {
          map[l.habitId] = (map[l.habitId] ?? 0) + (-l.amount);
        }
      }
    }
    final items = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final byId = {for (final h in state.habits) h.id: h};
    return items.take(limit).map((e) {
      final h = byId[e.key];
      return (
        habit:
            h ??
            Habit(
              id: e.key,
              name: 'Unknown',
              description: '',
              kind: HabitKind.good,
            ),
        total: e.value,
      );
    }).toList();
  }

  List<({Habit habit, int total, int monthsCovered})> topHabitsForWindow({
    required MonthKey mk,
    required bool positive,
    required int windowMonths,
    int limit = 3,
  }) {
    DateTime end = DateTime(mk.y, mk.m, 1);
    DateTime start = DateTime(end.year, end.month - (windowMonths - 1), 1);

    final byId = <String, List<HabitLog>>{};
    for (final l in state.logs) {
      final d = DateTime(l.date.year, l.date.month, 1);
      if (d.isBefore(start) || d.isAfter(end)) continue;

      if (positive && l.amount <= 0) continue;
      if (!positive && l.amount >= 0) continue;

      (byId[l.habitId] ??= []).add(l);
    }

    final items = <({Habit habit, int total, int monthsCovered})>[];
    final allHabits = {for (final h in state.habits) h.id: h};

    byId.forEach((id, logs) {
      final h = allHabits[id];
      if (h == null) return;

      int sum = 0;
      final covered = <String>{};
      for (final l in logs) {
        sum += positive ? l.amount : -l.amount;
        covered.add(
          '${l.date.year}-${l.date.month.toString().padLeft(2, '0')}',
        );
      }

      items.add((habit: h, total: sum, monthsCovered: covered.length));
    });

    items.sort((a, b) => b.total.compareTo(a.total));
    return items.take(limit).toList();
  }
}
