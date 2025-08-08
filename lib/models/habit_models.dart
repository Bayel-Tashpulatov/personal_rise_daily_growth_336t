enum HabitType { good, bad }

class Habit {
  final String id;
  final String name;
  final String shortDesc;
  final HabitType type;

  const Habit({
    required this.id,
    required this.name,
    required this.shortDesc,
    required this.type,
  });
}
