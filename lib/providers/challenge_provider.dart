import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/challenge.dart';
import '../services/notification_service.dart';

final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, List<Challenge>>((ref) {
      return ChallengeNotifier();
    });

class ChallengeNotifier extends StateNotifier<List<Challenge>> {
  ChallengeNotifier() : super([]) {
    _loadChallenges();
  }

  late Box<Challenge> _box;

  int _notificationId(Challenge challenge) =>
      challenge.id.hashCode.abs() % 50000;

  Future<void> _loadChallenges() async {
    _box = await Hive.openBox<Challenge>('challenges');
    state = _box.values.toList();
    _rescheduleAll();
  }

  Future<void> addChallenge(Challenge challenge) async {
    await _box.put(challenge.id, challenge);
    state = [...state, challenge];
    _scheduleNotifications(challenge);
  }

  Future<void> updateChallenge(Challenge challenge) async {
    await _box.put(challenge.id, challenge);
    state = [
      for (final c in state)
        if (c.id == challenge.id) challenge else c,
    ];
    _scheduleNotifications(challenge);
  }

  Future<void> deleteChallenge(String id) async {
    final challenge = state.firstWhere((c) => c.id == id);
    final nId = _notificationId(challenge);
    await _box.delete(id);
    state = state.where((c) => c.id != id).toList();

    // Cancel ongoing notification
    NotificationService().cancelNotification(nId + 250000);
    // Cancel specific time reminders (scheduled for next 7 days)
    for (int i = 0; i < 7; i++) {
      NotificationService().cancelNotification(nId + (i * 1000) + 200000);
    }
  }

  void _rescheduleAll() {
    for (final challenge in state) {
      _scheduleNotifications(challenge);
    }
  }

  void _scheduleNotifications(Challenge challenge) {
    final nId = _notificationId(challenge);
    if (!challenge.isActive) {
      NotificationService().cancelNotification(nId + 250000);
      for (int i = 0; i < 7; i++) {
        NotificationService().cancelNotification(nId + (i * 1000) + 200000);
      }
      return;
    }

    final now = DateTime.now();

    // 1. Ongoing Notification (from startDate to endDate)
    // We schedule it at startDate. It's marked as 'ongoing'.
    if (challenge.startDate.isAfter(now)) {
      NotificationService().scheduleChallengeOngoingNotification(
        id: nId,
        title: challenge.title,
        startDate: challenge.startDate,
        endDate: challenge.endDate,
      );
    } else if (challenge.endDate.isAfter(now)) {
      // If already started but not finished, show immediately
      NotificationService().scheduleChallengeOngoingNotification(
        id: nId,
        title: challenge.title,
        startDate: now.add(const Duration(seconds: 1)),
        endDate: challenge.endDate,
      );
    }

    // 2. Specific Time Reminders
    if (challenge.isSpecificTime && challenge.specificTime != null) {
      // We want to schedule reminders for each day between startDate and endDate at specificTime.
      // Since local notifications are limited in number (usually ~50-100),
      // we'll schedule for the next 7 days if they fall within the range.

      final specificT = challenge.specificTime!;
      DateTime currentDay = DateTime(
        now.year,
        now.month,
        now.day,
        specificT.hour,
        specificT.minute,
      );

      if (currentDay.isBefore(now)) {
        currentDay = currentDay.add(const Duration(days: 1));
      }

      int remindersCount = 0;
      while (currentDay.isBefore(challenge.endDate) && remindersCount < 7) {
        if (currentDay.isAfter(challenge.startDate) ||
            currentDay.isAtSameMomentAs(challenge.startDate)) {
          NotificationService().scheduleChallengeNotification(
            id:
                nId +
                (remindersCount * 1000), // Unique ID for each daily reminder
            title: challenge.title,
            body: 'Time for your challenge!',
            scheduledTime: currentDay,
          );
          remindersCount++;
        }
        currentDay = currentDay.add(const Duration(days: 1));
      }
    }
  }
}

extension DateTimeExtension on DateTime {
  bool isAtSameMomentAs(DateTime other) =>
      millisecondsSinceEpoch == other.millisecondsSinceEpoch;
}
