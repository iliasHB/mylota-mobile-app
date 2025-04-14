// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest_all.dart' as tz;
//
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   static Future<void> init() async {
//     tz.initializeTimeZones();
//
//     const AndroidInitializationSettings androidSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const InitializationSettings settings =
//     InitializationSettings(android: androidSettings);
//
//     await _notificationsPlugin.initialize(settings);
//   }
//
//   // static Future<void> scheduleExerciseReminder(int hour, int minute) async {
//   //   await _notificationsPlugin.zonedSchedule(
//   //     0,
//   //     'Exercise Reminder',
//   //     'Time to achieve your daily exercise goal!',
//   //     tz.TZDateTime.now(tz.local).add(Duration(hours: hour, minutes: minute)),
//   //     const NotificationDetails(
//   //       android: AndroidNotificationDetails(
//   //         'exercise_channel',
//   //         'Exercise Notifications',
//   //         importance: Importance.high,
//   //         priority: Priority.high,
//   //       ),
//   //     ),
//   //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//   //     uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//   //   );
//   // }
//
//   static Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//     required String channelId,
//     required String channelTitle,
//     required String channelDesc,
//   }) async {
//     AndroidNotificationDetails androidPlatformChannelSpecifics =
//     AndroidNotificationDetails(
//       channelId,
//       channelTitle,
//       channelDescription: channelDesc,
//       importance: Importance.max,
//       priority: Priority.high,);
//
//     NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//     );
//
//     await _notificationsPlugin.show(
//       id,
//       title,
//       body,
//       platformChannelSpecifics,
//     );
//   }
// }
