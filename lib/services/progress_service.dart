import 'package:collection/collection.dart';
import 'package:personal_rise_daily_growth_336t/models/level_models.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_log.dart';
import 'package:personal_rise_daily_growth_336t/models/achievement_models.dart';

class ProgressSnapshot {
  final int totalSaved;
  final int totalWasted;
  final int cleanDays;
  final int goodStreak;
  final List<AchievementProgress> achievements;

  const ProgressSnapshot({
    required this.totalSaved,
    required this.totalWasted,
    required this.cleanDays,
    required this.goodStreak,
    required this.achievements,
  });
}

class ProgressService {
  static const int goodPoint = 1000;
  static const int badPoint = -3;

  static LevelState applyPoints(LevelState prev, HabitLog log) {
    final delta = log.amount >= 0 ? goodPoint : badPoint;

    if (!prev.isMax) {
      int points = prev.points + delta;
      if (points < 0) points = 0;

      final target = prev.nextTarget!;
      if (points >= target) {
        final nextLevel = (prev.level + 1).clamp(1, 5);
        if (nextLevel == 5) {
          return LevelState(level: 5, points: 0, maxScore: 0);
        }
        return LevelState(level: nextLevel, points: 0, maxScore: 0);
      }
      return LevelState(
        level: prev.level,
        points: points,
        maxScore: prev.maxScore,
      );
    } else {
      int score = prev.maxScore + delta;
      if (score < 0) score = 0;
      return LevelState(level: 5, points: 0, maxScore: score);
    }
  }

