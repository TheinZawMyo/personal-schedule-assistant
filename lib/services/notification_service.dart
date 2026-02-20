import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import '../models/timetable_entry.dart';
import 'dart:developer' as developer;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'timetable_reminders';
  static const String channelName = 'Timetable Reminders';
  static const int morningSummaryId = 888;
  static const int ongoingNotificationIdOffset = 100000;

  Future<void> init() async {
    // tz.initializeTimeZones() is called in main.dart before this

    // Detect device timezone using flutter_timezone
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone()
          .timeout(const Duration(seconds: 2));
      final location = tz.getLocation(timeZoneName);
      tz.setLocalLocation(location);
      developer.log(
        'Timezone detected: $timeZoneName (offset: ${location.currentTimeZone.offset}ms)',
        name: 'NotificationService',
      );
    } catch (e) {
      // Fallback to Asia/Yangon if detection fails or times out
      final yangon = tz.getLocation('Asia/Yangon');
      tz.setLocalLocation(yangon);
      developer.log(
        'Timezone detection failed or timed out, falling back to Asia/Yangon: $e',
        name: 'NotificationService',
      );
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );
  }

  /// Convert a local [DateTime] to a [tz.TZDateTime] by re-constructing it
  /// from its date/time components in [tz.local].
  ///
  /// This avoids the bug where [tz.TZDateTime.from] misinterprets the UTC epoch
  /// when the Dart VM's system timezone differs from [tz.local].
  tz.TZDateTime _toTZDateTime(DateTime dt) {
    return tz.TZDateTime(
      tz.local,
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      dt.minute,
      dt.second,
    );
  }

  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _onNotificationResponse(NotificationResponse details) {
    if (details.actionId == 'snooze') {
      final now = DateTime.now();
      scheduleNotification(
        id: details.id ?? (DateTime.now().millisecond),
        title: 'Snooze: Reminder',
        body: 'Activity starting soon',
        scheduledTime: now.add(const Duration(minutes: 10)),
      );
    }
  }

  static void _onBackgroundNotificationResponse(NotificationResponse details) {
    developer.log(
      'Background notification response: ${details.actionId}',
      name: 'NotificationService',
    );

    if (details.actionId == 'snooze') {
      final notificationService = NotificationService();
      final now = DateTime.now();
      notificationService.scheduleNotification(
        id: details.id ?? (DateTime.now().millisecond),
        title: 'Snooze: Reminder',
        body: 'Activity starting soon',
        scheduledTime: now.add(const Duration(minutes: 10)),
      );
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final tzScheduledTime = _toTZDateTime(scheduledTime);

    developer.log(
      'Scheduling notification "$title" at TZ: $tzScheduledTime '
      '(local: ${tz.local.name}, now: ${tz.TZDateTime.now(tz.local)})',
      name: 'NotificationService',
    );

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledTime,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.reminder,
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction('snooze', 'Snooze 10 min'),
            const AndroidNotificationAction('dismiss', 'Dismiss'),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> scheduleOngoingNotification({
    required int id,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final endTimeStr = DateFormat('jm').format(endTime);
    await _notifications.zonedSchedule(
      id: id + ongoingNotificationIdOffset,
      title: '🔴 Now: $title',
      body: 'Ends at $endTimeStr',
      scheduledDate: _toTZDateTime(startTime),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'ongoing_activity',
          'Ongoing Activity',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true,
          autoCancel: false,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleMorningSummary({
    required int hour,
    required int minute,
    required List<TimetableEntry> todayEntries,
  }) async {
    if (todayEntries.isEmpty) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final sorted = List<TimetableEntry>.from(todayEntries)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final summary = sorted
        .take(3)
        .map((e) {
          final time = DateFormat('HH:mm').format(e.startTime);
          return '$time ${e.title}';
        })
        .join(', ');

    await _notifications.zonedSchedule(
      id: morningSummaryId,
      title: 'Your Schedule for Today',
      body: summary,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_summary',
          'Morning Summary',
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Fire an instant test notification to verify setup.
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Channel for testing notifications',
          importance: Importance.max,
          priority: Priority.max,
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notifications.show(
      id: 9999,
      title: '🔔 Test Notification',
      body: 'Notifications are working! Tap to dismiss.',
      notificationDetails: notificationDetails,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
