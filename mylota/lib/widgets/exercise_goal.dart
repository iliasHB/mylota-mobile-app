import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mylota/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../controller/exercise_schedule_controller.dart';
import '../core/usecase/provider/exercise_timer_provider.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

import '../utils/styles.dart';
import 'custom_input_decorator.dart';

class ExerciseGoal extends StatefulWidget {
  @override
  _ExerciseGoalState createState() => _ExerciseGoalState();
}

class _ExerciseGoalState extends State<ExerciseGoal> {
  double _exerciseGoal = 1.0;
  bool isLoading = false;
  String _selectedExercise = 'Running';

  List<String> dropdownItems = [];
  String? selectedItem;

  void _startLoading() => setState(() => isLoading = true);
  void _stopLoading() => setState(() => isLoading = false);

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection("user-inputs")
          .doc(
              "yQtkG0iE0dA0tcrQ8RAW") //3l8kubMtLGsE1kRn9FGN  Change this to your document ID
          .get();

      if (docSnapshot.exists) {
        List<dynamic> data = docSnapshot["exercise-goal"];
        setState(() {
          dropdownItems = List<String>.from(data);
          if (dropdownItems.isNotEmpty) {
            selectedItem = dropdownItems.first; // Default selection
          }
        });
      }
    } catch (e) {
      print("Error fetching dropdown data: $e");
    }
  }

  _exercise(String? selectedItem, double exerciseGoal, BuildContext context) {
    ExerciseScheduleController.saveExerciseGoal(
      selectedItem,
      _exerciseGoal,
      context,
      onStartLoading: _startLoading,
      onStopLoading: _stopLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set Your Exercise Goal', style: AppStyle.cardfooter),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
              value: selectedItem,
              items: dropdownItems.map<DropdownMenuItem<String>>((exercise) {
                return DropdownMenuItem<String>(
                  value: exercise,
                  child: Text(
                    exercise,
                    style: AppStyle.cardfooter.copyWith(fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedItem = value;
                });
              },
              decoration: customInputDecoration(
                labelText: '',
                hintText: 'Choose a exercise',
                prefixIcon:
                    const Icon(Icons.run_circle_outlined, color: Colors.green),
              )),
          const SizedBox(height: 20),
          Text(
            'Set your daily goal (minutes):',
            style: AppStyle.cardfooter,
          ),
          const SizedBox(height: 10),
          Slider(
            value: _exerciseGoal,
            min: 0,
            max: 120,
            divisions: 11,
            activeColor: const Color(0xFF66C3A7), // Updated slider color
            thumbColor: const Color(0xFF2A7F67), // Thumb color for consistency
            label: '${_exerciseGoal.round()} mins',
            onChanged: (value) {
              setState(() {
                _exerciseGoal = value;
              });
            },
          ),
          Center(
              child: Text(
            "${_exerciseGoal.toInt()} min",
            style: AppStyle.cardfooter,
          )),
          const SizedBox(height: 20),
          isLoading
              ? const CustomContainerLoadingButton()
              : Center(
                  child: CustomPrimaryButton(
                      label: 'Save Goal',
                      onPressed: () =>
                          _exercise(selectedItem, _exerciseGoal, context)))
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Alarm Permission'),
        content: const Text(
            'This app requires exact alarm permission to remind you about your goals. '
            'Please enable it in settings.'),
        actions: [
          TextButton(
            onPressed: () async {
              const intent = AndroidIntent(
                action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
                package: 'com.example.mylota',
                flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
              );
              await intent.launch();
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// Future<void> _saveExerciseGoal() async {
//     try {
//       await _checkAndRequestAlarmPermission();
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setDouble('exerciseGoal', _exerciseGoal);
//       await prefs.setString('selectedExercise', _selectedExercise);
//
//       await NotificationService.scheduleExerciseReminder(8, 0);
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Exercise goal and reminder set!'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to save goal: $e'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }
