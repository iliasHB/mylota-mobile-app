import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mylota/utils/pref_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mylota/firebase_options.dart';
import 'package:intl/intl.dart';

// Global notification plugin instance
final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

// Global timer reference
Timer? _monitoringTimer;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // ✅ CRITICAL: Initialize Firebase in background isolate FIRST
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // ✅ REGISTER DART PLUGIN - VERY IMPORTANT
    DartPluginRegistrant.ensureInitialized();
    
    // ✅ Initialize Firebase with a small delay to ensure platform is ready
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized in background service');
    } else {
      print('✅ Firebase already initialized in background service');
    }
    
  } catch (e) {
    print('❌ Failed to initialize Firebase in background service: $e');
    service.stopSelf();
    return;
  }
  
  // ✅ Initialize preferences AFTER Firebase
  try {
    await PrefUtils.init();
    print('✅ PrefUtils initialized in background service');
  } catch (e) {
    print('❌ PrefUtils initialization failed: $e');
    service.stopSelf();
    return;
  }
  
  // ✅ Add a longer delay before starting monitoring to ensure everything is ready
  await Future.delayed(const Duration(seconds: 2));
  
  // Start monitoring with increased interval to reduce conflicts
  Timer.periodic(const Duration(seconds: 60), (timer) async { // ✅ Increased to 60 seconds
    try {
      // Update foreground notification
      if (service is AndroidServiceInstance) {
        await service.setForegroundNotificationInfo(
          title: "MyLota Active",
          content: "Monitoring your goals • ${DateFormat.Hm().format(DateTime.now())}",
        );
      }
      
      // Create fresh PrefUtils instance for each check
      final prefs = PrefUtils();
      
      // Check all goal types safely with additional checks
      await _safeCheckWithRetry(() => _checkExerciseGoals(prefs), 'exercise');
      await _safeCheckWithRetry(() => _checkSleepGoals(prefs), 'sleep');
      await _safeCheckWithRetry(() => _checkTodoItems(prefs), 'todo');
      await _safeCheckWithRetry(() => _checkWaterIntake(prefs), 'water');
      await _safeCheckWithRetry(() => _checkMealPlanner(prefs), 'meal');
      
    } catch (e) {
      print('Error in background service main loop: $e');
    }
  });

  // ✅ Listen for service commands
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    _monitoringTimer?.cancel();
    service.stopSelf();
  });
  
  print('✅ Background service started successfully');
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('iOS background service running');
  return true;
}

// ✅ Initialize service function (called from main.dart)
Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      autoStartOnBoot: true,
      initialNotificationContent: 'MyLota is starting...',
      initialNotificationTitle: 'MyLota Service',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  
  await service.startService();
  print('✅ Background service configured and started');
}

// ✅ SAFE WRAPPER FUNCTIONS (with Firebase checks)

Future<void> _safeCheckTodoItems(PrefUtils prefs) async {
  try {
    // ✅ Multiple Firebase checks
    if (Firebase.apps.isEmpty) {
      print('Firebase apps empty for todo check');
      return;
    }
    
    // ✅ Check if Firebase is actually ready
    try {
      await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
    } catch (e) {
      print('Firebase Auth not ready for todo check: $e');
      return;
    }
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user for todo check');
      return;
    }
    
    await _checkTodoItems(prefs);
  } catch (e) {
    print('Safe todo check error: $e');
  }
}

Future<void> _safeCheckMealPlanner(PrefUtils prefs) async {
  try {
    // ✅ Multiple Firebase checks
    if (Firebase.apps.isEmpty) {
      print('Firebase apps empty for meal check');
      return;
    }
    
    // ✅ Check if Firebase is actually ready
    try {
      await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
    } catch (e) {
      print('Firebase Auth not ready for meal check: $e');
      return;
    }
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user for meal check');
      return;
    }
    
    await _checkMealPlanner(prefs);
  } catch (e) {
    print('Safe meal check error: $e');
  }
}

Future<void> _safeCheckExerciseGoals(PrefUtils prefs) async {
  try {
    // ✅ Use correct method names
    final exerciseGoalTime = await prefs.getExerciseGoalTime();
    final exerciseGoalEnabled = await prefs.getExerciseGoalEnabled();
    
    if (exerciseGoalTime != null && exerciseGoalEnabled == true) {
      final goalTime = DateTime.parse(exerciseGoalTime);
      final now = DateTime.now();
      
      // Check if it's time for exercise reminder
      if (now.isAfter(goalTime) && now.isBefore(goalTime.add(Duration(minutes: 1)))) {
        await _showNotification(
          id: 100,
          title: 'Exercise Time! 💪',
          body: 'Time to work out and reach your fitness goals!',
          channelId: 'exercise_channel',
          channelName: 'Exercise Reminders',
          isAlarm: false,
        );
        
        // ✅ Mark as notified to prevent repeated notifications
        await prefs.setExerciseGoalEnabled(false);
      }
    }
  } catch (e) {
    print('Error checking exercise goals: $e');
  }
}

Future<void> _safeCheckSleepGoals(PrefUtils prefs) async {
  try {
    await _checkSleepGoals(prefs);
  } catch (e) {
    print('Safe sleep check error: $e');
  }
}

