// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
//
// class LocalNotificationService {
//   static final _notifications = FlutterLocalNotificationsPlugin();
//
//   static Future init() async {
//     // Android initialization
//     const androidSettings = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );
//     // iOS initialization
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//     await _notifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (details) {
//         // handle tap
//       },
//     );
//   }
//
//   //LocalNotificationService.showNotification();
//   Future<void> showNotification(String title, String body) async {
//     const androidDetails = AndroidNotificationDetails(
//       'channel_id',
//       'My Channel',
//       channelDescription: 'Channel description',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const iosDetails = DarwinNotificationDetails();
//     const notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//     await LocalNotificationService._notifications.show(
//       0,
//       title,
//       body,
//       notificationDetails,
//     );
//   }
//
//   Future<void> scheduleDailyNotification({
//     required int hour,
//     required int minute,
//   }) async {
//     final tz.TZDateTime scheduled = _nextInstanceOfTime(hour, minute);
//
//     await _notifications.zonedSchedule(
//       1,
//       'Daily Reminder',
//       'Don’t forget to check the app!',
//       scheduled,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_channel',
//           'Daily Notifications',
//           channelDescription: 'Daily reminder channel',
//         ),
//         iOS: DarwinNotificationDetails(),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }
//
//   tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
//     final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime scheduled = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       hour,
//       minute,
//     );
//     if (scheduled.isBefore(now)) {
//       scheduled = scheduled.add(const Duration(days: 1));
//     }
//     return scheduled;
//   }
// }
