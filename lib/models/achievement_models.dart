// models/achievement_models.dart
enum AchievementKind { streakDays, savedMoney, wastedMoney, cleanDays }

class AchievementDef {
  final String id;
  final String title;
  final String desc;
  final AchievementKind kind;
  final int target; // дни/доллары
  const AchievementDef({
    required this.id,
    required this.title,
    required this.desc,
    required this.kind,
    required this.target,
  });
}

class AchievementProgress {
  final AchievementDef def;
  final int current; // текущий прогресс
  final bool achieved;
  const AchievementProgress({
    required this.def,
    required this.current,
    required this.achieved,
  });
}
