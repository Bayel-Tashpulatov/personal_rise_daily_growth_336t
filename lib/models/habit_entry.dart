// models/habit_entry.dart
enum EntryType { goodDone, badSlip }

class HabitEntry {
  final String id;
  final String habitId;
  final DateTime date; // дата события
  final EntryType type;
  final int amount; // +$ для good, -$ для bad
  final String note;

  const HabitEntry({
    required this.id,
    required this.habitId,
    required this.date,
    required this.type,
    required this.amount,
    required this.note,
  });

  HabitEntry copyWith({int? amount, String? note}) => HabitEntry(
    id: id,
    habitId: habitId,
    date: date,
    type: type,
    amount: amount ?? this.amount,
    note: note ?? this.note,
  );
}
