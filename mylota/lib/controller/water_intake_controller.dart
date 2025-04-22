import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/time.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../core/usecase/provider/water_intake_provider.dart';

class WaterInTakeController {
  static Future<void> saveWaterIntake(
      TimeOfDay? reminderPeriod, BuildContext context, double waterIntake,
      {required VoidCallback onStartLoading,
      required VoidCallback onStopLoading}) async {
    try {
      onStartLoading();
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in!");
        onStopLoading();
        return;
      }
      final today = DateTime.now();
      final todayStr =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      String formattedTime = reminderPeriod!.format(context);
      bool acknowledged = false;
      await FirebaseFirestore.instance
          .collection('water-intake-schedule')
          .doc(user.uid) // Save goal under user's UID
          .set({
        'daily-water-intake': '$waterIntake',
        "reminder-time": formattedTime, // or HH:mm
        "acknowledged": acknowledged,
        'createdAt': todayStr,
        // 'createdAt': DateTime.now().toIso8601String(),
      });

      Provider.of<WaterReminderProvider>(context, listen: false)
          .startDailyWaterIntakeTimer(waterIntake.toString(),
              reminderPeriod.format(context), acknowledged);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule saved successfully!')),
      );
      onStopLoading();
    } catch (e) {
      onStopLoading();
      print("Error saving goal: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save goal!')),
      );
    }
  }

  static Future<void> checkAndResetAcknowledgedFlag(
      BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print("User not logged in.");
      return;
    }

    final docSnapshot = await FirebaseFirestore.instance
        .collection('water-intake-schedule')
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      final bool isAcknowledged = data?['acknowledged'] ?? false;
      final String lastAcknowledgedDate = data?['createdAt'] ?? '';

      final today = DateTime.now();
      final todayStr =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // Check if today is a new day and acknowledgment is already done
      if (isAcknowledged && lastAcknowledgedDate != todayStr) {
        // Reset acknowledged status
        await FirebaseFirestore.instance
            .collection('water-intake-schedule')
            .doc(uid)
            .update({
          'acknowledged': false, // Reset acknowledged for new day
          'createdAt': todayStr, // Update today's date
        });

        // Reschedule the reminder for today
        final reminderTime = data?['reminder-time'] ??
            "08:00"; // Get reminder time from Firestore
        final intakeLiters =
            data?['daily-water-intake'] ?? "2"; // Get intake amount

        Provider.of<WaterReminderProvider>(context, listen: false)
            .startDailyWaterIntakeTimer(intakeLiters, reminderTime,
                false); // false indicates new day reminder
      }
    }
  }
}
