import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 1)
enum HabitKind {
  @HiveField(0)
  good,
  @HiveField(1)
  bad,
}

@HiveType(typeId: 2)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final HabitKind kind;
  @HiveField(4)
  final String? goal;
  @HiveField(5)
  final int? frequencyIndex;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.kind,
    this.goal,
    this.frequencyIndex,
  });

  Habit copyWith({
    String? name,
    String? description,
    String? goal,
    int? frequencyIndex,
  }) => Habit(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    kind: kind,
    goal: goal ?? this.goal,
    frequencyIndex: frequencyIndex ?? this.frequencyIndex,
  );
}
