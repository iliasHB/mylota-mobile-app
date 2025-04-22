import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../../services/notification_service.dart';

class ToDoScheduleProvider extends ChangeNotifier {
  Future<void> startTodoSchedule(task, String reminderTime, bool acknowledged, String reminderDate) async {
    if (acknowledged) {
      await NotificationService.cancelToDoReminder(); // Cancel existing notifications if acknowledged
      return;
    }

    final timeParts = reminderTime.split(":");
    final reminderHour = int.parse(timeParts[0]);
    final reminderMinute = int.parse(timeParts[1]);

    // Schedule the notification
    NotificationService.scheduleRepeatingToDoReminder(
        task,
        reminderHour,
        reminderMinute,
        reminderDate
    );

    // NotificationService.showNotification(
    //   id: 8,
    //   title: 'Good Morning!',
    //   body: 'Time to wake up! 🌅. ',
    //   channelId: 'sleep_channel_id',
    //   channelTitle: 'Sleep Timer',
    //   channelDesc: 'Notifies you when it’s time to wake up',
    // );
  }

  Future<void> markToDoAsDoneForToday() async {
    await NotificationService.cancelToDoReminder(); // Cancel notifications

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final today = DateTime.now();
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    await FirebaseFirestore.instance
        .collection('todo-goals')
        // .where('title', isEqualTo: '')
        .doc(uid)
        .update({
      'acknowledged': true,
      'reminder-date': todayStr,
    });

    notifyListeners();
  }
}