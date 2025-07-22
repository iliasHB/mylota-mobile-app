import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';

class SleepAlarmService {
  static const int SLEEP_ALARM_ID = 1000;
  static const int WAKE_ALARM_ID = 1001;

  // ✅ SET BEDTIME ALARM (system alarm)
  static Future<bool> setBedtimeAlarm({
    required TimeOfDay bedtime,
    required String message,
  }) async {
    try {
      // ✅ USE SYSTEM ALARM APP
      final intent = AndroidIntent(
        action: 'android.intent.action.SET_ALARM',
        arguments: <String, dynamic>{
          'android.intent.extra.alarm.HOUR': bedtime.hour,
          'android.intent.extra.alarm.MINUTES': bedtime.minute,
          'android.intent.extra.alarm.MESSAGE': message,
          'android.intent.extra.alarm.VIBRATE': true,
          'android.intent.extra.alarm.SKIP_UI': false,
        },
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      await intent.launch();
      print('✅ Bedtime alarm set for ${bedtime.hour}:${bedtime.minute}');
      return true;
    } catch (e) {
      print('❌ Error setting bedtime alarm: $e');
      return false;
    }
  }

  // ✅ SET WAKE UP ALARM (system alarm)
  static Future<bool> setWakeUpAlarm({
    required TimeOfDay wakeTime,
    required String message,
    bool recurring = true,
  }) async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.SET_ALARM',
        arguments: <String, dynamic>{
          'android.intent.extra.alarm.HOUR': wakeTime.hour,
          'android.intent.extra.alarm.MINUTES': wakeTime.minute,
          'android.intent.extra.alarm.MESSAGE': message,
          'android.intent.extra.alarm.VIBRATE': true,
          'android.intent.extra.alarm.SKIP_UI': false,
        },
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      await intent.launch();
      print('✅ Wake up alarm set for ${wakeTime.hour}:${wakeTime.minute}');
      return true;
    } catch (e) {
      print('❌ Error setting wake up alarm: $e');
      return false;
    }
  }

  // ✅ SHOW ALARM SETTINGS
  static Future<void> openAlarmApp() async {
    try {
      const intent = AndroidIntent(
        action: 'android.intent.action.SHOW_ALARMS',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (e) {
      print('❌ Error opening alarm app: $e');
      try {
        const intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          category: 'android.intent.category.LAUNCHER',
          package: 'com.google.android.deskclock',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
      } catch (e2) {
        print('❌ Error opening clock app: $e2');
      }
    }
  }

  // ✅ CALCULATE SLEEP DURATION
  static Duration calculateSleepDuration(TimeOfDay bedtime, TimeOfDay wakeTime) {
    final now = DateTime.now();
    final bedDateTime = DateTime(now.year, now.month, now.day, bedtime.hour, bedtime.minute);
    DateTime wakeDateTime = DateTime(now.year, now.month, now.day + 1, wakeTime.hour, wakeTime.minute);

    // If wake time is after bedtime on same day, don't add a day
    if (wakeTime.hour > bedtime.hour || 
        (wakeTime.hour == bedtime.hour && wakeTime.minute > bedtime.minute)) {
      wakeDateTime = DateTime(now.year, now.month, now.day, wakeTime.hour, wakeTime.minute);
    }

    return wakeDateTime.difference(bedDateTime);
  }
}