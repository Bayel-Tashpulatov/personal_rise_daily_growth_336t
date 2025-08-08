const levelThresholds = [50, 100, 150, 200]; // 1→2, 2→3, 3→4, 4→5

class LevelState {
  final int level; // 1..5
  final int points; // текущие очки (уровни 1–4)
  final int maxScore; // накопленные сверх 5 уровня
  const LevelState({
    required this.level,
    required this.points,
    required this.maxScore,
  });

  bool get isMax => level == 5;
  int? get nextTarget => isMax ? null : levelThresholds[level - 1];
  double get progress =>
      isMax ? 1 : (points.clamp(0, nextTarget!) / nextTarget!);
}
