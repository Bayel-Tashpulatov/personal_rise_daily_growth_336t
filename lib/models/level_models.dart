const levelThresholds = [50, 100, 150, 200];

class LevelState {
  final int level;
  final int points;
  final int maxScore;
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
