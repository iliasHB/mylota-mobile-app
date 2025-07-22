import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/usecase/provider/sleep_timer_provider.dart';

class SleepScheduleController {
  static Future<void> saveSleepGoal(
    TimeOfDay? bedTime,
    TimeOfDay? wakeTime,
    BuildContext context,
  ) async {
    if (bedTime == null || wakeTime == null) return;
    
    try {
      Provider.of<SleepTimerProvider>(context, listen: false)
          .startDailySleepTimer(bedTime, wakeTime);
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('sleep-goals')
            .doc(user.uid)
            .set({
          'bedtime': '${bedTime.hour}:${bedTime.minute}',
          'wake_time': '${wakeTime.hour}:${wakeTime.minute}',
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      
      print('✅ Sleep goal saved successfully');
      
    } catch (e) {
      print('❌ Error saving sleep goal: $e');
    }
  }
}