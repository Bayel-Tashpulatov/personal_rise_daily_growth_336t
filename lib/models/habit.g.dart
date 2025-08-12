// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 2;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      kind: fields[3] as HabitKind,
      goal: fields[4] as String?,
      frequencyIndex: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.kind)
      ..writeByte(4)
      ..write(obj.goal)
      ..writeByte(5)
      ..write(obj.frequencyIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitKindAdapter extends TypeAdapter<HabitKind> {
  @override
  final int typeId = 1;

  @override
  HabitKind read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitKind.good;
      case 1:
        return HabitKind.bad;
      default:
        return HabitKind.good;
    }
  }

  @override
  void write(BinaryWriter writer, HabitKind obj) {
    switch (obj) {
      case HabitKind.good:
        writer.writeByte(0);
        break;
      case HabitKind.bad:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitKindAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