  static ProgressSnapshot buildSnapshot({
    required LevelState level,
    required List<HabitLog> logs,
  }) {
    final totalSaved = logs
        .where((l) => l.amount > 0)
        .fold<int>(0, (s, l) => s + l.amount);
    final totalWasted = logs
        .where((l) => l.amount < 0)
        .fold<int>(0, (s, l) => s + (-l.amount));

    final byDay = groupBy(
      logs,
      (HabitLog l) => DateTime(l.date.year, l.date.month, l.date.day),
    );
    int cleanDays = byDay.values.where((list) {
      final hasGood = list.any((l) => l.amount > 0);
      final hasBad = list.any((l) => l.amount < 0);
      return hasGood && !hasBad;
    }).length;

    int goodStreak = 0;
    final goodDays = byDay.entries
        .where((e) => e.value.any((l) => l.amount > 0))
        .map((e) => e.key)
        .toSet();
    DateTime cursor = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    while (goodDays.contains(cursor)) {
      goodStreak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final defs = _allAchievementDefs();
    final List<AchievementProgress> progress = defs.map((d) {
      int current;
      switch (d.kind) {
        case AchievementKind.streakDays:
          current = goodStreak;
          break;
        case AchievementKind.savedMoney:
          current = totalSaved;
          break;
        case AchievementKind.wastedMoney:
          current = totalWasted;
          break;
        case AchievementKind.cleanDays:
          current = cleanDays;
          break;
      }
      return AchievementProgress(
        def: d,
        current: current,
        achieved: current >= d.target,
      );
    }).toList();

    return ProgressSnapshot(
      totalSaved: totalSaved,
      totalWasted: totalWasted,
      cleanDays: cleanDays,
      goodStreak: goodStreak,
      achievements: progress,
    );
  }

  static List<AchievementDef> _allAchievementDefs() => const [
    AchievementDef(
      id: 'streak_3',
      title: '3-Day Streak',
      desc: 'Complete habits 3 days in a row',
      kind: AchievementKind.streakDays,
      target: 3,
    ),
    AchievementDef(
      id: 'streak_7',
      title: '7-Day Streak',
      desc: 'Keep your streak for a week',
      kind: AchievementKind.streakDays,
      target: 7,
    ),
    AchievementDef(
      id: 'streak_14',
      title: '14-Day Streak',
      desc: 'Two weeks of consistency',
      kind: AchievementKind.streakDays,
      target: 14,
    ),
    AchievementDef(
      id: 'streak_30',
      title: '30-Day Streak',
      desc: 'A full month of momentum',
      kind: AchievementKind.streakDays,
      target: 30,
    ),
    AchievementDef(
      id: 'streak_60',
      title: '60-Day Streak',
      desc: 'Two months straight',
      kind: AchievementKind.streakDays,
      target: 60,
    ),
    AchievementDef(
      id: 'streak_100',
      title: '100-Day Streak',
      desc: '100 days without a break',
      kind: AchievementKind.streakDays,
      target: 100,
    ),
    AchievementDef(
      id: 'streak_365',
      title: '365-Day Streak',
      desc: 'An entire year!',
      kind: AchievementKind.streakDays,
      target: 365,
    ),

    AchievementDef(
      id: 'saved_10',
      title: 'Saved \$10',
      desc: 'First dollars saved',
      kind: AchievementKind.savedMoney,
      target: 10,
    ),
    AchievementDef(
      id: 'saved_50',
      title: 'Saved \$50',
      desc: 'A meaningful amount',
      kind: AchievementKind.savedMoney,
      target: 50,
    ),
    AchievementDef(
      id: 'saved_100',
      title: 'Saved \$100',
      desc: 'Triple digits saved',
      kind: AchievementKind.savedMoney,
      target: 100,
    ),
    AchievementDef(
      id: 'saved_250',
      title: 'Saved \$250',
      desc: 'Quarter to a grand',
      kind: AchievementKind.savedMoney,
      target: 250,
    ),
    AchievementDef(
      id: 'saved_500',
      title: 'Saved \$500',
      desc: 'Half a grand saved',
      kind: AchievementKind.savedMoney,
      target: 500,
    ),
    AchievementDef(
      id: 'saved_1000',
      title: 'Saved \$1000',
      desc: 'Four digits saved',
      kind: AchievementKind.savedMoney,
      target: 1000,
    ),
    AchievementDef(
      id: 'saved_5000',
      title: 'Saved \$5000',
      desc: 'Financial discipline unlocked',
      kind: AchievementKind.savedMoney,
      target: 5000,
    ),

    AchievementDef(
      id: 'wasted_50',
      title: 'Wasted \$50',
      desc: 'Money lost to bad habits',
      kind: AchievementKind.wastedMoney,
      target: 50,
    ),
    AchievementDef(
      id: 'wasted_200',
      title: 'Wasted \$200',
      desc: 'That stings',
      kind: AchievementKind.wastedMoney,
      target: 200,
    ),

    AchievementDef(
      id: 'clean_1',
      title: '1 Clean Day',
      desc: 'Only good habits today',
      kind: AchievementKind.cleanDays,
      target: 1,
    ),
    AchievementDef(
      id: 'clean_3',
      title: '3 Clean Days',
      desc: 'Three days without bad habits',
      kind: AchievementKind.cleanDays,
      target: 3,
    ),
    AchievementDef(
      id: 'clean_7',
      title: '7 Clean Days',
      desc: 'A clean week',
      kind: AchievementKind.cleanDays,
      target: 7,
    ),
    AchievementDef(
      id: 'clean_14',
      title: '14 Clean Days',
      desc: 'Two clean weeks',
      kind: AchievementKind.cleanDays,
      target: 14,
    ),
    AchievementDef(
      id: 'clean_30',
      title: '30 Clean Days',
      desc: 'A clean month',
      kind: AchievementKind.cleanDays,
      target: 30,
    ),
    AchievementDef(
      id: 'clean_60',
      title: '60 Clean Days',
      desc: 'Two clean months',
      kind: AchievementKind.cleanDays,
      target: 60,
    ),
    AchievementDef(
      id: 'clean_100',
      title: '100 Clean Days',
      desc: 'Perfection for 100 days',
      kind: AchievementKind.cleanDays,
      target: 100,
    ),
  ];
}
