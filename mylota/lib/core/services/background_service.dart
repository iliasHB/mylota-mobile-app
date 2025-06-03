
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

  final prefs = PrefUtils();//await SharedPreferences.getInstance();
  int remainingTime = await prefs.getInt('exercise_minutes') ?? 10;
  String exerciseName = await prefs.getExerciseStr('exercise_name') ?? '';

  if(exerciseName.isNotEmpty || exerciseName != "") {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingTime--;
      if (remainingTime <= 0) {
        FlutterLocalNotificationsPlugin().show(
          9,
          'Exercise Complete! 💪',
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

  // DartPluginRegistrant.ensureInitialized();
  // Random random = Random();
  // int randomNumber = random.nextInt(100);
  // // Register MQTTClient
  // // final mqttClient = MqttServerClient(privateBrokerAddress, randomNumber.toString());
  // // final mqttClientManager = MQTTClientManager(mqttClient);
  //
  // // Connect to MQTT broker
  // // mqttClientManager.connect();
  //
  // // Listen for MQTT messages and trigger a notification
  // // mqttClientManager.onMessageReceived().listen((message) {
  //   // Trigger local notification
  //   FlutterLocalNotificationsPlugin().show(
  //       888, // Notification ID
  //       "MyLota",
  //       "Message: Initializing...",
  //       const NotificationDetails(
  //           android:
  //           AndroidNotificationDetails('MyLota', 'Notification',
  //             channelDescription: 'MyLota update',
  //             importance: Importance.max,
  //             priority: Priority.high,)
  //       )
  //   );
  // });



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

