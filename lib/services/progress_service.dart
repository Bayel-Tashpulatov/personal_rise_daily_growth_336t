// services/progress_service.dart

import 'package:personal_rise_daily_growth_336t/models/achievement_models.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_log.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_models.dart';
import 'package:personal_rise_daily_growth_336t/models/level_models.dart';
import 'package:personal_rise_daily_growth_336t/services/achievements_service.dart';

class ProgressSnapshot {
  final LevelState level;
  final int
  goodStreakDays; // текущий стрик "выполнял good в каждый из последних N дней"
  final int cleanStreakDays; // текущие чистые дни подряд (без bad в дни)
  final int totalSaved; // целая часть $
  final int totalWasted; // целая часть $
  final List<AchievementProgress> achievements;

  const ProgressSnapshot({
    required this.level,
    required this.goodStreakDays,
    required this.cleanStreakDays,
    required this.totalSaved,
    required this.totalWasted,
    required this.achievements,
  });
}

class ProgressService {
  /// применяем новый лог и возвращаем новое состояние уровня
  static LevelState applyPoints(LevelState s, HabitLog log) {
    if (s.isMax) {
      // на 5 уровне копим score «сверх»
      return LevelState(
        level: 5,
        points: 0,
        maxScore: s.maxScore + (log.type == HabitType.good ? 1 : -3),
      );
    }
    final delta = (log.type == HabitType.good) ? 1 : -3;
    int pts = (s.points + delta).clamp(0, 999999);

    // апгрейд уровня?
    final target = s.nextTarget!;
    if (pts >= target) {
      final nextLevel = s.level + 1;
      if (nextLevel >= 5) {
        // дошли до 5 — очки сбрасываются, дальше копим maxScore
        return LevelState(level: 5, points: 0, maxScore: 0);
      }
      // переход: очки сбрасываются
      return LevelState(level: nextLevel, points: 0, maxScore: 0);
    }
    return LevelState(level: s.level, points: pts, maxScore: 0);
  }

  /// агрегирует всё для экранов
  static ProgressSnapshot buildSnapshot({
    required LevelState level,
    required List<HabitLog> logs,
  }) {
    // сгруппировать по дню
    final byDay = <DateTime, List<HabitLog>>{};
    for (final l in logs) {
      final d = DateTime(l.date.year, l.date.month, l.date.day);
      (byDay[d] ??= []).add(l);
    }

    // стрик good-дней и чистые дни подряд (считаем от сегодня назад)
    int goodStreak = 0;
    int cleanStreak = 0;
    DateTime cursor = DateTime.now();
    // нормализуем к дню (без времени)
    cursor = DateTime(cursor.year, cursor.month, cursor.day);

    while (true) {
      final has = byDay[cursor];
      if (has == null) break;

      final hasGood = has.any((e) => e.type == HabitType.good);
      final hasBad = has.any((e) => e.type == HabitType.bad);

      if (hasGood) {
        goodStreak++;
      } else {
        break;
      }

      if (hasBad) {
        break;
      } else {
        cleanStreak++;
      }

      cursor = cursor.subtract(const Duration(days: 1));
    }

    // деньги
    double saved = 0;
    double wasted = 0;
    for (final l in logs) {
      if (l.type == HabitType.good && l.money > 0) saved += l.money;
      if (l.type == HabitType.bad && l.money < 0) wasted += -l.money;
    }

    // прогресс ачивок
    final ach = achievementsCatalog.map((def) {
      int current = 0;
      switch (def.kind) {
        case AchievementKind.streakDays:
          current = goodStreak;
          break;
        case AchievementKind.savedMoney:
          current = saved.floor();
          break;
        case AchievementKind.wastedMoney:
          current = wasted.floor();
          break;
        case AchievementKind.cleanDays:
          current = cleanStreak;
          break;
      }
      return AchievementProgress(
        def: def,
        current: current,
        achieved: current >= def.target,
      );
    }).toList();

    return ProgressSnapshot(
      level: level,
      goodStreakDays: goodStreak,
      cleanStreakDays: cleanStreak,
      totalSaved: saved.floor(),
      totalWasted: wasted.floor(),
      achievements: ach,
    );
  }
}
