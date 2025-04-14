import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../main.dart';
import '../../../services/notifications_service.dart';
import '../../services/notification_service.dart';



class SleepTimerProvider with ChangeNotifier {
  Timer? _countdownTimer;
  Duration? _remaining;
  bool _isCounting = false;

  bool get isCounting => _isCounting;
  Duration? get remaining => _remaining;

  void startDailySleepTimer(TimeOfDay bedTime, TimeOfDay wakeTime) {
    _scheduleNextSleepCountdown(bedTime, wakeTime);
  }

  void _scheduleNextSleepCountdown(TimeOfDay bedTime, TimeOfDay wakeTime) {
    final now = DateTime.now();
    final todayBedTime = DateTime(
      now.year,
      now.month,
      now.day,
      bedTime.hour,
      bedTime.minute,
    );

    final nextBedTime = now.isAfter(todayBedTime)
        ? todayBedTime.add(const Duration(days: 1))
        : todayBedTime;

    final waitDuration = nextBedTime.difference(now);
    Timer(waitDuration, () {
      _startSleepCountdown(bedTime, wakeTime);
    });
  }
  void _startSleepCountdown(TimeOfDay bedTime, TimeOfDay wakeTime) {
    final bedDateTime = _timeOfDayToDateTime(bedTime);
    final wakeDateTime = _timeOfDayToDateTime(wakeTime, addOneDayIfNeeded: true);

    final duration = wakeDateTime.difference(bedDateTime);

    _remaining = duration;
    _isCounting = true;
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining!.inSeconds <= 0) {
        timer.cancel();
        _isCounting = false;
        _remaining = null;
        notifyListeners();
        // Show a notification
        NotificationService.showNotification(
          id: 0,
          title: 'Good Morning!',
          body: 'Time to wake up! 🌅. ',
          channelId: 'sleep_channel_id',
          channelTitle: 'Sleep Timer',
          channelDesc: 'Notifies you when it’s time to wake up',
        );
        // _showWakeUpNotification();
        return;
      }
      _remaining = _remaining! - const Duration(seconds: 1);
      notifyListeners();
    });
  }


  // Future<void> _showWakeUpNotification() async {
  //   const AndroidNotificationDetails androidDetails =
  //   AndroidNotificationDetails(
  //     'sleep_channel_id',
  //     'Sleep Timer',
  //     channelDescription: 'Notifies you when it’s time to wake up',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //
  //   const NotificationDetails platformDetails =
  //   NotificationDetails(android: androidDetails);
  //
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Good Morning!',
  //     'Time to wake up! 🌅',
  //     platformDetails,
  //   );
  // }

  ///
  // void _startSleepCountdown(TimeOfDay bedTime, TimeOfDay wakeTime) {
  //   final bedDateTime = _timeOfDayToDateTime(bedTime);
  //   final wakeDateTime = _timeOfDayToDateTime(wakeTime, addOneDayIfNeeded: true);
  //
  //   final duration = wakeDateTime.difference(bedDateTime);
  //
  //   _remaining = duration;
  //   _isCounting = true;
  //   notifyListeners();
  //
  //   _countdownTimer?.cancel();
  //   _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (_remaining!.inSeconds <= 0) {
  //       timer.cancel();
  //       _isCounting = false;
  //       notifyListeners();
  //       return;
  //     }
  //     _remaining = _remaining! - const Duration(seconds: 1);
  //     notifyListeners();
  //   });
  // }

  DateTime _timeOfDayToDateTime(TimeOfDay time, {bool addOneDayIfNeeded = false}) {
    final now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (addOneDayIfNeeded && dt.isBefore(now)) {
      dt = dt.add(const Duration(days: 1));
    }
    return dt;
  }

  void stopTimer() {
    _countdownTimer?.cancel();
    _isCounting = false;
    _remaining = null;
    notifyListeners();
  }
}