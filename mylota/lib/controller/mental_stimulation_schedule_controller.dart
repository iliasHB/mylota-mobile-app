import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mylota/utils/pref_util.dart';

import '../widgets/subscription_alert.dart';

class MentalStimulationScheduleController {
  static Future<void> saveLearningJourney(
    String? learningTask,
    DateTime? startDateTime,
    DateTime? endDateTime,
    BuildContext context, {
    required VoidCallback onStartLoading,
    required VoidCallback onStopLoading,
  }) async {
    try {
      onStartLoading();
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
          onStopLoading();
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
          await FirebaseFirestore.instance
              .collection('learning-journeys')
              .doc(user.uid)
              .set({
            'task': learningTask,
            'start_time': startDateTime?.toIso8601String(),
            'end_time': endDateTime?.toIso8601String(),
            'createdAt': DateTime.now().toIso8601String(),
          });

          onStopLoading();

          // Save data to shared preferences for background service
          PrefUtils prefUtils = PrefUtils();
          if (startDateTime != null && endDateTime != null) {
            final int learningMinutes =
                endDateTime
                    .difference(startDateTime)
                    .inMinutes;
            await prefUtils.setInt('learning_minutes', learningMinutes);
          }
          await prefUtils.setExerciseStr('learning_task', learningTask ?? '');

          // Start background service for mental stimulation
          final service = FlutterBackgroundService();
          await service.startService();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Learning journey saved successfully!')),
          );
        }
      }
    } catch (e) {
      onStopLoading();
      print("Error saving learning journey: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save learning journey!')),
      );
    }
  }
}