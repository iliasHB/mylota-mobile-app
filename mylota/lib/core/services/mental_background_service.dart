import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mylota/utils/pref_util.dart';

Future<void> initializeMentalService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onMentalStart,
      autoStart: true,
      isForegroundMode: true,
      autoStartOnBoot: true,
      initialNotificationContent: 'Preparing your learning journey...',
      initialNotificationTitle: 'Mental Stimulation Service',
      foregroundServiceNotificationId: 889,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onMentalStart,
      onBackground: onIosMentalBackground,
    ),
  );

  service.startService();
}

bool onIosMentalBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

void onMentalStart(ServiceInstance service) async {
  // Initialize preferences utility to get stored values
  final prefs = PrefUtils();
  int remainingTime = await prefs.getInt('learning_minutes') ?? 10; // Get remaining learning time, default to 10
  String learningTask = await prefs.getExerciseStr('learning_task') ?? ''; // Get learning task name

  // If learning task is not empty, start a timer to count down
  if (learningTask.isNotEmpty) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingTime--;
      // When time is up, show a notification and stop the service
      if (remainingTime <= 0) {
        FlutterLocalNotificationsPlugin().show(
          889,
          'Learning Journey Complete! 🎓',
          'You finished $learningTask!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'learning_timer_channel',
              'Learning Timer',
              channelDescription: 'Notifies when your learning journey ends',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
        timer.cancel();
        service.stopSelf();
      }
    });
  }

  // Listen for foreground/background commands and stop service if requested
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}