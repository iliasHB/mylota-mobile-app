import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mylota/utils/pref_util.dart';

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
            endDateTime.difference(startDateTime).inMinutes;
        await prefUtils.setInt('learning_minutes', learningMinutes);
      }
      await prefUtils.setExerciseStr('learning_task', learningTask ?? '');

      // Start background service for mental stimulation
      final service = FlutterBackgroundService();
      await service.startService();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Learning journey saved successfully!')),
      );
    } catch (e) {
      print("Error saving learning journey: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save learning journey!')),
      );
    }
  }
}