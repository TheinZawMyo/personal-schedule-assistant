import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import '../models/timetable_entry.dart';
import '../services/notification_service.dart';
import '../providers/settings_provider.dart';

final StateNotifierProvider<TimetableNotifier, List<TimetableEntry>>
timetableProvider =
    StateNotifierProvider<TimetableNotifier, List<TimetableEntry>>((ref) {
      return TimetableNotifier(ref);
    });

class TimetableNotifier extends StateNotifier<List<TimetableEntry>> {
  final Ref ref;
  TimetableNotifier(this.ref) : super([]) {
    _loadEntries();

    // Listen to settings changes to reschedule morning summary
    ref.listen(settingsProvider, (previous, next) {
      if (previous?.morningSummaryEnabled != next.morningSummaryEnabled ||
          previous?.morningSummaryHour != next.morningSummaryHour ||
          previous?.morningSummaryMinute != next.morningSummaryMinute) {
        rescheduleMorningSummary();
      }
    });
  }

  late Box<TimetableEntry> _box;

  /// Generate a stable notification ID from the entry's UUID string.
  /// We use modulo to keep it within a safe range for Android (32-bit int).
  int _notificationId(TimetableEntry entry) => entry.id.hashCode.abs() % 100000;

  Future<void> _loadEntries() async {
    _box = await Hive.openBox<TimetableEntry>('timetable_entries');
    state = _box.values.toList();
    _rescheduleAll();
  }

  Future<void> addEntry(TimetableEntry entry) async {
    await _box.put(entry.id, entry);
    state = [...state, entry];
    _scheduleNotification(entry);
    rescheduleMorningSummary();
  }

  Future<void> updateEntry(TimetableEntry entry) async {
    await _box.put(entry.id, entry);
    state = [
      for (final e in state)
        if (e.id == entry.id) entry else e,
    ];
    _scheduleNotification(entry);
    rescheduleMorningSummary();
  }

  Future<void> deleteEntry(String id) async {
    final entry = state.firstWhere((e) => e.id == id);
    final nId = _notificationId(entry);
    await _box.delete(id);
    state = state.where((e) => e.id != id).toList();
    NotificationService().cancelNotification(nId);
    NotificationService().cancelNotification(
      nId + NotificationService.ongoingNotificationIdOffset,
    );
    rescheduleMorningSummary();
  }

  Future<void> toggleComplete(String id) async {
    final entry = state.firstWhere((e) => e.id == id);
    final updated = entry.copyWith(isCompleted: !entry.isCompleted);
    await updateEntry(updated);
  }

  void _rescheduleAll() {
    for (final entry in state) {
      _scheduleNotification(entry);
    }
    rescheduleMorningSummary();
  }

  void rescheduleMorningSummary() {
    final settings = ref.read(settingsProvider);
    if (!settings.morningSummaryEnabled) {
      NotificationService().cancelNotification(
        NotificationService.morningSummaryId,
      );
      return;
    }

    final now = DateTime.now();
    final summaryTimeToday = DateTime(
      now.year,
      now.month,
      now.day,
      settings.morningSummaryHour,
      settings.morningSummaryMinute,
    );

    // Determine if the next summary is for today or tomorrow.
    final DateTime summaryDate;
    if (summaryTimeToday.isAfter(now)) {
      summaryDate = summaryTimeToday;
    } else {
      summaryDate = summaryTimeToday.add(const Duration(days: 1));
    }

    // Filter entries for the day of the next summary.
    final todayEntries = state.where((e) {
      return e.startTime.year == summaryDate.year &&
          e.startTime.month == summaryDate.month &&
          e.startTime.day == summaryDate.day;
    }).toList();

    NotificationService().scheduleMorningSummary(
      hour: settings.morningSummaryHour,
      minute: settings.morningSummaryMinute,
      todayEntries: todayEntries,
    );
  }

  /// Fixed 5-minute reminder before task start time.
  static const int _reminderMinutes = 5;

  void _scheduleNotification(TimetableEntry entry) {
    final nId = _notificationId(entry);
    final now = DateTime.now();

    if (entry.isCompleted) {
      NotificationService().cancelNotification(nId);
      NotificationService().cancelNotification(
        nId + NotificationService.ongoingNotificationIdOffset,
      );
      developer.log(
        'Skipping notification for "${entry.title}" — marked as completed',
        name: 'TimetableNotifier',
      );
      return;
    }

    // Skip entries whose start time is already in the past
    if (!entry.startTime.isAfter(now)) {
      developer.log(
        'Skipping notification for "${entry.title}" — '
        'start time ${entry.startTime} is in the past (now: $now)',
        name: 'TimetableNotifier',
      );
      return;
    }

    // Calculate the ideal 5-minute-before reminder time
    final idealReminderTime = entry.startTime.subtract(
      const Duration(minutes: _reminderMinutes),
    );

    // If the ideal reminder time is in the future, schedule at that time.
    // If it's already past (e.g. user created task less than 5 min ahead),
    // schedule immediately (now + 5 seconds) so they still get a reminder.
    final DateTime scheduledTime;
    if (idealReminderTime.isAfter(now)) {
      scheduledTime = idealReminderTime;
    } else {
      scheduledTime = now.add(const Duration(seconds: 5));
    }

    final timeStr = DateFormat('jm').format(entry.startTime);
    NotificationService().scheduleNotification(
      id: nId,
      title: 'Task - ${entry.title}',
      body: 'Starts at $timeStr — tap to open',
      scheduledTime: scheduledTime,
      payload: entry.id,
    );
    developer.log(
      'Scheduled reminder for "${entry.title}" at $scheduledTime '
      '(start: ${entry.startTime}, now: $now)',
      name: 'TimetableNotifier',
    );

    // Handle ongoing notification
    final settings = ref.read(settingsProvider);
    if (settings.ongoingNotificationEnabled && entry.startTime.isAfter(now)) {
      NotificationService().scheduleOngoingNotification(
        id: nId,
        title: 'Task - ${entry.title}',
        startTime: entry.startTime,
        endTime: entry.endTime,
      );
    } else if (!settings.ongoingNotificationEnabled) {
      NotificationService().cancelNotification(
        nId + NotificationService.ongoingNotificationIdOffset,
      );
    }
  }
}
