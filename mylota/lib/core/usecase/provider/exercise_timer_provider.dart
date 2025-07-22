import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ExerciseTimerProvider with ChangeNotifier {
  // ✅ CORE STATE - Only what we need
  Duration _duration = const Duration();
  Duration _totalDuration = const Duration();
  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleted = false;
  String _exerciseType = '';
  Duration remainingTime = const Duration();
  String exerciseName = "";
  
  
  






  // ✅ SIMPLE GETTERS - No complex calculations
  Duration get duration => _duration;
  Duration get totalDuration => _totalDuration;
  bool get isRunning => _isRunning;
  bool get isCompleted => _isCompleted;
  String get exerciseType => _exerciseType;

  // ✅ COMPATIBILITY GETTERS - For existing UI code
  bool get hasActiveTimer => _totalDuration.inSeconds > 0;
  double get progress => _totalDuration.inSeconds > 0
      ? (_duration.inSeconds / _totalDuration.inSeconds).clamp(0.0, 1.0)
      : 0.0;

  // ✅ FORMATTED TIME - Simple and reliable
  String get formattedDuration {
    final minutes = _duration.inMinutes;
    final seconds = _duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ✅ CONSTRUCTOR - Load data on init
  ExerciseTimerProvider() {
    _loadData();
  }

  get elapsedMinutes => null;

  get targetDurationMinutes => null;

  get targetMinutes => null;

  get isExercising => null;

  get actualMinutes => null;

  // ✅ SET GOAL - Simple, no side effects
  void setExerciseGoal({
    required Duration targetDuration,
    required String exerciseType,
  }) {
    _totalDuration = targetDuration;
    _exerciseType = exerciseType;
    _duration = const Duration();
    _isRunning = false;
    _isCompleted = false;

    _saveData();
    notifyListeners();
    print('✅ Goal set: $exerciseType (${targetDuration.inMinutes}min)');
  }

  // ✅ START EXERCISE - Fresh start only
  void startExercise({
    required Duration targetDuration,
    required String exerciseType,
  }) {
    // Stop any existing timer
    _timer?.cancel();

    // Set fresh state
    _totalDuration = targetDuration;
    _exerciseType = exerciseType;
    _duration = const Duration();
    _isRunning = true;
    _isCompleted = false;

    // Start counting
    _startTimer();
    _saveData();
    notifyListeners();
    print('🏃‍♂️ Started: $exerciseType (${targetDuration.inMinutes}min)');
  }

  // ✅ PAUSE - Stop timer, keep progress
  void pauseExercise() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    _isRunning = false;
    _saveData();
    notifyListeners();
    print('⏸️ Paused at ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}');
  }

  // ✅ RESUME - Continue from where paused
  void resumeExercise() {
    if (!_isRunning && _totalDuration.inSeconds > 0 && !_isCompleted) {
      _isRunning = true;
      _startTimer();
      _saveData();
      notifyListeners();
      print('▶️ Resumed from ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}');
    }
  }

  // ✅ TIMER CORE - Simple increment every second
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration = Duration(seconds: _duration.inSeconds + 1);

      // Check completion
      if (_duration.inSeconds >= _totalDuration.inSeconds) {
        _completeExercise();
        return;
      }

      // Update UI every second
      notifyListeners();

      // Save every 5 seconds to reduce lag
      if (_duration.inSeconds % 5 == 0) {
        _saveData();
      }
    });
  }

  // ✅ COMPLETE - Exercise finished
  void _completeExercise() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _isCompleted = true;
    _duration = _totalDuration; // Ensure exact match

    _saveData();
    notifyListeners();
    print('🎉 Completed: $_exerciseType');
  }

  // ✅ RESET - Clear everything
  void resetExercise() {
    _timer?.cancel();
    _timer = null;
    _duration = const Duration();
    _isRunning = false;
    _isCompleted = false;

    _saveData();
    notifyListeners();
    print('🔄 Reset');
  }

  // ✅ SAVE - Minimal data only
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('duration_seconds', _duration.inSeconds);
      await prefs.setInt('total_seconds', _totalDuration.inSeconds);
      await prefs.setBool('is_running', _isRunning);
      await prefs.setBool('is_completed', _isCompleted);
      await prefs.setString('exercise_type', _exerciseType);
    } catch (e) {
      print('❌ Save error: $e');
    }
  }

  // ✅ LOAD - Restore state, pause if was running
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _duration = Duration(seconds: prefs.getInt('duration_seconds') ?? 0);
      _totalDuration = Duration(seconds: prefs.getInt('total_seconds') ?? 0);
      _isRunning = false; // Always pause on app restart
      _isCompleted = prefs.getBool('is_completed') ?? false;
      _exerciseType = prefs.getString('exercise_type') ?? '';

      notifyListeners();
      print('📱 Loaded: $_exerciseType - ${_duration.inSeconds}s/${_totalDuration.inSeconds}s');
    } catch (e) {
      print('❌ Load error: $e');
    }
  }

  // ✅ CLEANUP
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ✅ COMPATIBILITY METHODS - For existing code
  void startOrResumeTimer(int minutes, String type) {
    if (_isRunning) return;

    if (_totalDuration.inSeconds > 0 && !_isCompleted) {
      resumeExercise();
    } else {
      startExercise(
        targetDuration: Duration(minutes: minutes),
        exerciseType: type,
      );
    }
  }

  void pauseTimer() => pauseExercise();
  void stopTimer() => pauseExercise();
  void resetTimer() => resetExercise();
}