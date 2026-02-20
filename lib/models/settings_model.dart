import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 3)
class SettingsModel extends HiveObject {
  @HiveField(0)
  bool morningSummaryEnabled = true;

  @HiveField(1)
  int morningSummaryHour = 7;

  @HiveField(2)
  int morningSummaryMinute = 0;

  @HiveField(3)
  int defaultReminderMinutes = 10;

  @HiveField(4)
  bool darkMode = true;

  @HiveField(5)
  bool hapticFeedbackEnabled = true;

  @HiveField(6)
  bool ongoingNotificationEnabled = false;

  SettingsModel({
    this.morningSummaryEnabled = true,
    this.morningSummaryHour = 7,
    this.morningSummaryMinute = 0,
    this.defaultReminderMinutes = 10,
    this.darkMode = true,
    this.hapticFeedbackEnabled = true,
    this.ongoingNotificationEnabled = false,
  });

  TimeOfDay get morningSummaryTime =>
      TimeOfDay(hour: morningSummaryHour, minute: morningSummaryMinute);

  SettingsModel copyWith({
    bool? morningSummaryEnabled,
    int? morningSummaryHour,
    int? morningSummaryMinute,
    int? defaultReminderMinutes,
    bool? darkMode,
    bool? hapticFeedbackEnabled,
    bool? ongoingNotificationEnabled,
  }) {
    return SettingsModel(
      morningSummaryEnabled:
          morningSummaryEnabled ?? this.morningSummaryEnabled,
      morningSummaryHour: morningSummaryHour ?? this.morningSummaryHour,
      morningSummaryMinute: morningSummaryMinute ?? this.morningSummaryMinute,
      defaultReminderMinutes:
          defaultReminderMinutes ?? this.defaultReminderMinutes,
      darkMode: darkMode ?? this.darkMode,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      ongoingNotificationEnabled:
          ongoingNotificationEnabled ?? this.ongoingNotificationEnabled,
    );
  }
}
