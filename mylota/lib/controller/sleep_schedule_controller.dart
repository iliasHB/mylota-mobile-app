import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../core/usecase/provider/sleep_timer_provider.dart';
import '../widgets/subscription_alert.dart';

class SleepScheduleController {
  static Future<void> saveSleepGoal(TimeOfDay? bedTime, TimeOfDay? wakeTime, BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in!");
        return;
      }


      DocumentReference userDoc =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      DocumentSnapshot docSnap = await userDoc.get();

      Map<String, dynamic> sub = {};
      // Map<String, dynamic> email = {};
      if (docSnap.exists && docSnap.data() != null) {
        Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;
        sub = Map<String, dynamic>.from(data['subscription'] ?? {});
        // email = data['email'] ?? {});
        // if (sub.containsKey('expiredAt')) {
        // Parse expiredAt from String to DateTime
        DateTime expiredAt = DateTime.parse(sub['expiredAt']);
        DateTime now = DateTime.now();

        // Compare dates
        if (now.isAfter(expiredAt)) {
          // onStopLoading();
          // subscription expired
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      SubscriptionAlert(
                        // plan: sub['type'],
                        // amount: sub['amount'],
                          email: data['email']
                      )));
        } else {
          // String bed_time = '${bedTime!.hour}:${bedTime.minute}';
          // String wake_time = '${wakeTime!.hour}:${wakeTime.minute}';
          String bed_time = bedTime!.format(context); // Proper AM/PM format
          String wake_time = wakeTime!.format(context); // Proper AM/PM format
          await FirebaseFirestore.instance
              .collection('bed-time-schedule')
              .doc(user.uid)
              .set({
            'bed-time': bed_time,
            'wakeup-time': wake_time,
            'createdAt': DateTime.now().toIso8601String(),
          });
          Provider.of<SleepTimerProvider>(context, listen: false)
              .startDailySleepTimer(bedTime, wakeTime);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Sleeping schedule saved successfully!')),
          );
        }
      }
    } catch (e) {
      print("Error saving goal: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save schedule!')),
      );
    }
  }

}