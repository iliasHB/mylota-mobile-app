import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../services/notification_service.dart';

class MealPlannerProvider with ChangeNotifier {
  Future<void> startMealPlanner(
      String meal,
      String selectedCategory,
      String selectedDayCategory,
      String reminderTime,
      String? selectedItem,
      String? selectedItem2,
      bool acknowledged) async {
    if (acknowledged) {
      await NotificationService.cancelMealReminder(); // Cancel existing notifications if acknowledged
      return;
    }

    final timeParts = reminderTime.split(":");
    final reminderHour = int.parse(timeParts[0]);
    final reminderMinute = int.parse(timeParts[1]);

    // Schedule the notification
    NotificationService.scheduleRepeatingMealReminder(
        meal,
        selectedCategory,
        selectedDayCategory,
        selectedItem,
        selectedItem2,
        reminderHour,
        reminderMinute);
  }

  // Mark the reminder as done for today
  Future<void> markMealAsDoneForToday(String mealType) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final dayName = DateFormat('EEEE').format(now); // "Monday", "Tuesday", etc.

    final fieldPath = '$dayName.$mealType';

    final updateData = {
      '$fieldPath.acknowledged': true,
      '$fieldPath.reminder-date': todayStr,
    };

    await FirebaseFirestore.instance
        .collection('meal-planner')
        .doc(uid)
        .update(updateData);
  }

  // Future<void> markMealAsDoneForToday() async {
  //   await NotificationService.cancelMealReminder(); // Cancel notifications
  //
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid == null) return;
  //
  //   final today = DateTime.now();
  //   final todayStr =
  //       "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
  //
  //   FirebaseFirestore.instance
  //       .collection('meal-planner')
  //       .doc(FirebaseAuth.instance.currentUser?.uid).get();
  //
  //
  //   await FirebaseFirestore.instance
  //       .collection('meal-planner')
  //       .doc(uid)
  //       .update({
  //     'acknowledged': true,
  //     'reminder-date': todayStr,
  //   });
  //
  //   notifyListeners();
  // }
}
