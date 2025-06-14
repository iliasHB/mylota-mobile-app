import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mylota/core/usecase/provider/todo_schedule_provider.dart';
import 'package:mylota/screens/splash_screen.dart';
import 'package:mylota/utils/permission_util.dart';
import 'package:mylota/utils/pref_util.dart';
import 'package:provider/provider.dart';

import 'core/services/background_service.dart';
import 'core/services/notification_service.dart';
import 'core/usecase/provider/exercise_timer_provider.dart';
import 'core/usecase/provider/meal_planner_provider.dart';
import 'core/usecase/provider/sleep_timer_provider.dart';
import 'core/usecase/provider/water_intake_provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  // await requestPermissions();
  // await NotificationService.initializeNotification();
  final waterReminderProvider = WaterReminderProvider();
  final mealReminderProvider = MealPlannerProvider();
  final todoReminderProvider = ToDoScheduleProvider();

  // Initialize NotificationService with the callback
  NotificationService.initializeNotification((String? payload) {
    if (payload == null) return;

    if (payload.startsWith('mealReminderTap')) {
      final parts = payload.split('|');
      final mealType = parts.length > 1 ? parts[1] : 'breakfast'; // default fallback

      mealReminderProvider.markMealAsDoneForToday(mealType);
    }

    if (payload == 'waterReminderTap') {
      waterReminderProvider.markAsDoneForToday();
    }

    if (payload == 'toDoReminderTap') {
      final parts = payload.split('|');
      final todoType = parts.length > 1 ? parts[1] : ''; // default fallback

      todoReminderProvider.markToDoAsDoneForToday(todoType);
    }
  });

  // await initializeService();
  await requestPermissions();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ExerciseTimerProvider()),
      ChangeNotifierProvider(create: (_) => SleepTimerProvider()),
      ChangeNotifierProvider(create: (_) => WaterReminderProvider()),
      ChangeNotifierProvider(create: (_) => MealPlannerProvider()),
      ChangeNotifierProvider(create: (_) => ToDoScheduleProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mylota Fitness',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}



