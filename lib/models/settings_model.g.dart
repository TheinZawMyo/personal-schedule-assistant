// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 3;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      morningSummaryEnabled: fields[0] as bool,
      morningSummaryHour: fields[1] as int,
      morningSummaryMinute: fields[2] as int,
      defaultReminderMinutes: fields[3] as int,
      darkMode: fields[4] as bool,
      hapticFeedbackEnabled: fields[5] as bool,
      ongoingNotificationEnabled: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.morningSummaryEnabled)
      ..writeByte(1)
      ..write(obj.morningSummaryHour)
      ..writeByte(2)
      ..write(obj.morningSummaryMinute)
      ..writeByte(3)
      ..write(obj.defaultReminderMinutes)
      ..writeByte(4)
      ..write(obj.darkMode)
      ..writeByte(5)
      ..write(obj.hapticFeedbackEnabled)
      ..writeByte(6)
      ..write(obj.ongoingNotificationEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
