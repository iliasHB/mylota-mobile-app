import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterReminderProvider with ChangeNotifier {
  double _dailyWaterIntake = 0.0;
  String _reminderTime = "08:00";
  bool _acknowledged = false;
  Timer? _reminderTimer;
  
  // Getters
  double get dailyWaterIntake => _dailyWaterIntake;
  String get reminderTime => _reminderTime;
  bool get acknowledged => _acknowledged;
  
  // ✅ Updated method signature to accept all 3 parameters
  void startDailyWaterIntakeTimer(
    String waterIntakeAmount,
    String reminderTime,
    bool acknowledged,
  ) {
    try {
      // Parse and store the values
      _dailyWaterIntake = double.tryParse(waterIntakeAmount) ?? 2.0;
      _reminderTime = reminderTime;
      _acknowledged = acknowledged;
      
      // Parse the reminder time
      TimeOfDay reminderTimeOfDay = _parseTimeString(reminderTime);
      
      // Calculate when the next reminder should be
      final now = DateTime.now();
      DateTime nextReminder = DateTime(
        now.year,
        now.month,
        now.day,
        reminderTimeOfDay.hour,
        reminderTimeOfDay.minute,
      );
      
      // If the time has passed today, schedule for tomorrow
      if (nextReminder.isBefore(now)) {
        nextReminder = nextReminder.add(const Duration(days: 1));
      }
      
      // Only schedule if not already acknowledged
      if (!acknowledged) {
        _scheduleWaterReminder(nextReminder);
      }
      
      // Save to local storage
      _saveToPreferences();
      
      print('✅ Water reminder scheduled for: ${nextReminder.toString()}');
      print('📊 Daily water intake: ${_dailyWaterIntake}L');
      
      notifyListeners();
      
    } catch (e) {
      print('❌ Error setting up water reminder: $e');
      _scheduleDefaultWaterReminder();
    }
  }
  
  // ✅ Helper method to parse time strings
  TimeOfDay _parseTimeString(String timeString) {
    try {
      String cleanTime = timeString.trim().toUpperCase();
      
      // Handle "09 AM" or "09:30 PM" format
      if (cleanTime.contains('AM') || cleanTime.contains('PM')) {
        // Add :00 if no minutes specified
        if (!cleanTime.contains(':')) {
          cleanTime = cleanTime.replaceFirst(' ', ':00 ');
        }
        
        final format = DateFormat('h:mm a');
        final dateTime = format.parse(cleanTime);
        return TimeOfDay.fromDateTime(dateTime);
      }
      
      // Handle "09:30" format (24-hour)
      if (cleanTime.contains(':')) {
        final parts = cleanTime.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
      
      // Handle "09" format (hour only)
      final hour = int.parse(cleanTime);
      return TimeOfDay(hour: hour, minute: 0);
      
    } catch (e) {
      print('❌ Error parsing time "$timeString": $e');
      return const TimeOfDay(hour: 8, minute: 0); // Default to 8 AM
    }
  }
  
  // ✅ Schedule water reminder
  void _scheduleWaterReminder(DateTime reminderTime) {
    // Cancel any existing timer
    _reminderTimer?.cancel();
    
    final now = DateTime.now();
    final duration = reminderTime.difference(now);
    
    if (duration.isNegative) {
      print('⚠️ Reminder time is in the past, scheduling for tomorrow');
      return;
    }
    
    _reminderTimer = Timer(duration, () {
      _triggerWaterReminder();
    });
    
    print('🔔 Water reminder scheduled for: ${reminderTime.toString()}');
  }
  
  // ✅ Trigger water reminder
  void _triggerWaterReminder() {
    if (!_acknowledged) {
      print('💧 Water reminder triggered!');
      // Here you would show notification or trigger reminder
      // You can integrate with your notification service here
    }
  }
  
  // ✅ Fallback method for default reminder
  void _scheduleDefaultWaterReminder() {
    final now = DateTime.now();
    final defaultTime = DateTime(now.year, now.month, now.day, 8, 0); // 8 AM
    
    if (defaultTime.isBefore(now)) {
      _scheduleWaterReminder(defaultTime.add(const Duration(days: 1)));
    } else {
      _scheduleWaterReminder(defaultTime);
    }
  }
  
  // ✅ Save to SharedPreferences
  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('daily_water_intake', _dailyWaterIntake);
      await prefs.setString('reminder_time', _reminderTime);
      await prefs.setBool('water_acknowledged', _acknowledged);
      
      print('💾 Water intake preferences saved');
    } catch (e) {
      print('❌ Error saving water intake preferences: $e');
    }
  }
  
  // ✅ Load from SharedPreferences
  Future<void> loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dailyWaterIntake = prefs.getDouble('daily_water_intake') ?? 2.0;
      _reminderTime = prefs.getString('reminder_time') ?? "08:00";
      _acknowledged = prefs.getBool('water_acknowledged') ?? false;
      
      notifyListeners();
      print('📱 Water intake preferences loaded');
    } catch (e) {
      print('❌ Error loading water intake preferences: $e');
    }
  }
  
  // ✅ Mark as acknowledged
  void markAsAcknowledged() {
    _acknowledged = true;
    _saveToPreferences();
    notifyListeners();
    print('✅ Water intake acknowledged');
  }
  
  // ✅ Reset acknowledgment (for new day)
  void resetAcknowledgment() {
    _acknowledged = false;
    _saveToPreferences();
    notifyListeners();
    print('🔄 Water intake acknowledgment reset');
  }
  
  // ✅ Mark as done for today (for compatibility)
  void markAsDoneForToday() {
    markAsAcknowledged();
  }
  
  // ✅ Dispose method
  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }
}
