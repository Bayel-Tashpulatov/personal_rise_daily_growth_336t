// lib/models/habit_log.dart
import 'package:hive/hive.dart';
part 'habit_log.g.dart';

@HiveType(typeId: 3)
class HabitLog extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String habitId;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final int amount; 
  @HiveField(4)
  final String? note; 

  HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.amount,
     this.note,
  });

  HabitLog copyWith({int? amount, String? note, DateTime? date}) => HabitLog(
    id: id,
    habitId: habitId,
    date: date ?? this.date,
    amount: amount ?? this.amount,
    note: note ?? this.note,
  );
}
