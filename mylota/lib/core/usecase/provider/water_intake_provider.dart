import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/notification_service.dart';

class WaterReminderProvider with ChangeNotifier {

  Future<void> startDailyWaterIntakeTimer(String intakeLiters, String reminderTime, bool acknowledged) async {
    if (acknowledged) {
      await NotificationService.cancelWaterIntakeReminder(); // Cancel existing notifications if acknowledged
      return;
    }

    final timeParts = reminderTime.split(":");
    final reminderHour = int.parse(timeParts[0]);
    final reminderMinute = int.parse(timeParts[1]);

    // Schedule the notification
    NotificationService.scheduleRepeatingReminder(intakeLiters, reminderHour, reminderMinute);
  }

  // Mark the reminder as done for today
  Future<void> markAsDoneForToday() async {
    await NotificationService.cancelWaterIntakeReminder(); // Cancel notifications

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    await FirebaseFirestore.instance
        .collection('water-intake-schedule')
        .doc(uid)
        .update({
      'acknowledged': true,
      'createdAt': todayStr,
    });

    notifyListeners();
  }
}






// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class WaterReminderProvider with ChangeNotifier {
//   final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   WaterReminderProvider() {
//     _initializeNotifications();
//     _checkTodayReminder();
//   }
//
//   void _initializeNotifications() {
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const initializationSettings = InitializationSettings(
//       android: androidSettings,
//     );
//
//     _notificationsPlugin.initialize(
//       initializationSettings,
//       onSelectNotification: (payload) async {
//         // You can navigate or show dialog when notification is tapped
//       },
//     );
//   }
//
//   Future<void> _checkTodayReminder() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;
//
//     final doc = await FirebaseFirestore.instance
//         .collection('water-intake-schedule')
//         .doc(uid)
//         .get();
//
//     if (!doc.exists) return;
//
//     final data = doc.data()!;
//     final acknowledged = data['acknowledged'] ?? false;
//     final storedDate = data['date'] ?? '';
//     final today = DateTime.now();
//     final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
//
//     if (!acknowledged || storedDate != todayStr) {
//       final timeParts = (data['reminder-time'] as String).split(":");
//       final reminderTime = TimeOfDay(
//         hour: int.parse(timeParts[0]),
//         minute: int.parse(timeParts[1]),
//       );
//
//       final intakeLiters = data['daily-water-intake'] ?? '2L';
//       _scheduleRepeatingReminder(intakeLiters);
//     }
//   }
//
//   Future<void> _scheduleRepeatingReminder(String intakeLiters) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'water_channel',
//       'Water Intake',
//       channelDescription: 'Reminder to drink water daily',
//       importance: Importance.max,
//       priority: Priority.high,
//       enableVibration: true,
//       playSound: true,
//     );
//
//     const NotificationDetails platformDetails = NotificationDetails(
//       android: androidDetails,
//     );
//
//     await _notificationsPlugin.periodicallyShow(
//       12345,
//       '💧 Water Reminder',
//       'Remember to drink $intakeLiters of water today!',
//       RepeatInterval.hourly,
//       platformDetails,
//       // androidAllowWhileIdle: true,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//   }
//
//   Future<void> markAsDoneForToday() async {
//     await _notificationsPlugin.cancel(12345); // Cancel notifications
//
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;
//
//     final today = DateTime.now();
//     final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
//
//     await FirebaseFirestore.instance
//         .collection('water-intake-schedule')
//         .doc(uid)
//         .update({
//       'acknowledged': true,
//       'date': todayStr,
//     });
//
//     notifyListeners();
//   }
// }