Future<void> _safeCheckWaterIntake(PrefUtils prefs) async {
  try {
    await _checkWaterIntake(prefs);
  } catch (e) {
    print('Safe water check error: $e');
  }
}

// Check Exercise Goals
Future<void> _checkExerciseGoals(PrefUtils prefs) async {
  try {
    // ✅ Use correct method names
    final exerciseGoalTime = await prefs.getExerciseGoalTime();
    final exerciseGoalEnabled = await prefs.getExerciseGoalEnabled();
    
    if (exerciseGoalTime != null && exerciseGoalEnabled == true) {
      final goalTime = DateTime.parse(exerciseGoalTime);
      final now = DateTime.now();
      
      // Check if it's time for exercise reminder
      if (now.isAfter(goalTime) && now.isBefore(goalTime.add(Duration(minutes: 1)))) {
        await _showNotification(
          id: 100,
          title: 'Exercise Time! 💪',
          body: 'Time to work out and reach your fitness goals!',
          channelId: 'exercise_channel',
          channelName: 'Exercise Reminders',
          isAlarm: false,
        );
        
        // ✅ Mark as notified
        await prefs.setExerciseGoalEnabled(false);
      }
    }
  } catch (e) {
    print('Error checking exercise goals: $e');
  }
}

// Check Sleep Goals with Alarm Functionality
Future<void> _checkSleepGoals(PrefUtils prefs) async {
  try {
    final sleepAlarmTime = await prefs.getSleepAlarmTime();
    final sleepGoalName = await prefs.getSleepGoalName();
    final isAlarmSet = await prefs.getSleepAlarmEnabled();
    
    if (isAlarmSet == true && sleepAlarmTime != null && sleepAlarmTime.isNotEmpty) {
      final now = DateTime.now();
      final alarmTime = DateTime.parse(sleepAlarmTime);
      
      // Check if alarm time has arrived (within 1 minute window)
      if (now.isAfter(alarmTime) && now.isBefore(alarmTime.add(Duration(minutes: 1)))) {
        await _showAlarmNotification(
          id: 200,
          title: 'Wake Up! ⏰',
          body: sleepGoalName != null && sleepGoalName.isNotEmpty 
              ? 'Time to wake up! $sleepGoalName'
              : 'Your sleep goal is complete. Rise and shine!',
        );
        
        // Disable alarm after triggering
        await prefs.setSleepAlarmEnabled(false);
      }
    }
  } catch (e) {
    print('Error checking sleep goals: $e');
  }
}

// Check Todo Items
Future<void> _checkTodoItems(PrefUtils prefs) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final now = DateTime.now();
    
    // Get todo items from Firestore
    final todoSnapshot = await FirebaseFirestore.instance
        .collection('todo-goals')
        .doc(user.uid)
        .get();
    
    if (todoSnapshot.exists) {
      final data = todoSnapshot.data() as Map<String, dynamic>;
      final tasks = data['tasks'] as List<dynamic>? ?? [];
      
      for (var task in tasks) {
        final taskData = task as Map<String, dynamic>;
        final reminderDate = taskData['reminder-date'] != null
            ? (taskData['reminder-date'] as Timestamp).toDate()
            : null;
        final title = taskData['title'] ?? 'Task';
        final completed = taskData['completed'] ?? false;
        final notified = taskData['notified'] ?? false;
        
        if (reminderDate != null && !completed && !notified) {
          // Check if reminder time has arrived
          if (now.isAfter(reminderDate) && now.isBefore(reminderDate.add(Duration(minutes: 1)))) {
            await _showNotification(
              id: 300 + tasks.indexOf(task),
              title: 'Todo Reminder 📋',
              body: 'Time to: $title',
              channelId: 'todo_channel',
              channelName: 'Todo Reminders',
              isAlarm: false,
            );
            
            // Mark as notified
            taskData['notified'] = true;
            await FirebaseFirestore.instance
                .collection('todo-goals')
                .doc(user.uid)
                .update({'tasks': tasks});
          }
        }
      }
    }
  } catch (e) {
    print('Error checking todo items: $e');
  }
}

// Check Water Intake
Future<void> _checkWaterIntake(PrefUtils prefs) async {
  try {
    final waterReminderTime = await prefs.getWaterReminderTime();
    final waterGoal = await prefs.getWaterGoal() ?? 8; // Default 8 glasses
    final waterConsumed = await prefs.getWaterConsumed() ?? 0;
    final waterReminderEnabled = await prefs.getWaterReminderEnabled();
    
    if (waterReminderEnabled == true && waterReminderTime != null && waterReminderTime.isNotEmpty) {
      final now = DateTime.now();
      final reminderTime = DateTime.parse(waterReminderTime);
      
      // Check if reminder time has arrived
      if (now.isAfter(reminderTime) && now.isBefore(reminderTime.add(Duration(minutes: 1)))) {
        final remaining = waterGoal - waterConsumed;
        
        if (remaining > 0) {
          await _showNotification(
            id: 400,
            title: 'Water Reminder 💧',
            body: 'Time to drink water! $remaining glasses remaining for today.',
            channelId: 'water_channel',
            channelName: 'Water Reminders',
            isAlarm: false,
          );
          
          // Set next reminder (every 2 hours)
          final nextReminder = reminderTime.add(Duration(hours: 2));
          await prefs.setWaterReminderTime(nextReminder.toIso8601String());
        } else {
          await _showNotification(
            id: 401,
            title: 'Water Goal Complete! 🎉',
            body: 'Congratulations! You\'ve reached your daily water intake goal.',
            channelId: 'water_channel',
            channelName: 'Water Reminders',
            isAlarm: false,
          );
          
          // Disable water reminders for today
          await prefs.setWaterReminderEnabled(false);
        }
      }
    }
  } catch (e) {
    print('Error checking water intake: $e');
  }
}

