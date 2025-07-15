import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mylota/core/usecase/provider/todo_schedule_provider.dart';
import 'package:mylota/firebase_options.dart';
import 'package:mylota/screens/splash_screen.dart';
import 'package:mylota/utils/permission_util.dart';
import 'package:mylota/utils/pref_util.dart';
import 'package:mylota/widgets/exercise_goal.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/background_service.dart';
import 'core/services/notification_service.dart';
import 'core/usecase/provider/exercise_timer_provider.dart';
import 'package:mylota/core/usecase/provider/meal_planner_provider.dart' as meal;
import 'core/usecase/provider/sleep_timer_provider.dart';
import 'core/usecase/provider/water_intake_provider.dart';
import 'widgets/sleep_goal.dart';


Future<void> main() async {
  // Add error handling wrapper
  runApp(const ErrorWrapper());
}

class ErrorWrapper extends StatelessWidget {
  const ErrorWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('❌ Initialization error: ${snapshot.error}');
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Restart app
                        main();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return const MyApp();
        }

        // Show loading screen
        return const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing Mylota Fitness...'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _initializeApp() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      print('✅ Flutter binding initialized');

      // ✅ Initialize PrefUtils FIRST
      try {
        await PrefUtils.init();
        print('✅ PrefUtils initialized');
      } catch (e) {
        print('⚠️ PrefUtils initialization failed: $e');
      }

      // Initialize Stripe with error handling
      try {
        Stripe.publishableKey = 'pk_test_51Rku0K4GO9W81Cm2Caa3OGRHu90v3KUHTd1QeWNhkmHhp2YXAuYhAX1o5Cw014iB0CiiDcob48pfA7TRFcyFpejc00DQOyiL4V';
        await Stripe.instance.applySettings();
        print('✅ Stripe initialized successfully');
      } catch (e) {
        print('⚠️ Stripe initialization failed: $e');
      }

      // Initialize providers
      final waterReminderProvider = WaterReminderProvider();
      final mealReminderProvider = meal.MealPlannerProvider(); // ✅ This should work now
      final todoReminderProvider = ToDoScheduleProvider();
      print('✅ Providers initialized');

      // Initialize NotificationService with error handling
      try {
        NotificationService.initializeNotification((String? payload) {
          if (payload == null) return;

          if (payload.startsWith('mealReminderTap')) {
            final parts = payload.split('|');
            final mealType = parts.length > 1 ? parts[1] : 'breakfast';
            mealReminderProvider.markMealAsDoneForToday(mealType);
          }

          if (payload == 'waterReminderTap') {
            waterReminderProvider.markAsDoneForToday();
          }

          if (payload == 'toDoReminderTap') {
            final parts = payload.split('|');
            final todoType = parts.length > 1 ? parts[1] : '';
            todoReminderProvider.markToDoAsDoneForToday(todoType);
          }
        });
        print('✅ Notification service initialized');
      } catch (e) {
        print('⚠️ Notification service failed: $e');
      }

      // Request permissions
      try {
        await requestPermissions();
        print('✅ Permissions requested');
      } catch (e) {
        print('⚠️ Permission request failed: $e');
      }
// Initialize alarm service
      try {
         await AndroidAlarmManager.initialize();
        print('✅ Alarm service initialized');
      } catch (e) {
        print('⚠️ Alarm service failed: $e');
      }
      // Initialize Firebase FIRST
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('✅ Firebase initialized in main app');
      } catch (e) {
        print('❌ Firebase initialization failed: $e');
        throw Exception('Firebase initialization failed: $e');
      }

      // ✅ Wait for Firebase to be fully ready
      await Future.delayed(const Duration(seconds: 3));

      // Initialize background service AFTER Firebase is ready
      try {
        final service = FlutterBackgroundService();
        bool isRunning = await service.isRunning();
        
        if (!isRunning) {
          print('🔄 Starting background service...');
          await initializeService();
          
          // ✅ Verify service started successfully
          await Future.delayed(const Duration(seconds: 2));
          bool isNowRunning = await service.isRunning();
          
          if (isNowRunning) {
            print('✅ Background service started successfully');
          } else {
            print('⚠️ Background service failed to start properly');
          }
        } else {
          print('✅ Background service already running');
        }
      } catch (e) {
        print('⚠️ Background service failed: $e');
        // Continue without background service
      }

      print('✅ App initialization completed successfully');
    } catch (e) {
      print('❌ App initialization failed: $e');
      rethrow;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExerciseTimerProvider()),
        ChangeNotifierProvider(create: (_) => SleepTimerProvider()),
        ChangeNotifierProvider(create: (_) => WaterReminderProvider()),
        ChangeNotifierProvider(create: (_) => meal.MealPlannerProvider()),
        ChangeNotifierProvider(create: (_) => ToDoScheduleProvider()),
      ],
      child: MaterialApp(
        title: 'MyLota Fitness',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}



