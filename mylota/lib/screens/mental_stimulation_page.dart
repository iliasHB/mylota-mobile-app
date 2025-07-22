import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:intl/intl.dart';
import 'package:mylota/utils/styles.dart';
import 'package:mylota/widgets/box_breathing_audio_widget.dart';
import 'package:mylota/widgets/custom_button.dart';
import 'package:mylota/widgets/pattern_recognition_game.dart';
import 'package:mylota/widgets/puzzle_game.dart';
import 'package:mylota/widgets/cognitive_tasks_page.dart';
import '../widgets/appBar_widget.dart';
import '../widgets/custom_input_decorator.dart';
import 'package:mylota/widgets/mindfulness_activities_widget.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:mylota/utils/permission_util.dart';
import 'package:mylota/core/services/mental_notification_service.dart';
import 'package:mylota/core/services/mental_background_service.dart';
import 'package:mylota/controller/mental_stimulation_schedule_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MentalStimulationPage extends StatefulWidget {
  @override
  _MentalStimulationPageState createState() => _MentalStimulationPageState();
}

class _MentalStimulationPageState extends State<MentalStimulationPage> {
  // Dropdown selections
  String? selectedChallenge;
  String? selectedFocusActivity;

  // User input for learning modules
  final TextEditingController _learningModuleController = TextEditingController();
  List<String> learningModules = [];

  // Progress tracking
  int puzzleScore = 0;
  int cognitiveScore = 0;
  int meditationMinutes = 0;
  int learningProgress = 0;

  int patternRecognitionScore = 0;

  // Well-being reminders
  TimeOfDay? callSomeoneTime;
  DateTime? callSomeoneDate;
  String? callSomeoneContact;
  String? callSomeonePhoneNumber;

  TimeOfDay? checkLoverTime;
  DateTime? checkLoverDate;
  String? checkLoverContact;
  String? checkLoverPhoneNumber;

  TimeOfDay? selfTreatTime;
  DateTime? selfTreatDate;
  String? selfTreatContact;

  String? selfTreatLocation;

  DateTime? learningJourneyDate;
  TimeOfDay? learningJourneyTime;

  DateTime? learningStartDateTime;
  DateTime? learningEndDateTime;

  List<String> dropdownItems = [];

  // Progress variables
  int puzzleProgress = 0;
  int patternRecognitionProgress = 0;
  int cognitiveTasksProgress = 0;
  int focusActivityProgress = 0;

  // Controller for location input
  final TextEditingController _selfTreatLocationController = TextEditingController();

  // Focus activity completion status
  bool focusActivityCompleted = false;

  // Manual number entry controllers
  final TextEditingController _callSomeoneManualController = TextEditingController();
  final TextEditingController _checkLoverManualController = TextEditingController();

  // Loading state
  bool isLoading = false;

  // Timer for learning progress prompt
  Timer? _learningProgressPromptTimer;

  // Learning progress history
  List<Map<String, dynamic>> learningProgressHistory = [];

  // Active learning tasks
  List<Map<String, dynamic>> _activeLearningTasks = [];
  List<Map<String, dynamic>> _activeWellBeingTasks = [];
  Timer? _taskVisibilityTimer;

  // Active well-being reminders
  List<QueryDocumentSnapshot> _activeWellBeingReminders = [];
  List<QueryDocumentSnapshot> _todaysReminders = [];

  // Focus node for learning task
  final FocusNode _learningFocusNode = FocusNode();

