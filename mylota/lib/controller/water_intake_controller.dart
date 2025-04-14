
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/time.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../core/usecase/provider/water_intake_provider.dart';

class WaterInTakeController {
  static Future<void> saveWaterIntake(TimeOfDay? reminderPeriod, BuildContext context, double waterIntake) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in!");
        return;
      }
      final today = DateTime.now();
      final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
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
          .startDailyWaterIntakeTimer(
          waterIntake.toString(), reminderPeriod.format(context), acknowledged);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule saved successfully!')),
      );
    } catch (e) {
      print("Error saving goal: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save goal!')),
      );
    }
  }
}
