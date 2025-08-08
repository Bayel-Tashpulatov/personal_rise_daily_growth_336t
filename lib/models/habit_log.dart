import 'package:personal_rise_daily_growth_336t/models/habit_models.dart';

class HabitLog {
  final String habitId;
  final HabitType type;
  final DateTime date; // день выполнения
  final double money; // +сэкономлено / -потрачено

  const HabitLog({
    required this.habitId,
    required this.type,
    required this.date,
    required this.money,
  });
}
