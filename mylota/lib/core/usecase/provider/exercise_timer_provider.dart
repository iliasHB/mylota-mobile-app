import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../services/notification_service.dart';

class ExerciseTimerProvider with ChangeNotifier {
  int _remainingTime = 0;
  String _exerciseName = '';
  Timer? _timer;

  int get remainingTime => _remainingTime;
  String get exerciseName => _exerciseName;

  // final FlutterLocalNotificationsPlugin _notificationsPlugin =
  // FlutterLocalNotificationsPlugin();

  void startTimer(int minutes, String name) {
    _remainingTime = minutes * 60;
    _exerciseName = name;
    _timer?.cancel();
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        NotificationService.showNotification(
          id: 9,
          title: 'Exercise Complete! 💪',
          body: 'You finished $_exerciseName!.',
          channelId: 'exercise_timer_channel',
          channelTitle: 'Exercise Timer',
          channelDesc: 'Notifies when your exercise ends',
        );
        timer.cancel();
        // _showNotification(); // Send notification here
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _remainingTime = 0;
    _exerciseName = '';
    notifyListeners();
  }

  // Future<void> _showNotification() async {
  //   const AndroidNotificationDetails androidDetails =
  //   AndroidNotificationDetails(
  //     'exercise_timer_channel',
  //     'Exercise Timer',
  //     channelDescription: 'Notifies when your exercise ends',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //
  //   const NotificationDetails platformDetails =
  //   NotificationDetails(android: androidDetails);
  //
  //   await _notificationsPlugin.show(
  //     0,
  //     'Exercise Complete! 💪',
  //     'You finished $_exerciseName!',
  //     platformDetails,
  //   );
  // }
}


// class ExerciseTimerProvider with ChangeNotifier {
//   int _remainingTime = 0; // Remaining time in seconds
//   String _exerciseName = ''; // Exercise name
//   Timer? _timer;
//
//   int get remainingTime => _remainingTime;
//   String get exerciseName => _exerciseName;
//
//   void startTimer(int minutes, String name) {
//     _remainingTime = minutes * 60; // Convert minutes to seconds
//     _exerciseName = name; // Set exercise name
//     _timer?.cancel(); // Cancel any existing timer
//     notifyListeners(); // Notify listeners of change
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_remainingTime > 0) {
//         _remainingTime--;
//         notifyListeners();
//       } else {
//         timer.cancel();
//       }
//     });
//   }
//
//   void stopTimer() {
//     _timer?.cancel();
//     _remainingTime = 0;
//     _exerciseName = ''; // Clear exercise name
//     notifyListeners();
//   }
// }