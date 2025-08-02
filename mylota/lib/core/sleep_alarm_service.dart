// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:audioplayers/audioplayers.dart';
//
// class SleepAlarmService {
//   static const int sleepAlarmId = 1;
//
//   // Method to set the alarm
//   static Future<void> setSleepAlarm(Duration duration) async {
//     try {
//       // Schedule the alarm to fire after the specified duration
//       await AndroidAlarmManager.oneShot(
//         duration,
//         sleepAlarmId,
//         fireSleepAlarm,
//         exact: true,
//         wakeup: true,
//       );
//       print('✅ Sleep alarm set for ${DateTime.now().add(duration)}');
//     } catch (e) {
//       print('❌ Failed to set sleep alarm: $e');
//     }
//   }
//
//   // Method to cancel the alarm
//   static Future<void> cancelSleepAlarm() async {
//     try {
//       await AndroidAlarmManager.cancel(sleepAlarmId);
//       print('✅ Sleep alarm canceled');
//     } catch (e) {
//       print('❌ Failed to cancel sleep alarm: $e');
//     }
//   }
//
//   // Callback method for the alarm
//   static void fireSleepAlarm() {
//     print('⏰ Sleep alarm fired at ${DateTime.now()}');
//
//     // Play the alarm sound
//     final player = AudioPlayer();
//     player.play(DeviceFileSource('assets/sounds/alarm.mp3'));
//
//     // Debugging notification values
//     String notificationTitle = 'Sleep Goal Completed';
//     String notificationBody = 'You have successfully completed your sleep goal!';
//     print('Debug: notificationTitle = $notificationTitle');
//     print('Debug: notificationBody = $notificationBody');
//   }
// }
//
// // Set a test alarm for demonstration purposes
//     //   final dateTime = DateTime.now().add(const Duration(seconds: 10)); // Trigger after 10 seconds
//     //   final alarmSettings = AlarmSettings(
//     //     id: 42, // Unique ID for the alarm
//     //     dateTime: dateTime,
//     //     assetAudioPath: 'assets/alarm.mp3', // Path to your alarm sound
//     //     loopAudio: true,
//     //     vibrate: true,
//     //     volumeSettings: VolumeSettings.fade(
//     //       volume: 0.8,
//     //       fadeDuration: const Duration(seconds: 3),
//     //       volumeEnforced: true,
//     //     ),
//     //     notificationSettings: const NotificationSettings(
//     //       title: 'This is the title',
//     //       body: 'This is the body',
//     //       stopButton: 'Stop Alarm',
//     //       icon: 'notification_icon',
//     //       iconColor: Color(0xff862778),
//     //     ),
//     //   );
//
//     //   await Alarm.set(alarmSettings: alarmSettings);
//     //   print('✅ Test alarm set for ${dateTime.toLocal()}');
//     // } catch (e) {
//     //   print('⚠️ Alarm service failed: $e');
//     // }