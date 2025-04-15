import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../../services/notification_service.dart';

class MealPlannerProvider with ChangeNotifier {
  Future<void> startMealPlanner(
      String meal,
      // String selectedCategory,
      // String selectedDayCategory,
      String reminderTime,
      String? selectedItem,
      String? selectedItem2,
      bool acknowledged) async {
    if (acknowledged) {
      await NotificationService.cancelReminder(); // Cancel existing notifications if acknowledged
      return;
    }

    final timeParts = reminderTime.split(":");
    final reminderHour = int.parse(timeParts[0]);
    final reminderMinute = int.parse(timeParts[1]);

    // Schedule the notification
    NotificationService.scheduleRepeatingMealReminder(
        meal,
        // selectedCategory,
        // selectedDayCategory,
        selectedItem,
        selectedItem2,
        reminderHour,
        reminderMinute);
  }

  // Mark the reminder as done for today
  Future<void> markMealAsDoneForToday() async {
    await NotificationService.cancelReminder(); // Cancel notifications

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final today = DateTime.now();
    final todayStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    await FirebaseFirestore.instance
        .collection('meal-planner')
        .doc(uid)
        .update({
      'acknowledged': true,
      'reminder-date': todayStr,
    });

    notifyListeners();
  }
}
