//
// import 'dart:math';
// import 'dart:ui';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:smarte/core/constants/api_address.dart';
// import 'mqtt_client_manager.dart';
//
// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//         onStart: onStart,
//         autoStart: true,
//         isForegroundMode: true,
//         autoStartOnBoot: true,
//         // notificationChannelId: '',
//         initialNotificationContent: 'Initializing...',
//         initialNotificationTitle: 'SmartE Service',
//         foregroundServiceNotificationId: 888
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: true,
//       onForeground: onStart,
//       onBackground: onIosBackground,
//     ),
//   );
//
//   service.startService();
// }
//
// bool onIosBackground(ServiceInstance service) {
//   WidgetsFlutterBinding.ensureInitialized();
//   return true;
// }
//
// void onStart(ServiceInstance service) {
//   DartPluginRegistrant.ensureInitialized();
//   Random random = Random();
//   int randomNumber = random.nextInt(100);
//   // Register MQTTClient
//   final mqttClient = MqttServerClient(privateBrokerAddress, randomNumber.toString());
//   final mqttClientManager = MQTTClientManager(mqttClient);
//
//   // Connect to MQTT broker
//   mqttClientManager.connect();
//
//   // Listen for MQTT messages and trigger a notification
//   mqttClientManager.onMessageReceived().listen((message) {
//     // Trigger local notification
//     FlutterLocalNotificationsPlugin().show(
//         888, // Notification ID
//         "SmartE",
//         "Message: $message",
//         const NotificationDetails(
//             android:
//             AndroidNotificationDetails('Sbc', 'Notification',
//               channelDescription: 'Sbc update',
//               importance: Importance.max,
//               priority: Priority.high,)
//         )
//     );
//   });
//
//
//
//   if(service is AndroidServiceInstance){
//     service.on('setAsForeground').listen((event) {
//       service.setAsForegroundService();
//     });
//
//     service.on('setAsBackground').listen((event) {
//       service.setAsBackgroundService();
//     });
//   }
//
//   service.on('stopService').listen((event) {
//     service.stopSelf();
//   });
//
// }
//
