// models/habit.dart
enum HabitKind { good, bad }

class HabitItem {
  final String id;
  final String title;
  final String subtitle; // краткое описание
  final HabitKind kind;

  /// Сколько раз выполнено сегодня (для good = done; для bad = триггеры)
  final int todayCount;

  /// Стрик по этой привычке (для good: подряд дней выполнения; для bad: подряд дней «провалов»)
  final int streak;

  /// Деньги: для good — накоплено (+), для bad — потеряно (−)
  final int money; // в $, целое для UI

  const HabitItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    this.todayCount = 0,
    this.streak = 0,
    this.money = 0,
  });

  HabitItem copyWith({int? todayCount, int? streak, int? money}) => HabitItem(
    id: id,
    title: title,
    subtitle: subtitle,
    kind: kind,
    todayCount: todayCount ?? this.todayCount,
    streak: streak ?? this.streak,
    money: money ?? this.money,
  );
}
