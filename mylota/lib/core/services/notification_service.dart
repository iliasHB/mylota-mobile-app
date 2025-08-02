import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

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

  // ✅ Add this method that was missing
  static Future<void> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    
    if (status.isGranted) {
      print('✅ Notification permission granted');
    } else {
      print('❌ Notification permission denied');
    }
  }

  static Future<void> showImmediateNotification({
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
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: true,
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

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
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
      fullScreenIntent: true,
      ongoing: false,
      autoCancel: true,
      visibility: NotificationVisibility.public,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.zonedSchedule(
      id, 
      title, 
      body, 
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ✅ ADD MISSING METHODS FOR WATER INTAKE
  
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
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: true,
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

  // Cancel water intake reminder
  static Future<void> cancelWaterIntakeReminder() async {
    await _notificationsPlugin.cancel(12);
  }

  // ✅ ADD MISSING METHODS FOR MEAL PLANNER

  static void scheduleRepeatingMealReminder(
      String meal,
      String? selectedCategory,
      String? selectedDayCategory,
      String? selectedItem,
      String? selectedItem2,
      int reminderHour,
      int reminderMinute,
      ) async {
    const androidDetails = AndroidNotificationDetails(
      'meal_channel',
      'Meal Schedule',
      channelDescription: 'Reminder to take your daily meal',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: true,
      visibility: NotificationVisibility.public,
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderHour,
      reminderMinute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      13,
      '🍱 Meal Reminder',
      'Remember to have your $meal today',
      scheduledDate,
      platformDetails,
      payload: 'mealReminderTap|$selectedCategory',
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Cancel meal reminder
  static Future<void> cancelMealReminder() async {
    await _notificationsPlugin.cancel(13);
  }

  // ✅ ADD MISSING METHODS FOR TODO SCHEDULE

  static Future<void> scheduleOneTimeToDoReminder(
      String task,
      int reminderHour,
      int reminderMinute,
      String reminderDate,
      ) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'todo_channel',
      'To-do Schedule',
      channelDescription: 'Reminder to complete your task',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      ongoing: false,
      autoCancel: true,
      visibility: NotificationVisibility.public,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
    );

    DateTime reminderDateFormat = reminderDate as DateTime;
    final scheduledDate = DateTime(
      reminderDateFormat.year,
      reminderDateFormat.month,
      reminderDateFormat.day,
      reminderHour,
      reminderMinute,
    );

    if (scheduledDate.isBefore(DateTime.now())) return;

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notificationsPlugin.zonedSchedule(
      14,
      '✅ To-do Reminder',
      'Don\'t forget: $task',
      tzDateTime,
      platformChannelSpecifics,
      payload: 'toDoReminderTap|$task',
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Cancel todo reminder
  static cancelToDoReminder() async {
    await _notificationsPlugin.cancel(14);
  }

  // ✅ ADDITIONAL UTILITY METHODS

  static Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Handle the notification received
  }

  static Future selectNotification(String? payload) async {
    // Handle the notification tapped logic
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Cancel specific notification by ID
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
