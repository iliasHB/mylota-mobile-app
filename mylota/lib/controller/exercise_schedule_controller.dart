import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mylota/utils/pref_util.dart';
import 'package:provider/provider.dart';

import '../core/usecase/provider/exercise_timer_provider.dart';

class ExerciseScheduleController {

  static Future<void> saveExerciseGoal(
      String? selectedItem, double _exerciseGoal, BuildContext context,
      {required VoidCallback onStartLoading,
      required VoidCallback onStopLoading}) async {
    try {

      onStartLoading();
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in!");
        return;
      }

      await FirebaseFirestore.instance
          .collection('exercise-goals')
          .doc(user.uid) // Save goal under user's UID
          .set({
        'exercise': selectedItem,
        'goal_minutes': _exerciseGoal,
        'createdAt': DateTime.now().toIso8601String(),
      });

      onStopLoading();

      /// Save data to shared preferences for background service
      PrefUtils prefUtils = PrefUtils();
      await prefUtils.setInt('exercise_minutes', _exerciseGoal.toInt());
      await prefUtils.setExerciseStr('exercise_name', selectedItem!);

      /// Start background service
      final service = FlutterBackgroundService();
      await service.startService();

      Provider.of<ExerciseTimerProvider>(context, listen: false)
          .startTimer(_exerciseGoal.toInt(), selectedItem!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise goal saved successfully!')),
      );
    } catch (e) {
      print("Error saving goal: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save goal!')),
      );
    }
  }
}
