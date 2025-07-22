import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mylota/utils/pref_util.dart';
import 'package:mylota/widgets/subscription_alert.dart';
import 'package:provider/provider.dart';

import '../core/usecase/provider/exercise_timer_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../controller/sleep_schedule_controller.dart';
import '../core/usecase/provider/sleep_timer_provider.dart';
import '../utils/styles.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      DocumentSnapshot docSnapshot = await userDoc.get();

      Map<String, dynamic> sub = {};
      // Map<String, dynamic> email = {};
      if (docSnapshot.exists && docSnapshot.data() != null) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
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
                  builder: (_) => SubscriptionAlert(
                      // plan: sub['type'],
                      // amount: sub['amount'],
                      email: data['email']
                  )));
        } else {
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

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exercise goal saved successfully!')),
          );
        }
      }
    } catch (e) {
      onStopLoading();
      print("Error saving goal: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save goal!')),
      );
    }
  }
}

class SleepGoal extends StatefulWidget {
  @override
  _SleepGoalState createState() => _SleepGoalState();
}

class _SleepGoalState extends State<SleepGoal> {
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon'); // Replace 'app_icon' with your app's icon name

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Los_Angeles')); // Replace with your timezone
  }

  Future<void> _pickTime(BuildContext context, bool isBedTime) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: isBedTime
          ? (_bedTime ?? const TimeOfDay(hour: 22, minute: 0))
          : (_wakeTime ?? const TimeOfDay(hour: 6, minute: 0)),
    );

    if (pickedTime != null) {
      setState(() {
        if (isBedTime) {
          _bedTime = pickedTime;
        } else {
          _wakeTime = pickedTime;
        }
      });
      if (_bedTime != null && _wakeTime != null) {
        SleepScheduleController.saveSleepGoal(
            _bedTime, _wakeTime, context);
        _scheduleAlarm(); // Schedule the alarm when both times are set
      }
    }
  }

  void _scheduleAlarm() {
    // Calculate the wake-up time as a DateTime object
    DateTime now = DateTime.now();
    DateTime wakeUpDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _wakeTime!.hour,
      _wakeTime!.minute,
    );

    // If the wake-up time is in the past, schedule it for the next day
    if (wakeUpDateTime.isBefore(now)) {
      wakeUpDateTime = wakeUpDateTime.add(const Duration(days: 1));
    }

    // Ensure the alarm time is in UTC
    wakeUpDateTime = wakeUpDateTime.toUtc();

    scheduleAlarm(wakeUpDateTime); // Schedule the alarm using flutter_local_notifications
  }

  Future<void> scheduleAlarm(DateTime wakeUpDateTime) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'alarm_channel', // Replace with your channel ID
      'Alarm', // Replace with your channel name
      channelDescription: 'Alarm for sleep goal', // Replace with your channel description
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Wake Up!', // Notification title
      'Time to wake up!', // Notification body
      tz.TZDateTime.from(wakeUpDateTime, tz.local),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_bedTime != null && _wakeTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
            child: Center(
              child: Text(
                'Sleep Duration: ${_calculateSleepDuration()} hours',
                style: AppStyle.cardfooter,
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _pickTime(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A7F67), // Default here
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _bedTime == null
                        ? 'Set Bedtime'
                        : 'Bedtime: ${_bedTime!.format(context)}',
                    style: AppStyle.cardSubtitle
                        .copyWith(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _pickTime(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A7F67), // Default here
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _wakeTime == null
                        ? 'Set Wake-up Time'
                        : 'Wake: ${_wakeTime!.format(context)}',
                    style: AppStyle.cardSubtitle
                        .copyWith(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _calculateSleepDuration() {
    final bedTimeMinutes = (_bedTime!.hour * 60) + _bedTime!.minute;
    final wakeTimeMinutes = (_wakeTime!.hour * 60) + _wakeTime!.minute;

    int durationMinutes;
    if (wakeTimeMinutes >= bedTimeMinutes) {
      durationMinutes = wakeTimeMinutes - bedTimeMinutes;
    } else {
      durationMinutes = (24 * 60 - bedTimeMinutes) + wakeTimeMinutes;
    }

    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '$hours:$minutes';
  }
}
