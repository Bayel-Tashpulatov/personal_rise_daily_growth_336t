const levelThresholds = [3, 5, 7, 10]; // 1→2, 2→3, 3→4, 4→5

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
  double get progress {
    if (isMax) return 1.0;
    final tgt = nextTarget ?? 1;
    final v = points / tgt;
    return (v.isNaN || v.isInfinite) ? 0.0 : v.clamp(0.0, 1.0);
  }
}
