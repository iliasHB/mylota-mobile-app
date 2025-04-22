import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotification(
      Function(String? payload) onNotificationTap) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) async {
        // Handle the tap on the notification
        if (notificationResponse.payload != null) {
          print('Notification tapped: ${notificationResponse.payload}');
          // Call the passed callback function with the payload
          onNotificationTap(notificationResponse.payload);
        }
      },
    );
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelTitle,
    required String channelDesc,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelTitle,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true, // Opens the app like an alarm
      ongoing: true, // Keeps the notification active until dismissed
      autoCancel: true, // Prevents auto-dismiss when tapped
      visibility: NotificationVisibility.public,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id,
      title,
      "${body} Tap to dismiss.",
      platformChannelSpecifics,
    );
  }

  // Schedule the repeating reminder at a specific time daily
  static Future<void> scheduleRepeatingReminder(
      String intakeLiters, int hour, int minute) async {
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
      'water_channel',
      'Water Intake',
      channelDescription: 'Reminder to drink water daily',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true, // Opens the app like an alarm
      ongoing: true, // Keeps the notification active until dismissed
      autoCancel: true, // Prevents auto-dismiss when tapped
      visibility: NotificationVisibility.public,
    );

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    final now = DateTime.now();
    final reminderDateTime =
        DateTime(now.year, now.month, now.day, hour, minute);

    final initialDelay = reminderDateTime.isBefore(now)
        ? reminderDateTime.add(const Duration(days: 1)).difference(now)
        : reminderDateTime.difference(now);

    // Schedule the notification to repeat every 24 hours at the same time
    await _notificationsPlugin.zonedSchedule(
      12,
      '💧 Water Reminder',
      'Remember to drink $intakeLiters liters of water today!',
      tz.TZDateTime.from(now.add(initialDelay), tz.local),
      platformDetails,
      payload: 'waterReminderTap',
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static void scheduleRepeatingMealReminder(
      String meal,
      String? selectedCategory,
      String? selectedDayCategory,
      String? selectedItem,
      String? selectedItem2, int reminderHour, int reminderMinute) async {
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
      'meal_channel',
      'Meal Schedule',
      channelDescription: 'Reminder to take your daily meal',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true, // Opens the app like an alarm
      ongoing: true, // Keeps the notification active until dismissed
      autoCancel: true, // Prevents auto-dismiss when tapped
      visibility: NotificationVisibility.public,
    );

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    final now = DateTime.now();
    final reminderDateTime =
        DateTime(now.year, now.month, now.day, reminderHour, reminderMinute);

    final initialDelay = reminderDateTime.isBefore(now)
        ? reminderDateTime.add(const Duration(days: 1)).difference(now)
        : reminderDateTime.difference(now);

    // Schedule the notification to repeat every 24 hours at the same time
    await _notificationsPlugin.zonedSchedule(
      13,
      '🍱 Meal Reminder',
      'Remember to have your $meal today',
      tz.TZDateTime.from(now.add(initialDelay), tz.local),
      platformDetails,
      payload: 'mealReminderTap',
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleRepeatingToDoReminder(
      task, int reminderHour, int reminderMinute, String reminderDate) async {
    AndroidNotificationDetails androidDetails =
    const AndroidNotificationDetails(
      'todo_channel',
      'To-do Schedule',
      channelDescription: 'Reminder to the task today',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true, // Opens the app like an alarm
      ongoing: true, // Keeps the notification active until dismissed
      autoCancel: true, // Prevents auto-dismiss when tapped
      visibility: NotificationVisibility.public,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
    );
    // await _notificationsPlugin.show(
    //   13,
    //   '🍱 To-do Reminder',
    //   'Remember to do $task today',
    //   platformChannelSpecifics,
    // );

    final now = reminderDate as DateTime;
    final reminderDateTime =
    DateTime(now.year, now.month, now.day, reminderHour, reminderMinute);

    final initialDelay = reminderDateTime.isBefore(now)
        ? reminderDateTime.add(const Duration(days: 1)).difference(now)
        : reminderDateTime.difference(now);

    // Schedule the notification to repeat every 24 hours at the same time
    await _notificationsPlugin.zonedSchedule(
      13,
      '🍱 To-do Reminder',
      'Remember to do $task today',
      tz.TZDateTime.from(now.add(initialDelay), tz.local),
      platformChannelSpecifics,
      payload: 'toDoReminderTap',
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Handle the notification received
  }

  static Future selectNotification(String? payload) async {
    // Handle the notification tapped logic
  }

  // Cancel all notifications
  static Future<void> cancelWaterIntakeReminder() async {
    await _notificationsPlugin.cancel(12);
  }

  static Future<void> cancelMealReminder() async {
    await _notificationsPlugin.cancel(13);
  }

  static cancelToDoReminder() async {
    await _notificationsPlugin.cancel(11);
  }
}
