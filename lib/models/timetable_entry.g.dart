// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimetableEntryAdapter extends TypeAdapter<TimetableEntry> {
  @override
  final int typeId = 2;

  @override
  TimetableEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimetableEntry(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime,
      category: fields[5] as ActivityCategory,
      reminderMinutes: fields[6] as int,
      repeat: fields[7] as RepeatCycle,
      customDays: (fields[8] as List?)?.cast<int>(),
      isCompleted: fields[9] as bool,
      createdAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TimetableEntry obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.reminderMinutes)
      ..writeByte(7)
      ..write(obj.repeat)
      ..writeByte(8)
      ..write(obj.customDays)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityCategoryAdapter extends TypeAdapter<ActivityCategory> {
  @override
  final int typeId = 0;

  @override
  ActivityCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityCategory.work;
      case 1:
        return ActivityCategory.personal;
      case 2:
        return ActivityCategory.health;
      case 3:
        return ActivityCategory.study;
      case 4:
        return ActivityCategory.other;
      default:
        return ActivityCategory.work;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityCategory obj) {
    switch (obj) {
      case ActivityCategory.work:
        writer.writeByte(0);
        break;
      case ActivityCategory.personal:
        writer.writeByte(1);
        break;
      case ActivityCategory.health:
        writer.writeByte(2);
        break;
      case ActivityCategory.study:
        writer.writeByte(3);
        break;
      case ActivityCategory.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepeatCycleAdapter extends TypeAdapter<RepeatCycle> {
  @override
  final int typeId = 1;

  @override
  RepeatCycle read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RepeatCycle.none;
      case 1:
        return RepeatCycle.daily;
      case 2:
        return RepeatCycle.weekly;
      case 3:
        return RepeatCycle.custom;
      default:
        return RepeatCycle.none;
    }
  }

  @override
  void write(BinaryWriter writer, RepeatCycle obj) {
    switch (obj) {
      case RepeatCycle.none:
        writer.writeByte(0);
        break;
      case RepeatCycle.daily:
        writer.writeByte(1);
        break;
      case RepeatCycle.weekly:
        writer.writeByte(2);
        break;
      case RepeatCycle.custom:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatCycleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
