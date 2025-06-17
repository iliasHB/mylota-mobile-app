import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mylota/widgets/custom_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';

Future<void> requestPermissions() async {
  if(Platform.isAndroid || Platform.isIOS){
    var notification = await Permission.notification.status;
    var photos = await Permission.photos.status;
    var camera = await Permission.camera.status;
    var storage = await Permission.storage.status;
    var alarm = await Permission.scheduleExactAlarm.status;
    if(notification.isDenied){
      await Permission.notification.request();
    }
    if(photos.isDenied){
      await Permission.photos.request();
    }
    if(camera.isDenied){
      await Permission.camera.request();
    }
    if(photos.isDenied){
      await Permission.photos.request();
    }
    if(storage.isDenied){
      await Permission.storage.request();
    }

    if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 31) {
      //var status = await Permission.scheduleExactAlarm.status;
      if(alarm.isDenied){
        await Permission.scheduleExactAlarm.request();
      }
      // if (!status.isGranted) {
      //   // Open system settings for exact alarms
      //   const intent = AndroidIntent(
      //     action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      //   );
      //   await intent.launch();
      //   // Optionally, show a dialog to explain to the user
      //   if (context.mounted) {
      //     showDialog(
      //       context: context,
      //       builder: (_) => AlertDialog(
      //         title: const Text('Allow Exact Alarms'),
      //         content: const Text(
      //             'To receive timely reminders, please allow "Schedule exact alarms" for MyLota in system settings.'),
      //         actions: [
      //           CustomPrimaryButton(
      //             label: 'OK',
      //             onPressed: () => Navigator.pop(context),
      //           ),
      //         ],
      //       ),
      //     );
      //   }
      // }
    }
  }
  }
}

Future<void> requestNotificationPermission(BuildContext context) async {
  // Request notification permission
  await Permission.notification.request();

  // For Android 12+ (API 31+), request exact alarm permission
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 31) {
      var status = await Permission.scheduleExactAlarm.status;
      if (!status.isGranted) {
        // Open system settings for exact alarms
        const intent = AndroidIntent(
          action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        );
        await intent.launch();
        // Optionally, show a dialog to explain to the user
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Allow Exact Alarms'),
              content: const Text(
                  'To receive timely reminders, please allow "Schedule exact alarms" for MyLota in system settings.'),
              actions: [
                CustomPrimaryButton(
                  label: 'OK',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      }
    }
  }
}
