import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:mylota/utils/pref_util.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../controller/sleep_schedule_controller.dart';
import '../core/usecase/provider/sleep_timer_provider.dart';
import '../utils/styles.dart';

class SleepGoal extends StatefulWidget {
  @override
  _SleepGoalState createState() => _SleepGoalState();
}

class _SleepGoalState extends State<SleepGoal> {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  PrefUtils prefUtils =PrefUtils();
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Los_Angeles'));
  }

  Future<void> _pickTime(BuildContext context, bool isBedTime) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: isBedTime
          ? (_bedTime ?? const TimeOfDay(hour: 22, minute: 0))
          : (_wakeTime ?? const TimeOfDay(hour: 6, minute: 0))
    );

    // if (pickedTime != null) {
    //   setState(() {
    //     if (isBedTime) {
    //       _bedTime = pickedTime;
    //       prefUtils.setStr("bedTime", _bedTime);
    //       print("Bedtime set to: ${_bedTime}");
    //       print("Bedtime saved to preferences: ${prefUtils.getStr("bedTime").toString()}");
    //     } else {
    //       _wakeTime = pickedTime;
    //       prefUtils.setStr("wakeTime", _wakeTime);
    //     }
    //   });
      
    //   if (_bedTime != null && _wakeTime != null) {
    //     SleepScheduleController.saveSleepGoal(_bedTime, _wakeTime, context);
    //     _scheduleAlarm();
    //   }
    // }
if (pickedTime != null) {
  setState(() async {
    if (isBedTime) {
      _bedTime = pickedTime;
      // Convert TimeOfDay to String before saving
      final bedTimeString = _bedTime!.format(context);
      await prefUtils.setStr("bedTime", bedTimeString); // Await the async method
      print("Bedtime set to: $bedTimeString");
      print("Bedtime saved to preferences: ${await prefUtils.getStr("bedTime")}"); // Await the getStr method
    } else {
      _wakeTime = pickedTime;
      // Convert TimeOfDay to String before saving
      final wakeTimeString = _wakeTime!.format(context);
      await prefUtils.setStr("wakeTime", wakeTimeString); // Await the async method
    }
  });

  if (_bedTime != null && _wakeTime != null) {
    SleepScheduleController.saveSleepGoal(_bedTime, _wakeTime, context);
    _scheduleAlarm();
  }
}
  }

  

  void _scheduleAlarm() {
    DateTime now = DateTime.now();
    DateTime wakeUpDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _wakeTime!.hour,
      _wakeTime!.minute,
    );

    if (wakeUpDateTime.isBefore(now)) {
      wakeUpDateTime = wakeUpDateTime.add(const Duration(days: 1));
    }

    _saveSleepGoal(wakeUpDateTime);
    _scheduleNotification(wakeUpDateTime);
  }

  Future<void> _saveSleepGoal(DateTime wakeUpDateTime) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final sleepProvider = Provider.of<SleepTimerProvider>(context, listen: false);
      sleepProvider.updateSleepTimes(_bedTime!, _wakeTime!);

      final bedTimeMinutes = (_bedTime!.hour * 60) + _bedTime!.minute;
      final wakeTimeMinutes = (_wakeTime!.hour * 60) + _wakeTime!.minute;
      int durationMinutes;
      if (wakeTimeMinutes >= bedTimeMinutes) {
        durationMinutes = wakeTimeMinutes - bedTimeMinutes;
      } else {
        durationMinutes = (24 * 60 - bedTimeMinutes) + wakeTimeMinutes;
      }
      
      final durationHours = durationMinutes / 60.0;
      
      sleepProvider.updateFromSleepGoal(durationHours, _bedTime!, _wakeTime!);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sleep_alarm_time', wakeUpDateTime.toIso8601String());
      await prefs.setString('sleep_goal_name', 'Sleep Goal - ${durationHours.toStringAsFixed(1)} hours');
      await prefs.setBool('sleep_alarm_enabled', true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🌙 Sleep goal set successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      print('❌ Error saving sleep goal: $e');
    }
  }

  Future<void> _scheduleNotification(DateTime wakeUpDateTime) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'sleep_alarm_channel',
      'Sleep Alarms',
      channelDescription: 'Wake-up alarms for sleep goals',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      playSound: true,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999,
      '⏰ Wake Up!',
      'Time to wake up! Your sleep goal is complete.',
      tz.TZDateTime.from(wakeUpDateTime, tz.local),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    
    print('✅ Sleep alarm scheduled for: ${wakeUpDateTime.toLocal()}');
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
                  backgroundColor: const Color(0xFF2A7F67),
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
                  backgroundColor: const Color(0xFF2A7F67),
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