  Future<void> _fetchActiveWellBeingReminders() async {
    try {
      // Get current user's UID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user logged in, cannot fetch reminders");
        return;
      }
      
      final now = DateTime.now();
      
      // Query reminders for CURRENT USER ONLY
      final querySnapshot = await FirebaseFirestore.instance
          .collection("well-being-reminders")
          .where("userId", isEqualTo: user.uid) // ✅ Filter by user UID
          .where("date", isGreaterThanOrEqualTo: now.toIso8601String())
          .orderBy("date")
          .get();

      if (mounted) {
        setState(() {
          _activeWellBeingReminders = querySnapshot.docs;
        });
      }
      print("Found ${_activeWellBeingReminders.length} active reminders for user: ${user.uid}");
    } catch (e) {
      print("Error fetching active well-being reminders: $e");
    }
  }

  // Replace complex queries with simpler ones that don't require indexes
  Future<void> _fetchActiveWellBeingTasks() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final now = DateTime.now().toUtc();
      
      // ✅ Simplified query - get all user's reminders first
      final reminderSnapshot = await FirebaseFirestore.instance
          .collection('well-being-reminders')
          .where('userId', isEqualTo: user.uid)
          .get(); // ✅ Removed the complex where clause
    
      List<Map<String, dynamic>> activeTasks = [];
    
      // ✅ Filter in code instead of database
      for (var doc in reminderSnapshot.docs) {
        final data = doc.data();
        final reminderDate = DateTime.parse(data['date']).toUtc();
        
        // Filter active tasks in code
        if (now.isBefore(reminderDate)) {
          activeTasks.add({
            'type': data['type'] ?? 'Well-being',
            'detail': data['detail'] ?? 'Activity',
            'end': reminderDate,
          });
        }
      }
      
      setState(() {
        _activeWellBeingTasks = activeTasks;
      });
      
    } catch (e) {
      print('Error fetching active well-being tasks: $e');
      setState(() {
        _activeWellBeingTasks = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Lagos'));

    // Initialize notification service
    MentalNotificationService.initializeNotification((payload) {
      if (payload == 'learning_end') {
        _promptLearningProgress(_learningModuleController.text);
      }
    });

    // Set initial task text to match the screenshot
    _learningModuleController.text = "Learn a new language";

    // Set up focus listener to clear text when focused
    _learningFocusNode.addListener(() {
      if (_learningFocusNode.hasFocus && _learningModuleController.text == "Learn a new language") {
        _learningModuleController.clear();
      }
    });

    // Set up periodic timer
    _learningProgressPromptTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      if (learningStartDateTime != null && learningEndDateTime != null) {
        _promptLearningProgress(_learningModuleController.text);
      }
    });

    _fetchGameProgress();
    _fetchActiveLearningTasks();
    _fetchActiveWellBeingReminders();
    _fetchActiveWellBeingTasks();
    _taskVisibilityTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkTaskVisibility();
    });
  }

  @override
  void dispose() {
    _learningModuleController.dispose();
    _selfTreatLocationController.dispose();
    _callSomeoneManualController.dispose();
    _checkLoverManualController.dispose();
    _learningFocusNode.dispose();
    _taskVisibilityTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, String title, Function(DateTime) onDateSelected) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }

  Future<void> _pickTime(BuildContext context, String title, Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      onTimeSelected(pickedTime);
    }
  }

  Future<void> _pickDateTime(BuildContext context, String title, Function(DateTime) onDateTimeSelected) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onDateTimeSelected(combinedDateTime);
      }
    }
  }

  Future<void> _saveGameScore(String gameType, int score) async {
    try {
      await FirebaseFirestore.instance
          .collection("game-scores")
          .add({
        "gameType": gameType,
        "score": score,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$gameType score saved: $score")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save $gameType score: $e")),
      );
    }
  }

  Future<void> _saveFocusActivity(String activity) async {
    try {
      await FirebaseFirestore.instance
          .collection("focus-activities")
          .add({
        "activity": activity,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Focus activity saved: $activity")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save focus activity: $e")),
      );
    }
  }

  Future<void> _saveLearningJourney(String task, DateTime start, DateTime end) async {
    try {
      // Get current user's UID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in to save tasks")),
        );
        return;
      }

      // Display SnackBar immediately
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saving learning task: $task...")),
      );

      // Save with user ID
      await FirebaseFirestore.instance
          .collection("learning-journeys")
          .add({
        "task": task,
        "start_time": start.toUtc().toIso8601String(),
        "end_time": end.toUtc().toIso8601String(),
        "userId": user.uid, // ✅ Add user ID
        "timestamp": FieldValue.serverTimestamp(),
      });

      // Update SnackBar content after successful save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Learning task saved: $task")),
      );

      _learningModuleController.clear();
      setState(() {
        learningStartDateTime = null;
        learningEndDateTime = null;
      });

      // Fetch active learning tasks after saving
      await _fetchActiveLearningTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save learning task: $e")),
      );
    }
  }

  Future<void> _saveWellBeingReminder(String title, DateTime? date, String? detail) async {
    try {
      // Get current user's UID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in to save reminders")),
        );
        return;
      }

      // Display SnackBar immediately
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saving $title reminder...")),
      );

      if (date == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please set date and time for the reminder.")),
        );
        return;
      }
      
      // Save with user ID
      await FirebaseFirestore.instance
          .collection("well-being-reminders")
          .add({
        "title": title,
        "date": date.toUtc().toIso8601String(),
        "detail": detail,
        "userId": user.uid, // ✅ Add user ID
        "timestamp": FieldValue.serverTimestamp(),
      });

      // Update SnackBar content after successful save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$title reminder saved")),
      );

      // Fetch active reminders after saving
      await _fetchActiveWellBeingReminders();
      await _fetchActiveWellBeingTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save $title reminder: $e")),
    );
    }
  }

  Future<void> _saveGameProgress(String gameType, int score, int maxScore) async {
    try {
      final progress = (maxScore > 0) ? ((score / maxScore) * 100).clamp(0, 100).toInt() : 0;
      await FirebaseFirestore.instance
          .collection("game-progress")
          .doc(gameType)
          .set({
        "score": score,
        "progress": progress,
        "timestamp": FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$gameType progress saved: $progress%")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save $gameType progress: $e")),
      );
    }
  }

  Future<void> _updateGameProgress(String gameType, int currentStep, int totalSteps) async {
    final progress = ((currentStep / totalSteps) * 100).clamp(0, 100).toInt();
    await FirebaseFirestore.instance
        .collection("game-progress")
        .doc(gameType)
        .set({
      "score": currentStep,
      "progress": progress,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Future<void> _fetchGameProgress() async {
    final docRef = FirebaseFirestore.instance
        .collection("game-progress");

    final puzzle = await docRef.doc("Puzzle").get();
    final pattern = await docRef.doc("Pattern Recognition").get();
    final cognitive = await docRef.doc("Cognitive Tasks").get();

    setState(() {
      puzzleProgress = puzzle.data()?['progress'] ?? 0;
      patternRecognitionProgress = pattern.data()?['progress'] ?? 0;
      cognitiveTasksProgress = cognitive.data()?['progress'] ?? 0;
    });
  }

  Future<void> _fetchFocusActivityProgress() async {
    final query = await FirebaseFirestore.instance
        .collection("focus-activities-progress")
        .where("completed", isEqualTo: true)
        .get();

    setState(() {
      focusActivityProgress = query.docs.length * 20;
      if (focusActivityProgress > 100) focusActivityProgress = 100;
    });
  }

  void _promptLearningProgress(String task) async {
    double? percent = await showDialog<double>(
      context: context,
      builder: (context) {
        double tempPercent = 0;
        return AlertDialog(
          title: Text("Did you learn $task?"),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter percentage (0-100)"),
            onChanged: (value) {
              tempPercent = double.tryParse(value) ?? 0;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(tempPercent),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
    if (percent != null && percent >= 0 && percent <= 100) {
      setState(() {
        learningProgressHistory.add({
          'task': task,
          'percent': percent.toInt(),
          'timestamp': DateTime.now(),
        });
        learningProgress = percent.toInt();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Learning progress updated: $percent%")),
      );
    }
  }

  void _onPatternLevelCompleted(int currentLevel, int totalLevels) async {
    await FirebaseFirestore.instance
        .collection("game-progress")
        .doc("Pattern Recognition")
        .set({
      "score": currentLevel,
      "progress": ((currentLevel / totalLevels) * 100).clamp(0, 100).toInt(),
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  void _onGameLevelCompleted(String gameType, int currentLevel, int totalLevels) async {
    await FirebaseFirestore.instance
        .collection("game-progress")
        .doc(gameType)
        .set({
      "score": currentLevel,
      "progress": ((currentLevel / totalLevels) * 100).clamp(0, 100).toInt(),
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Future<void> _fetchActiveLearningTasks() async {
    print("Fetching active learning tasks...");
    setState(() => isLoading = true);
    
    try {
      // Get current user's UID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user logged in, cannot fetch tasks");
        setState(() => isLoading = false);
        return;
      }
      
      final now = DateTime.now().toUtc();
      
      // Query tasks for CURRENT USER ONLY
      final querySnapshot = await FirebaseFirestore.instance
          .collection("learning-journeys")
          .where("userId", isEqualTo: user.uid) // ✅ Filter by user UID
          .where("end_time", isGreaterThanOrEqualTo: now.toIso8601String())
          .get();

      final activeTasks = <Map<String, dynamic>>[];
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final DateTime start = DateTime.parse(data['start_time']).toUtc();
        final DateTime end = DateTime.parse(data['end_time']).toUtc();
        
        if (now.isAfter(start) && now.isBefore(end)) {
          print("User task is active. Name: ${data['task']}, End: $end");
          activeTasks.add({
            'name': data['task']?.toString() ?? 'Learning Task',
            'end': end,
            'userId': data['userId'], // Store user ID for verification
          });
        }
      }

      if (mounted) {
        setState(() {
          _activeLearningTasks = activeTasks;
        });
      }
      print("Found ${_activeLearningTasks.length} active tasks for user: ${user.uid}");
    } catch (e) {
      print("Error fetching active learning tasks: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _checkTaskVisibility() {
    final now = DateTime.now().toUtc(); // Use UTC for consistency
    
    // Update learning tasks
    final updatedLearningTasks = _activeLearningTasks.where((task) {
      return now.isBefore(task['end']);
    }).toList();

    // Update well-being tasks
    final updatedWellBeingTasks = _activeWellBeingTasks.where((task) {
      return now.isBefore(task['end']);
    }).toList();

    if (updatedLearningTasks.length != _activeLearningTasks.length ||
        updatedWellBeingTasks.length != _activeWellBeingTasks.length) {
      if (mounted) {
        setState(() {
          _activeLearningTasks = updatedLearningTasks;
          _activeWellBeingTasks = updatedWellBeingTasks;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: appBar(context: context, title: "Mental Stimulation"),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Boost your brainpower with fun and engaging challenges designed to enhance focus, memory, and problem-solving skills',
                  style: AppStyle.cardfooter,
                  softWrap: true,
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),
                
                // ✅ SEPARATE ACTIVE TASKS CARD
                _buildActiveTasksCard(),
                
                const SizedBox(height: 16),
                
                // ✅ CLEAN LEARNING JOURNEY CARD (without active tasks)
                _buildSection(
                  title: 'Learning Journey',
                  subtitle: 'Engage in new learning.',
                  icon: const Icon(Icons.lightbulb),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _learningModuleController,
                        focusNode: _learningFocusNode,
                        decoration: customInputDecoration(
                          labelText: 'Enter a learning task',
                          hintText: 'e.g Learn a new language',
                          prefixIcon: const Icon(Icons.book, color: Colors.green),
                        ),
                        onTap: () {
                          if (_learningModuleController.text == "Learn a new language") {
                            _learningModuleController.clear();
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            learningStartDateTime != null
                                ? "Start: ${learningStartDateTime!.day}/${learningStartDateTime!.month}/${learningStartDateTime!.year} ${TimeOfDay.fromDateTime(learningStartDateTime!).format(context)}"
                                : "Start: Not set",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          IconButton(
                            icon: const Icon(Icons.play_circle_fill, color: Color(0xFF66C3A7)),
                            onPressed: () => _pickDateTime(context, "Start Date & Time", (dateTime) {
                              setState(() {
                                learningStartDateTime = dateTime;
                              });
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            learningEndDateTime != null
                                ? "End: ${learningEndDateTime!.day}/${learningEndDateTime!.month}/${learningEndDateTime!.year} ${TimeOfDay.fromDateTime(learningEndDateTime!).format(context)}"
                                : "End: Not set",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          IconButton(
                            icon: const Icon(Icons.flag, color: Color(0xFF66C3A7)),
                            onPressed: () => _pickDateTime(context, "End Date & Time", (dateTime) {
                              setState(() {
                                learningEndDateTime = dateTime;
                              });
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CustomPrimaryButton(
                        label: "Save Learning Task",
                        onPressed: () async {
                          if (_learningModuleController.text.isNotEmpty &&
                              learningStartDateTime != null &&
                              learningEndDateTime != null) {
                            
                            // Validate end time is after start time
                            if (learningEndDateTime!.isBefore(learningStartDateTime!)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("End time must be after start time")),
                              );
                              return;
                            }
                            
                            setState(() => isLoading = true);
                            try {
                              final String task = _learningModuleController.text;
                              final DateTime start = learningStartDateTime!;
                              final DateTime end = learningEndDateTime!;
                              
                              await _saveLearningJourney(task, start, end);
                              
                              // Generate unique notification IDs using timestamp
                              final int startNotificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                              final int endNotificationId = startNotificationId + 1;
                              
                              // Schedule notifications with unique IDs
                              await MentalNotificationService.scheduleLearningJourneyNotification(
                                id: startNotificationId,
                                title: "Learning Task Start",
                                body: "Start: $task",
                                scheduledDate: start,
                              );
                              
                              await MentalNotificationService.scheduleLearningJourneyNotification(
                                id: endNotificationId,
                                title: "Learning Task End",
                                body: "End: $task",
                                scheduledDate: end,
                                payload: 'learning_end',
                              );

                              // Add to active tasks immediately
                              setState(() {
                                _activeLearningTasks.add({
                                  'name': task,
                                  'end': end,
                                  'userId': FirebaseAuth.instance.currentUser?.uid,
                                });
                              });

                              print("✅ Notifications scheduled with IDs: $startNotificationId, $endNotificationId");
                              
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error saving task: $e")),
                              );
                            } finally {
                              setState(() => isLoading = false);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please enter a task and set start/end date/time.")),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Continue with the rest of your existing cards...
                _buildSection(
                  title: 'Challenge Your Thinking',
                  subtitle: 'Select an activity to challenge your brain:',
                  icon: const Icon(Icons.psychology),
                  child: DropdownButtonFormField<String>(
                    value: selectedChallenge,
                    items: [
                      DropdownMenuItem(
                        value: 'Puzzle',
                        child: Text(
                          'Puzzle',
                          style: AppStyle.cardfooter.copyWith(fontSize: 12),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Pattern Recognition',
                        child: Text(
                          'Pattern Recognition',
                          style: AppStyle.cardfooter.copyWith(fontSize: 12),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Cognitive Tasks',
                        child: Text(
                          'Cognitive Tasks',
                          style: AppStyle.cardfooter.copyWith(fontSize: 12),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedChallenge = value;
                      });

                      // Navigate to specific game screens based on the selected challenge
                      if (value == 'Puzzle') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PuzzleGame(
                              onLevelCompleted: (currentLevel, totalLevels) {
                                _updateGameProgress("Puzzle", currentLevel, totalLevels);
                              },
                            ),
                          ),
                        );
                      } 
                      else if (value == 'Pattern Recognition') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatternRecognitionGame(
                              onLevelCompleted: (currentLevel, totalLevels) {
                                _updateGameProgress("Pattern Recognition", currentLevel, totalLevels);
                              },
                            ),
                          ),
                        );
                      }
                      else if (value == 'Cognitive Tasks') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CognitiveTasksPage(
                              onLevelCompleted: (currentLevel, totalLevels) {
                                _updateGameProgress("Cognitive Tasks", currentLevel, totalLevels);
                              },
                            ),
                          ),
                        );
                      }
                    },
                    decoration: customInputDecoration(
                      labelText: 'Choose a challenge',
                      hintText: 'Choose a game',
                      prefixIcon: const Icon(Icons.videogame_asset, color: Colors.green),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                _buildSection(
                  title: 'Stay Focused',
                  subtitle: 'Select an activity to improve focus:',
                  icon: const Icon(Icons.self_improvement), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedFocusActivity,
                        items: const [
                          DropdownMenuItem(
                            value: 'Box Breathing',
                            child: Text('Box Breathing'),
                          ),
                          DropdownMenuItem(
                            value: '5-4-3-2-1 Grounding Exercise',
                            child: Text('5-4-3-2-1 Grounding Exercise'),
                          ),
                          DropdownMenuItem(
                            value: 'Single-Task Focus',
                            child: Text('Single-Task Focus'),
                          ),
                          DropdownMenuItem(
                            value: 'Mindful Walking',
                            child: Text('Mindful Walking'),
                          ),
                          DropdownMenuItem(
                            value: 'Mindful Listening',
                            child: Text('Mindful Listening'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedFocusActivity = value;
                            focusActivityCompleted = false;
                          });
                        },
                        decoration: customInputDecoration(
                          labelText: 'Choose activity',
                          hintText: 'e.g Mindful listening',
                          prefixIcon: Icon(Icons.do_not_disturb, color: Colors.green),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (selectedFocusActivity != null)
                        selectedFocusActivity == 'Box Breathing'
                            ? BoxBreathingAudioWidget()
                            : MindfulnessActivitiesWidget(activity: selectedFocusActivity!),
                      const SizedBox(height: 10),
                      if (selectedFocusActivity != null && !focusActivityCompleted)
                        CustomPrimaryButton(
                          onPressed: () async {
                            // Save completion to Firestore
                            await FirebaseFirestore.instance
                                .collection("focus-activities-progress")
                                .add({
                              "activity": selectedFocusActivity,
                              "completed": true,
                              "timestamp": FieldValue.serverTimestamp(),
                            });

                            setState(() {
                              focusActivityCompleted = true;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Activity marked as done!")),
                            );

                            // Optionally, update progress bar or fetch progress again
                            _fetchFocusActivityProgress();

                            // Reset the activity after marking as done
                            Future.delayed(const Duration(milliseconds: 500), () {
                              setState(() {
                                selectedFocusActivity = null;
                                focusActivityCompleted = false;
                              });
                            });
                          },
                         label: "Done",
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                _buildSection(
                  title: 'Track Your Progress',
                  subtitle: 'See how your skills improve over time:',
                   icon: const Icon(Icons.analytics), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Learning Progress:'),
                      LinearProgressIndicator(
                        value: learningProgress / 100,
                        color: Colors.blue,
                        backgroundColor: Colors.blue.shade100,
                      ),
                      const SizedBox(height: 10),
                      if (learningProgressHistory.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Progress History:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ...learningProgressHistory.map((entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                "${entry['timestamp'].toString().substring(0, 16)}: ${entry['percent']}%",
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            )),
                          ],
                        ),
                      const SizedBox(height: 10),
                      const Text('Puzzle Progress:'),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("game-progress")
                            .doc("Puzzle")
                            .snapshots(),
                        builder: (context, snapshot) {
                          final data = snapshot.data?.data() as Map<String, dynamic>?;
                          final progress = (data?['progress'] ?? 0) as int;
                          return LinearProgressIndicator(
                            value: progress / 100,
                            color: Colors.orange,
                            backgroundColor: Colors.orange.shade100,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text('Pattern Recognition Progress:'),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("game-progress")
                            .doc("Pattern Recognition")
                            .snapshots(),
                        builder: (context, snapshot) {
                          final data = snapshot.data?.data() as Map<String, dynamic>?;
                          final progress = (data?['progress'] ?? 0) as int;
                          return LinearProgressIndicator(
                            value: progress / 100,
                            color: Colors.purple,
                            backgroundColor: Colors.purple.shade100,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text('Cognitive Tasks Progress:'),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("game-progress")
                            .doc("Cognitive Tasks")
                            .snapshots(),
                        builder: (context, snapshot) {
                          final data = snapshot.data?.data() as Map<String, dynamic>?;
                          final progress = (data?['progress'] ?? 0) as int;
                          return LinearProgressIndicator(
                            value: progress / 100,
                            color: Colors.green,
                            backgroundColor: Colors.green.shade100,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text('Focus Activity Progress:'),
                      LinearProgressIndicator(
                        value: focusActivityProgress / 100,
                        color: Colors.teal,
                        backgroundColor: Colors.teal.shade100,
                      ),
                      const SizedBox(height: 10),
                      
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildSection(
                  title: 'Well being Reminders',
                  subtitle: 'Take care of yourself with these friendly reminders:',
                  icon: const Icon(Icons.favorite),
                  child: Column(
                    children: [
                      _buildReminderTileWithDateAndContact(
                        title: "Call Someone (Family/Friend)",
                        date: callSomeoneDate,
                        contact: callSomeoneContact,
                        phoneNumber: callSomeonePhoneNumber,
                        onDateTimePressed: () => _pickDateTime(context, "Call Someone", (dateTime) {
                          setState(() {
                            callSomeoneDate = dateTime;
                            callSomeoneTime = TimeOfDay.fromDateTime(dateTime);
                          });
                        }),
                        onContactPressed: () async {
                          final FlutterNativeContactPicker contactPicker = FlutterNativeContactPicker();
                          try {
                            final Contact? contact = await contactPicker.selectContact();
                            if (contact != null) {
                              if (contact.phoneNumbers != null && contact.phoneNumbers!.length > 1) {
                                // If multiple numbers, let user pick one
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return ListView(
                                      shrinkWrap: true,
                                      children: contact.phoneNumbers!
                                          .map((number) => ListTile(
                                                title: Text(number),
                                                onTap: () {
                                                  setState(() {
                                                    callSomeoneContact = contact.fullName ?? "Unknown Contact";
                                                    callSomeonePhoneNumber = number;
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ))
                                          .toList(),
                                    );
                                  },
                                );
                              } else {
                                // Only one or no number
                                setState(() {
                                  callSomeoneContact = contact.fullName ?? "Unknown Contact";
                                  callSomeonePhoneNumber = contact.phoneNumbers?.isNotEmpty == true
                                      ? contact.phoneNumbers!.first
                                      : "";
                                });
                              }
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to pick contact: $e")),
                            );
                          }
                        },
                        onSavePressed: () {
                          // If user entered a manual number, use it as the contact
                          final bool hasManualNumber = callSomeonePhoneNumber != null && callSomeonePhoneNumber!.isNotEmpty;
                          final bool hasPickedContact = callSomeoneContact != null && callSomeoneContact!.isNotEmpty;

                          if (callSomeoneDate != null && (hasManualNumber || hasPickedContact)) {
                            final String contactName = hasPickedContact
                                ? callSomeoneContact!
                                : "Manual Entry";
                            final String contactDetail = hasManualNumber
                                ? callSomeonePhoneNumber!
                                : (callSomeoneContact ?? "");

                            _saveWellBeingReminder(
                              "Call Someone (Family/Friend)",
                              callSomeoneDate,
                              contactDetail,
                            );
                            
                            // Generate unique notification ID
                            final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                            
                            MentalNotificationService.scheduleWellBeingReminder(
                              id: notificationId, // ✅ Use unique ID
                              title: "Call reminder",
                              body: "Time to call ${callSomeoneContact ?? callSomeonePhoneNumber ?? "your contact"}",
                              scheduledDate: callSomeoneDate!,
                            );
                            
                            print("✅ Well-being notification scheduled with ID: $notificationId");
                            
                            // Clear inputs after saving
                            setState(() {
                              callSomeoneDate = null;
                              callSomeoneTime = null;
                              callSomeoneContact = null;
                              callSomeonePhoneNumber = null;
                              _callSomeoneManualController.clear();
                            });

                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please set both date/time and contact or enter a number before saving."),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                      _buildReminderTileWithDateAndContact(
                        title: "Call on Spouse / Partner",
                        date: checkLoverDate,
                        contact: checkLoverContact,
                        phoneNumber: checkLoverPhoneNumber,
                        onDateTimePressed: () => _pickDateTime(context, "Check on Spouse / Partner", (dateTime) {
                          setState(() {
                            checkLoverDate = dateTime;
                            checkLoverTime = TimeOfDay.fromDateTime(dateTime);
                          });
                        }),
                        onContactPressed: () async {
                          final FlutterNativeContactPicker contactPicker = FlutterNativeContactPicker();
                          try {
                            final Contact? contact = await contactPicker.selectContact();
                            if (contact != null) {
                              if (contact.phoneNumbers != null && contact.phoneNumbers!.length > 1) {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return ListView(
                                      shrinkWrap: true,
                                      children: contact.phoneNumbers!
                                          .map((number) => ListTile(
                                                title: Text(number),
                                                onTap: () {
                                                  setState(() {
                                                    checkLoverContact = contact.fullName ?? "Unknown Contact";
                                                    checkLoverPhoneNumber = number;
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ))
                                          .toList(),
                                    );
                                  },
                                );
                              } else {
                                setState(() {
                                  checkLoverContact = contact.fullName ?? "Unknown Contact";
                                  checkLoverPhoneNumber = contact.phoneNumbers?.isNotEmpty == true
                                      ? contact.phoneNumbers!.first
                                      : "";
                                });
                              }
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to pick contact: $e")),
                            );
                          }
                        },
                        onSavePressed: () {
                          if (checkLoverDate != null && checkLoverContact != null) {
                            _saveWellBeingReminder(
                              "Check on Spouse / Partner",
                              checkLoverDate,
                              checkLoverContact,
                            );
                            MentalNotificationService.scheduleWellBeingReminder(
                              id: 2,
                              title: "Check on Spouse/Partner",
                              body: "Time to check on $checkLoverContact",
                              scheduledDate: checkLoverDate!,
                            );
                            // Clear inputs after saving
                            setState(() {
                              checkLoverDate = null;
                              checkLoverTime = null;
                              checkLoverContact = null;
                              checkLoverPhoneNumber = null;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please set both date/time and contact before saving.")),
                            );
                          }
                        },
                      ),
                      _buildReminderTileWithDateAndLocation(
                        title: "Give Yourself a Treat",
                        date: selfTreatDate,
                        location: selfTreatLocation,
                        onDateTimePressed: () => _pickDateTime(context, "Give Yourself a Treat", (dateTime) {
                          setState(() {
                            selfTreatDate = dateTime;
                            selfTreatTime = TimeOfDay.fromDateTime(dateTime);
                          });
                        }),
                        onLocationChanged: (location) {
                          setState(() {
                            selfTreatLocation = location;
                          });
                        },
                        onSavePressed: () {
                          if (selfTreatDate != null && selfTreatLocation != null && selfTreatLocation!.isNotEmpty) {
                            _saveWellBeingReminder(
                              "Give Yourself a Treat",
                              selfTreatDate,
                              selfTreatLocation,
                            );
                            MentalNotificationService.scheduleWellBeingReminder(
                              id: 3,
                              title: "Treat Yourself",
                              body: "Go to $selfTreatLocation",
                              scheduledDate: selfTreatDate!,
                            );
                            // Clear inputs after saving
                            setState(() {
                              selfTreatDate = null;
                              selfTreatTime = null;
                              selfTreatLocation = null;
                              _selfTreatLocationController.clear();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please set both date/time and location before saving."),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for building a section card
  Widget _buildSection({
    required String title,
    required String subtitle,
    Widget? icon,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF66C3A7).withOpacity(0.2),
                    child: icon
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppStyle.cardSubtitle
                      ),
                      Text(
                        subtitle,
                        style: AppStyle.cardfooter.copyWith(fontSize: 12)
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  // Helper widget for active task items
  Widget _buildActiveTaskItem({
    required String name,
    required DateTime end,
    required IconData icon,
  }) {
    final now = DateTime.now().toUtc();
    final isActive = now.isBefore(end);
    
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade50 : Colors.grey.shade200,
          border: Border.all(color: isActive ? Colors.green : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.green : Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isActive 
                      ? 'Active until: ${DateFormat.yMMMd().add_jm().format(end.toLocal())}' 
                      : 'Completed',
                    style: AppStyle.cardfooter.copyWith(
                      color: isActive ? null : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTileWithDateAndContact({
    required String title,
    DateTime? date,
    String? contact,
    String? phoneNumber,
    required VoidCallback onDateTimePressed,
    required VoidCallback onContactPressed,
    VoidCallback? onSavePressed,
  }) {
    final bool showManualEntry = title == "Call Someone (Family/Friend)";
    final TextEditingController manualController =
        title == "Call Someone (Family/Friend)"
            ? _callSomeoneManualController
            : _checkLoverManualController;

    if (contact != null && contact.isNotEmpty && manualController.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        manualController.clear();
      });
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? "Date & Time: ${date.day}/${date.month}/${date.year} ${TimeOfDay.fromDateTime(date).format(context)}"
                      : "Date & Time: Not set",
                  style: const TextStyle(color: Colors.grey),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Color(0xFF66C3A7)),
                  onPressed: onDateTimePressed,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF66C3A7),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      contact ?? "No contact selected",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: contact != null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.contacts, color: Color(0xFF66C3A7)),
                  onPressed: () {
                    onContactPressed();
                    manualController.clear();
                    if (title == "Call Someone (Family/Friend)") {
                      setState(() {
                        callSomeonePhoneNumber = "";
                      });
                    }
                    if (title == "Check on Spouse / Partner") {
                      setState(() {
                        checkLoverPhoneNumber = "";
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Manual phone number input only for "Call Someone (Family/Friend)"
            if (showManualEntry)
              TextField(
                controller: manualController,
                keyboardType: TextInputType.text,
                decoration: customInputDecoration(
                  labelText: 'Enter phone number or name',
                  hintText: 'e.g. 08012345678 or John',
                  prefixIcon: const Icon(Icons.phone, color: Colors.green),
                ),
                onChanged: (value) {
                  setState(() {
                    callSomeonePhoneNumber = value;
                    callSomeoneContact = null;
                  });
                },
              ),
            if (showManualEntry) const SizedBox(height: 10),
            // Call button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () async {
                    String? numberToCall;
                    if (showManualEntry && manualController.text.isNotEmpty) {
                      numberToCall = manualController.text;
                    } else if (contact != null && contact.isNotEmpty && (phoneNumber != null && phoneNumber.isNotEmpty)) {
                      numberToCall = phoneNumber;
                    }
                    if ((numberToCall != null && numberToCall.isNotEmpty) &&
                        !((contact != null && contact.isNotEmpty) && manualController.text.isNotEmpty)) {
                      final cleanedNumber = numberToCall.replaceAll(RegExp(r'\s+'), '');
                      bool? res = await FlutterPhoneDirectCaller.callNumber(cleanedNumber);
                      if (res != true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Could not launch phone call")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter or select a number to call.")),
                      );
                    }
                  },
                  tooltip: 'Call',
                ),
              ],
            ),
            if (onSavePressed != null)
              Align(
                alignment: Alignment.centerRight,
                child: CustomPrimaryButton(
                  label: "Save",
                  onPressed: onSavePressed,
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTileWithDateAndLocation({
    required String title,
    DateTime? date,
    String? location,
    required VoidCallback onDateTimePressed,
    required ValueChanged<String> onLocationChanged,
    VoidCallback? onSavePressed,
  }) {
    if (_selfTreatLocationController.text != (location ?? "")) {
      _selfTreatLocationController.text = location ?? "";
      _selfTreatLocationController.selection = TextSelection.fromPosition(
        TextPosition(offset: _selfTreatLocationController.text.length),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? "Date & Time: ${date.day}/${date.month}/${date.year} ${TimeOfDay.fromDateTime(date).format(context)}"
                      : "Date & Time: Not set",
                  style: const TextStyle(color: Colors.grey),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Color(0xFF66C3A7)),
                  onPressed: onDateTimePressed,
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _selfTreatLocationController,
              decoration: customInputDecoration(
                labelText: 'Location',
                hintText: 'e.g Restaurant, Park',
                prefixIcon: const Icon(Icons.fastfood, color: Colors.green),
              ),
              onChanged: (value) {
                onLocationChanged(value);
              },
            ),
            const SizedBox(height: 10),
            if (onSavePressed != null)
              Align(
                alignment: Alignment.centerRight,
                child: CustomPrimaryButton(
                  label: "Save",
                  onPressed: onSavePressed,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ SEPARATE ACTIVE TASKS CARD
  Widget _buildActiveTasksCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.green.shade100,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.task_alt,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Tasks',
                          style: AppStyle.cardSubtitle.copyWith(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Monitor your ongoing activities',
                          style: AppStyle.cardfooter.copyWith(
                            fontSize: 12,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Task count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_activeLearningTasks.length + _activeWellBeingTasks.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Content
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                )
              else if (_activeLearningTasks.isEmpty && _activeWellBeingTasks.isEmpty)
                _buildEmptyState()
              else
                _buildActiveTasksList(),
            ],
          ),
        ),
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.task_alt_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No Active Tasks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Create a learning task or well-being reminder to get started',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Active tasks list widget
  Widget _buildActiveTasksList() {
    return Column(
      children: [
        // Learning Tasks Section
        if (_activeLearningTasks.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.book, size: 18, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                'Learning Tasks',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._activeLearningTasks.map((task) => _buildEnhancedActiveTaskItem(
            name: task['name'] as String,
            end: task['end'] as DateTime,
            icon: Icons.book,
            type: 'Learning',
          )).toList(),
        ],
        
        // Well-being Tasks Section
        if (_activeWellBeingTasks.isNotEmpty) ...[
          if (_activeLearningTasks.isNotEmpty) const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.favorite, size: 18, color: Colors.pink.shade600),
              const SizedBox(width: 8),
              Text(
                'Well-being Tasks',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.pink.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._activeWellBeingTasks.map((task) => _buildEnhancedActiveTaskItem(
            name: '${task['type']}: ${task['detail']}',
            end: task['end'] as DateTime,
            icon: Icons.favorite,
            type: 'Well-being',
          )).toList(),
        ],
      ],
    );
  }

  // Enhanced active task item
  Widget _buildEnhancedActiveTaskItem({
    required String name,
    required DateTime end,
    required IconData icon,
    required String type,
  }) {
    final now = DateTime.now().toUtc();
    final isActive = now.isBefore(end);
    final timeRemaining = end.difference(now);
    
    String getTimeRemainingText() {
      if (timeRemaining.inDays > 0) {
        return '${timeRemaining.inDays}d ${timeRemaining.inHours % 24}h left';
      } else if (timeRemaining.inHours > 0) {
        return '${timeRemaining.inHours}h ${timeRemaining.inMinutes % 60}m left';
      } else if (timeRemaining.inMinutes > 0) {
        return '${timeRemaining.inMinutes}m left';
      } else {
        return 'Almost done';
      }
    }
    
    Color getTypeColor() {
      switch (type) {
        case 'Learning': return Colors.blue;
        case 'Well-being': return Colors.pink;
        default: return Colors.grey;
      }
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? getTypeColor().withOpacity(0.3) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: getTypeColor().withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon with status indicator
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isActive 
                            ? getTypeColor().withOpacity(0.1) 
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: isActive ? getTypeColor() : Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                    if (isActive)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: getTypeColor(),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Task details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.black87 : Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: getTypeColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 11,
                            color: getTypeColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  isActive ? Icons.schedule : Icons.check_circle,
                  size: 16,
                  color: isActive ? Colors.orange.shade600 : Colors.green.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  isActive ? getTimeRemainingText() : 'Completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.orange.shade600 : Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'Ends ${DateFormat.MMMd().add_jm().format(end.toLocal())}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}