import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SleepTimerProvider extends ChangeNotifier {
  double _targetHours = 0.0;
  double _actualHours = 0.0;
  double _progress = 0.0;
  bool _isSleeping = false;
  bool _isCompleted = false;
  bool _isActive = false;
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;
  DateTime? _sleepStartTime;
  Timer? _sleepTimer;
  Timer? _progressTimer;

  var sleepType;

  Duration remaining = const Duration(hours: 0, minutes: 0, seconds: 0);

  // Getters
  double get targetHours => _targetHours;
  double get actualHours => _actualHours;
  double get progress => _progress;
  bool get isSleeping => _isSleeping;
  bool get isCompleted => _isCompleted;
  bool get isActive => _isActive;
  TimeOfDay? get bedTime => _bedTime;
  TimeOfDay? get wakeTime => _wakeTime;
  DateTime? get sleepStartTime => _sleepStartTime;

  SleepTimerProvider() {
    _loadSleepData();
  }

  void startDailySleepTimer(TimeOfDay bedTime, TimeOfDay wakeTime) {
    try {
      final bedTimeMinutes = (bedTime.hour * 60) + bedTime.minute;
      final wakeTimeMinutes = (wakeTime.hour * 60) + wakeTime.minute;
      
      int durationMinutes;
      if (wakeTimeMinutes >= bedTimeMinutes) {
        durationMinutes = wakeTimeMinutes - bedTimeMinutes;
      } else {
        durationMinutes = (24 * 60 - bedTimeMinutes) + wakeTimeMinutes;
      }
      
      final durationHours = durationMinutes / 60.00;
      
      startSleep(
        goalHours: durationHours,
        bedTime: bedTime,
        wakeTime: wakeTime,
      );
      
      print('✅ Daily sleep timer started: ${durationHours.toStringAsFixed(1)} hours');
      
    } catch (e) {
      print('❌ Error starting daily sleep timer: $e');
    }
  }

  void startSleep({
    required double goalHours,
    required TimeOfDay bedTime,
    required TimeOfDay wakeTime,
  }) {
    _targetHours = goalHours;
    _bedTime = bedTime;
    _wakeTime = wakeTime;
    _isActive = true;
    _isCompleted = false;
    _actualHours = 0.0;
    _progress = 0.0;
    
    final now = DateTime.now();
    DateTime sleepStart = DateTime(now.year, now.month, now.day, bedTime.hour, bedTime.minute);
    
    if (sleepStart.isAfter(now)) {
      _sleepStartTime = sleepStart;
      _isSleeping = false;
      _scheduleAutoStart();
    } else {
      _sleepStartTime = now;
      _isSleeping = true;
      _startSleepProgressTracking();
    }
    
    _saveSleepData();
    notifyListeners();
    print('🌙 Sleep session started: ${goalHours}h goal');
  }

  void _scheduleAutoStart() {
    if (_sleepStartTime == null) return;
    
    final duration = _sleepStartTime!.difference(DateTime.now());
    if (duration.isNegative) return;
    
    _sleepTimer?.cancel();
    _sleepTimer = Timer(duration, () {
      if (_isActive && !_isSleeping) {
        _isSleeping = true;
        _startSleepProgressTracking();
        notifyListeners();
      }
    });
  }

  void _startSleepProgressTracking() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!_isSleeping || _isCompleted) {
        timer.cancel();
        return;
      }
      
      _updateSleepProgress();
    });
  }

  void _updateSleepProgress() {
    if (_sleepStartTime == null || !_isSleeping) return;
    
    final elapsed = DateTime.now().difference(_sleepStartTime!);
    _actualHours = elapsed.inMinutes / 60.00;
    _progress = _targetHours > 0 ? (_actualHours / _targetHours).clamp(0.0, 1.0) : 0.0;
    
    if (_progress >= 1.0 && !_isCompleted) {
      _isCompleted = true;
      _isSleeping = false;
      _progressTimer?.cancel();
      print('🌅 Sleep goal completed!');
    }
    
    _saveSleepData();
    notifyListeners();
  }

  Future<void> updateFromSleepGoal(double goalHours, TimeOfDay bedTime, TimeOfDay wakeTime) async {
    startSleep(
      goalHours: goalHours,
      bedTime: bedTime,
      wakeTime: wakeTime,
    );
  }

  Future<void> _saveSleepData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      await FirebaseFirestore.instance
          .collection('sleep-progress')
          .doc(user.uid)
          .collection('daily')
          .doc(today)
          .set({
        'target_hours': _targetHours,
        'actual_hours': _actualHours,
        'progress': _progress,
        'is_sleeping': _isSleeping,
        'is_completed': _isCompleted,
        'is_active': _isActive,
        'bedtime': _bedTime != null ? '${_bedTime!.hour}:${_bedTime!.minute}' : null,
        'wake_time': _wakeTime != null ? '${_wakeTime!.hour}:${_wakeTime!.minute}' : null,
        'sleep_start_time': _sleepStartTime?.toIso8601String(),
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('sleep_target_hours', _targetHours);
      await prefs.setDouble('sleep_actual_hours', _actualHours);
      await prefs.setDouble('sleep_progress', _progress);
      await prefs.setBool('sleep_is_sleeping', _isSleeping);
      await prefs.setBool('sleep_is_completed', _isCompleted);
      await prefs.setBool('sleep_is_active', _isActive);
      if (_bedTime != null) {
        await prefs.setString('sleep_bedtime', '${_bedTime!.hour}:${_bedTime!.minute}');
      }
      if (_wakeTime != null) {
        await prefs.setString('sleep_wake_time', '${_wakeTime!.hour}:${_wakeTime!.minute}');
      }
      if (_sleepStartTime != null) {
        await prefs.setString('sleep_start_time', _sleepStartTime!.toIso8601String());
      }
      
    } catch (e) {
      print('❌ Error saving sleep data: $e');
    }
  }

  Future<void> _loadSleepData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _targetHours = prefs.getDouble('sleep_target_hours') ?? 0.0;
      _actualHours = prefs.getDouble('sleep_actual_hours') ?? 0.0;
      _progress = prefs.getDouble('sleep_progress') ?? 0.0;
      _isSleeping = prefs.getBool('sleep_is_sleeping') ?? false;
      _isCompleted = prefs.getBool('sleep_is_completed') ?? false;
      _isActive = prefs.getBool('sleep_is_active') ?? false;

      final bedTimeString = prefs.getString('sleep_bedtime');
      if (bedTimeString != null) {
        final parts = bedTimeString.split(':');
        _bedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }

      final wakeTimeString = prefs.getString('sleep_wake_time');
      if (wakeTimeString != null) {
        final parts = wakeTimeString.split(':');
        _wakeTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }

      final sleepStartTimeString = prefs.getString('sleep_start_time');
      if (sleepStartTimeString != null) {
        _sleepStartTime = DateTime.parse(sleepStartTimeString);
      }

      if (_isSleeping && !_isCompleted) {
        _startSleepProgressTracking();
      }

      notifyListeners();
      print('✅ Sleep data loaded from preferences');
      
    } catch (e) {
      print('❌ Error loading sleep data: $e');
    }
  }

  void stopSleep() {
    _isSleeping = false;
    _isActive = false;
    _progressTimer?.cancel();
    _sleepTimer?.cancel();
    _saveSleepData();
    notifyListeners();
    print('🛑 Sleep session stopped');
  }

  void resetSleep() {
    _targetHours = 0.0;
    _actualHours = 0.0;
    _progress = 0.0;
    _isSleeping = false;
    _isCompleted = false;
    _isActive = false;
    _bedTime = null;
    _wakeTime = null;
    _sleepStartTime = null;
    _progressTimer?.cancel();
    _sleepTimer?.cancel();
    _saveSleepData();
    notifyListeners();
    print('🔄 Sleep session reset');
  }

  void markAsDoneForToday() {
    if (_isActive) {
      _isCompleted = true;
      _isSleeping = false;
      _progress = 1.0;
      _progressTimer?.cancel();
      _saveSleepData();
      notifyListeners();
      print('✅ Sleep marked as done for today');
    }
  }

  Map<String, dynamic> getSleepProgressData() {
    return {
      'target_hours': _targetHours,
      'actual_hours': _actualHours,
      'progress': _progress,
      'is_sleeping': _isSleeping,
      'is_completed': _isCompleted,
      'is_active': _isActive,
      'bedtime': _bedTime,
      'wake_time': _wakeTime,
      'sleep_start_time': _sleepStartTime,
    };
  }

  void updateSleepTimes(TimeOfDay bedTime, TimeOfDay wakeTime) {
    _bedTime = bedTime;
    _wakeTime = wakeTime;
    notifyListeners();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _sleepTimer?.cancel();
    super.dispose();
  }
}