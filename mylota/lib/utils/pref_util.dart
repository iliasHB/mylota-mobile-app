//ignore: unused_import
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  static SharedPreferences? _sharedPreferences;

  PrefUtils() {
    // Initialize in constructor if not already initialized
    if (_sharedPreferences == null) {
      SharedPreferences.getInstance().then((value) {
        _sharedPreferences = value;
      });
    }
  }

  /// ✅ Static initialization method for background service
  static Future<void> init() async {
    try {
      _sharedPreferences ??= await SharedPreferences.getInstance();
      print('✅ PrefUtils initialized');
    } catch (e) {
      print('❌ PrefUtils initialization failed: $e');
      rethrow;
    }
  }

  /// ✅ Instance initialization method
  Future<void> initialize() async {
    try {
      _sharedPreferences ??= await SharedPreferences.getInstance();
      print('✅ SharedPreference Initialized');
    } catch (e) {
      print('❌ SharedPreference initialization failed: $e');
      rethrow;
    }
  }

  /// ✅ Helper method to ensure SharedPreferences is available
  Future<SharedPreferences> _getPrefs() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    return _sharedPreferences!;
  }

  Future<dynamic> setStringList(key, value) async {
    final SharedPreferences prefs = await _getPrefs();
    var result = prefs.setStringList('$key', value);
    return result;
  }

  Future<dynamic> getStringList(key) async {
    final SharedPreferences prefs = await _getPrefs();
    var result = prefs.getStringList('$key');
    return result;
  }

  Future<dynamic> setOtherStringList(key, value) async {
    final SharedPreferences prefs = await _getPrefs();
    var result = prefs.setStringList('$key', value);
    return result;
  }

  Future<dynamic> getOtherStringList(key) async {
    final SharedPreferences prefs = await _getPrefs();
    var result = prefs.getStringList('$key');
    return result;
  }

  Future<dynamic> deleteUser() async {
    final SharedPreferences prefs = await _getPrefs();
    var result = prefs.clear();
    return result;
  }

  Future<dynamic> deletekey(key) async {
    final SharedPreferences prefs = await _getPrefs();
    var result = prefs.remove(key);
    return result;
  }

  Future<dynamic> setExerciseStr(key, value) async {
    final SharedPreferences prefs = await _getPrefs();
    var result = prefs.setString('$key', value);
    return result;
  }

  Future<dynamic> getExerciseStr(key) async {
    final SharedPreferences prefs = await _getPrefs();
    var result = prefs.getString('$key');
    return result;
  }

  Future<dynamic> setStr(key, value) async {
    final SharedPreferences prefs = await _getPrefs();
    var result = prefs.setString('$key', value);
    return result;
  }

  Future<dynamic> getStr(key) async {
    final SharedPreferences prefs = await _getPrefs();
    var result = prefs.getString('$key');
    return result;
  }

  Future<dynamic> setInt(key, value) async {
    final SharedPreferences prefs = await _getPrefs();
    var result = prefs.setInt('$key', value);
    return result;
  }

  Future<dynamic> getInt(key) async {
    final SharedPreferences prefs = await _getPrefs();
    var result = prefs.getInt('$key');
    return result;
  }

  /// ✅ Clear all data stored in preferences
  Future<void> clearPreferencesData() async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.clear();
  }

  // ✅ SLEEP GOAL METHODS (fixed to use _getPrefs)
  Future<void> setSleepAlarmTime(String alarmTime) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setString('sleep_alarm_time', alarmTime);
  }

  Future<String?> getSleepAlarmTime() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getString('sleep_alarm_time');
  }

  Future<void> setSleepGoalName(String goalName) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setString('sleep_goal_name', goalName);
  }

  Future<String?> getSleepGoalName() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getString('sleep_goal_name');
  }

  Future<void> setSleepAlarmEnabled(bool enabled) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setBool('sleep_alarm_enabled', enabled);
  }

  Future<bool?> getSleepAlarmEnabled() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getBool('sleep_alarm_enabled');
  }

  // ✅ WATER INTAKE METHODS (fixed to use _getPrefs)
  Future<void> setWaterReminderTime(String reminderTime) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setString('water_reminder_time', reminderTime);
  }

  Future<String?> getWaterReminderTime() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getString('water_reminder_time');
  }

  Future<void> setWaterGoal(int goal) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setInt('water_goal', goal);
  }

  Future<int?> getWaterGoal() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getInt('water_goal');
  }

  Future<void> setWaterConsumed(int consumed) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setInt('water_consumed', consumed);
  }

  Future<int?> getWaterConsumed() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getInt('water_consumed');
  }

  Future<void> setWaterReminderEnabled(bool enabled) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setBool('water_reminder_enabled', enabled);
  }

  Future<bool?> getWaterReminderEnabled() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getBool('water_reminder_enabled');
  }

  // ✅ CONVENIENCE METHODS
  Future<void> setSleepAlarm(DateTime alarmTime, String goalName) async {
    await setSleepAlarmTime(alarmTime.toIso8601String());
    await setSleepGoalName(goalName);
    await setSleepAlarmEnabled(true);
  }

  Future<void> disableSleepAlarm() async {
    await setSleepAlarmEnabled(false);
  }

  Future<void> setWaterReminder(int goalGlasses, DateTime firstReminderTime) async {
    await setWaterGoal(goalGlasses);
    await setWaterConsumed(0);
    await setWaterReminderTime(firstReminderTime.toIso8601String());
    await setWaterReminderEnabled(true);
  }

  Future<void> addWaterIntake(int glasses) async {
    int current = await getWaterConsumed() ?? 0;
    await setWaterConsumed(current + glasses);
  }

  Future<void> resetDailyWater() async {
    await setWaterConsumed(0);
    await setWaterReminderEnabled(false);
  }

  // Add to PrefUtils.dart for better persistence
  // Exercise Goals
  Future<void> setExerciseGoal(String exerciseType, DateTime goalTime) async {
    final prefs = await _getPrefs();
    await prefs.setString('exercise_type', exerciseType);
    await prefs.setString('exercise_goal_time', goalTime.toIso8601String());
    await prefs.setBool('exercise_goal_enabled', true);
  }

  /// ✅ GENERAL BOOL METHODS
  Future<bool?> getBool(String key) async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getBool(key);
  }

  Future<bool> setBool(String key, bool value) async {
    final SharedPreferences prefs = await _getPrefs();
    return await prefs.setBool(key, value);
  }

  /// ✅ EXERCISE GOAL METHODS
  Future<void> setExerciseGoalTime(String goalTime) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setString('exercise_goal_time', goalTime);
  }

  Future<String?> getExerciseGoalTime() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getString('exercise_goal_time');
  }

  Future<void> setExerciseGoalEnabled(bool enabled) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setBool('exercise_goal_enabled', enabled);
  }

  Future<bool?> getExerciseGoalEnabled() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getBool('exercise_goal_enabled');
  }

  Future<void> setExerciseGoalType(String exerciseType) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setString('exercise_goal_type', exerciseType);
  }

  Future<String?> getExerciseGoalType() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getString('exercise_goal_type');
  }

  // Todo Goals (cache locally)
  Future<void> cacheTodoGoals(List<Map<String, dynamic>> todos) async {
    final prefs = await _getPrefs();
    final todosJson = jsonEncode(todos);
    await prefs.setString('cached_todos', todosJson);
  }

  Future<List<Map<String, dynamic>>?> getCachedTodos() async {
    final prefs = await _getPrefs();
    final todosJson = prefs.getString('cached_todos');
    if (todosJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(todosJson));
    }
    return null;
  }

  // Meal Plans (cache locally)
  Future<void> cacheMealPlans(Map<String, dynamic> meals) async {
    final prefs = await _getPrefs();
    final mealsJson = jsonEncode(meals);
    await prefs.setString('cached_meals', mealsJson);
  }

  // Mental Stimulation Tasks (cache locally)
  Future<void> cacheMentalTasks(List<Map<String, dynamic>> tasks) async {
    final prefs = await _getPrefs();
    final tasksJson = jsonEncode(tasks);
    await prefs.setString('cached_mental_tasks', tasksJson);
  }

  // Future<dynamic> setStringList(key, value) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var result = prefs.setStringList('$key', value);
  //   return result;
  // }

  // Future<dynamic> getStringList(key) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var result = prefs.getStringList('$key');
  //   return result;
  // }
}

// ✅ REMOVED: The problematic code block that was causing syntax errors
// The initialization should be done in main.dart, not here