// Check Meal Planner
Future<void> _checkMealPlanner(PrefUtils prefs) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    
    // Get meal plans from Firestore
    final mealSnapshot = await FirebaseFirestore.instance
        .collection('meal-planner')
        .doc(user.uid)
        .collection('daily-meals')
        .doc(today)
        .get();
    
    if (mealSnapshot.exists) {
      final data = mealSnapshot.data() as Map<String, dynamic>;
      final meals = data['meals'] as List<dynamic>? ?? [];
      
      for (var meal in meals) {
        final mealData = meal as Map<String, dynamic>;
        final mealTime = mealData['time'] != null
            ? (mealData['time'] as Timestamp).toDate()
            : null;
        final mealName = mealData['name'] ?? 'Meal';
        final notified = mealData['notified'] ?? false;
        
        if (mealTime != null && !notified) {
          // Check if meal time has arrived (15 minutes before)
          final reminderTime = mealTime.subtract(Duration(minutes: 15));
          
          if (now.isAfter(reminderTime) && now.isBefore(reminderTime.add(Duration(minutes: 1)))) {
            await _showNotification(
              id: 500 + meals.indexOf(meal),
              title: 'Meal Reminder 🍽️',
              body: 'Time for $mealName in 15 minutes!',
              channelId: 'meal_channel',
              channelName: 'Meal Reminders',
              isAlarm: false,
            );
            
            // Mark as notified
            mealData['notified'] = true;
            await FirebaseFirestore.instance
                .collection('meal-planner')
                .doc(user.uid)
                .collection('daily-meals')
                .doc(today)
                .update({'meals': meals});
          }
        }
      }
    }
  } catch (e) {
    print('Error checking meal planner: $e');
  }
}

// Show regular notification
Future<void> _showNotification({
  required int id,
  required String title,
  required String body,
  required String channelId,
  required String channelName,
  required bool isAlarm,
}) async {
  try {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Notifications for $channelName',
      importance: isAlarm ? Importance.max : Importance.high,
      priority: isAlarm ? Priority.max : Priority.high,
      enableVibration: true, // ✅ Use system vibration
      playSound: true,
      category: isAlarm ? AndroidNotificationCategory.alarm : AndroidNotificationCategory.reminder,
    );
    
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
    
    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  } catch (e) {
    print('Error showing notification: $e');
  }
}

// ✅ Show alarm notification using system vibration only
Future<void> _showAlarmNotification({
  required int id,
  required String title,
  required String body,
}) async {
  try {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sleep_alarm_channel',
      'Sleep Alarms',
      channelDescription: 'Sleep goal alarm notifications',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true, // ✅ Use system vibration
      playSound: true,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      // ✅ Use system vibration pattern
     // vibrationPattern: [0, 1000, 500, 1000, 500, 1000, 500, 1000],
    );
    
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
    
    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
    
    // ✅ Schedule repeating alarms using system vibration
    for (int i = 1; i <= 10; i++) {
      Timer(Duration(seconds: i * 5), () async {
        try {
          await _notificationsPlugin.show(
            id + i,
            title,
            '$body (${i * 5}s)',
            notificationDetails,
          );
        } catch (e) {
          print('Error showing repeat alarm: $e');
        }
      });
    }
  } catch (e) {
    print('Error showing alarm notification: $e');
  }
}

// ✅ ADD: Safe check with retry mechanism
Future<void> _safeCheckWithRetry(Future<void> Function() checkFunction, String checkType) async {
  int retryCount = 0;
  const maxRetries = 3;
  
  while (retryCount < maxRetries) {
    try {
      // ✅ Double-check Firebase is available before each operation
      if (Firebase.apps.isEmpty) {
        print('⚠️ Firebase not available for $checkType check, skipping...');
        return;
      }
      
      // ✅ Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('⚠️ No authenticated user for $checkType check, skipping...');
        return;
      }
      
      await checkFunction();
      return; // Success, exit retry loop
      
    } catch (e) {
      retryCount++;
      print('⚠️ Error in $checkType check (attempt $retryCount/$maxRetries): $e');
      
      if (retryCount >= maxRetries) {
        print('❌ Max retries reached for $checkType check, skipping...');
        return;
      }
      
      // Wait before retry
      await Future.delayed(Duration(seconds: retryCount * 2));
    }
  }
}

