import 'package:personal_rise_daily_growth_336t/models/habit.dart';

class HabitVm {
  final String id;
  final String title;
  final String subtitle;
  final HabitKind kind;
  final int todayCount;
  final int money;
  const HabitVm({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.todayCount,
    required this.money,
  });
}
