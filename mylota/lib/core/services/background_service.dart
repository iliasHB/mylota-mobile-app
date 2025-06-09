import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mylota/utils/pref_util.dart';


Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        autoStartOnBoot: true,
        // notificationChannelId: '',
        initialNotificationContent: 'Initializing...',
        initialNotificationTitle: 'MyLota Service',
        foregroundServiceNotificationId: 888
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

void onStart(ServiceInstance service) async {

  // Initialize preferences utility to get stored values
  final prefs = PrefUtils();//await SharedPreferences.getInstance();
  int remainingTime = await prefs.getInt('exercise_minutes') ?? 10; // Get remaining exercise time, default to 10
  String exerciseName = await prefs.getExerciseStr('exercise_name') ?? ''; // Get exercise name

  // If exercise name is not empty, start a timer to count down
  if(exerciseName.isNotEmpty || exerciseName != "") {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingTime--;
      // When time is up, show a notification and stop the service
      if (remainingTime <= 0) {
        FlutterLocalNotificationsPlugin().show(
          888,
          'Exercise bg Complete! 💪',
          'You finished $exerciseName!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'exercise_timer_channel',
              'Exercise Timer',
              channelDescription: 'Notifies when your exercise ends',
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
  if(service is AndroidServiceInstance){
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

