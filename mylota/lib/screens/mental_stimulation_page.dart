import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:mylota/utils/styles.dart';
import 'package:mylota/widgets/box_breathing_audio_widget.dart';
import 'package:mylota/widgets/custom_button.dart';
import 'package:mylota/widgets/pattern_recognition_game.dart';
import 'package:mylota/widgets/puzzle_game.dart';
import 'package:mylota/widgets/cognitive_tasks_page.dart';
import '../widgets/custom_input_decorator.dart';
import '../widgets/mental_stimulation_widget.dart';
import 'package:mylota/widgets/mindfulness_activities_widget.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

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

  int patternRecognitionScore = 0; // Added variable for pattern recognition score

  // Well-being reminders
  TimeOfDay? callSomeoneTime;
  DateTime? callSomeoneDate;
  String? callSomeoneContact;
  String? callSomeonePhoneNumber; // <-- Add this variable to your state

  TimeOfDay? checkLoverTime;
  DateTime? checkLoverDate;
  String? checkLoverContact;
  String? checkLoverPhoneNumber; // <-- Add this variable to your state

  TimeOfDay? selfTreatTime;
  DateTime? selfTreatDate;
  String? selfTreatContact;

  String? selfTreatLocation;

  DateTime? learningJourneyDate;
  TimeOfDay? learningJourneyTime;

  DateTime? learningStartDateTime;
  DateTime? learningEndDateTime;

  List<String> dropdownItems = [];

  // Add these progress variables
  int puzzleProgress = 0;
  int patternRecognitionProgress = 0;
  int cognitiveTasksProgress = 0;
  int focusActivityProgress = 0;

  // Controller for location input (for "Give Yourself a Treat")
  final TextEditingController _selfTreatLocationController = TextEditingController();

  // Focus activity completion status
  bool focusActivityCompleted = false;

  @override
  void dispose() {
    _learningModuleController.dispose();
    _selfTreatLocationController.dispose();
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
    // Pick the date first
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Pick the time after selecting the date
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Combine the date and time into a DateTime object
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
          .collection("Mental stimulation")
          .doc("hiIyyqWGzb9eR4RgAHAl") // Replace with your document ID
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
          .collection("Mental stimulation")
          .doc("hiIyyqWGzb9eR4RgAHAl") // Replace with your document ID
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
      await FirebaseFirestore.instance
          .collection("Mental stimulation")
          .doc("hiIyyqWGzb9eR4RgAHAl")
          .collection("learning-journey")
          .add({
        "task": task,
        "start": start.toIso8601String(),
        "end": end.toIso8601String(),
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Learning task saved: $task")),
      );

      _learningModuleController.clear();
      setState(() {
        learningStartDateTime = null;
        learningEndDateTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save learning task: $e")),
      );
    }
  }

  Future<void> _saveWellBeingReminder(String title, DateTime? date, String? detail) async {
    try {
      await FirebaseFirestore.instance
          .collection("Mental stimulation")
          .doc("hiIyyqWGzb9eR4RgAHAl") // Replace with your document ID
          .collection("well-being-reminders")
          .add({
        "title": title,
        "date": date?.toIso8601String(),
        "detail": detail,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$title reminder saved")),
      );
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
          .collection("Mental stimulation")
          .doc("hiIyyqWGzb9eR4RgAHAl")
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

  @override
  void initState() {
    super.initState();
    // Prompt every 10 minutes (600 seconds)
    Timer.periodic(const Duration(minutes: 10), (timer) {
      if (learningStartDateTime != null && learningEndDateTime != null) {
        _showProgressPrompt();
      }
    });
    _fetchGameProgress();
  }

  Future<void> _fetchGameProgress() async {
    final docRef = FirebaseFirestore.instance
        .collection("Mental stimulation")
        .doc("hiIyyqWGzb9eR4RgAHAl")
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
        .collection("Mental stimulation")
        .doc("hiIyyqWGzb9eR4RgAHAl")
        .collection("focus-activities-progress")
        .where("completed", isEqualTo: true)
        .get();

    setState(() {
      // Example: progress is number of completed activities (adjust as needed)
      focusActivityProgress = query.docs.length * 20; // e.g., 5 activities = 100%
      if (focusActivityProgress > 100) focusActivityProgress = 100;
    });
  }

  void _showProgressPrompt() async {
    double? percent = await showDialog<double>(
      context: context,
      builder: (context) {
        double tempPercent = 0;
        return AlertDialog(
          title: const Text("What percentage have you done?"),
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
        learningProgress = percent.toInt();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mental Stimulation',
          style: AppStyle.cardTitle
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66C3A7), Color(0xFF2A7F67)], // Gradient
            ),
          ),
        ),
        elevation: 5,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)], // Background gradient
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

              _buildSection(
                title: 'Learning Journey',
                subtitle: 'Engage in new learning.',
                icon: const Icon(Icons.lightbulb),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _learningModuleController,
                      decoration: customInputDecoration(
                        labelText: 'Enter a learning task',
                        hintText: 'e.g Learn a new language',
                        prefixIcon: const Icon(Icons.book, color: Colors.green),
                      ),
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
                          icon: const Icon(Icons.play_arrow, color: Color(0xFF66C3A7)),
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
                          icon: const Icon(Icons.stop, color: Color(0xFF66C3A7)),
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
                      onPressed: () {
                        if (_learningModuleController.text.isNotEmpty &&
                            learningStartDateTime != null &&
                            learningEndDateTime != null) {
                          _saveLearningJourney(
                            _learningModuleController.text,
                            learningStartDateTime!,
                            learningEndDateTime!,
                          );
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
                        MaterialPageRoute(builder: (context) => const PuzzleGame()),
                      );
                    } 
                    else if (value == 'Pattern Recognition') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PatternRecognitionGame()),
                      );
                    }
                    else if (value == 'Cognitive Tasks') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CognitiveTasksPage()),
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
                      ElevatedButton(
                        onPressed: () async {
                          // Save completion to Firestore
                          await FirebaseFirestore.instance
                              .collection("Mental stimulation")
                              .doc("hiIyyqWGzb9eR4RgAHAl")
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
                        },
                        child: const Text("Done"),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),

              _buildSection(
                title: 'Track Your Progress',
                subtitle: 'See how your skills improve over time:',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Puzzle Progress:'),
                    LinearProgressIndicator(value: puzzleProgress / 100),
                    const SizedBox(height: 10),
                    const Text('Pattern Recognition Progress:'),
                    LinearProgressIndicator(value: patternRecognitionProgress / 100),
                    const SizedBox(height: 10),
                    const Text('Cognitive Tasks Progress:'),
                    LinearProgressIndicator(value: cognitiveTasksProgress / 100),
                    const SizedBox(height: 10),
                    const Text('Focus Activity Progress:'),
                    LinearProgressIndicator(value: focusActivityProgress / 100),
                    const SizedBox(height: 10),
                    
                    // Save game scores
                    ElevatedButton(
                      onPressed: () {
                        _saveGameProgress("Puzzle", puzzleScore, 100);
                        _saveGameProgress("Pattern Recognition", patternRecognitionScore, 100);
                        _saveGameProgress("Cognitive Tasks", cognitiveScore, 100);
                        _fetchGameProgress(); // Refresh after saving
                      },
                      child: const Text("Save Scores"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildSection(
                title: 'Wellbeing Reminders',
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
                          callSomeoneDate = dateTime; // Store the combined DateTime
                          callSomeoneTime = TimeOfDay.fromDateTime(dateTime); // Extract TimeOfDay for display
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
                                                  callSomeonePhoneNumber = number; // or contact.phoneNumbers!.first
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
                        if (callSomeoneDate != null && callSomeoneContact != null) {
                          _saveWellBeingReminder(
                            "Call Someone (Family/Friend)",
                            callSomeoneDate,
                            callSomeoneContact,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please set both date/time and contact before saving.")),
                          );
                        }
                      },
                    ),
                    _buildReminderTileWithDateAndContact(
                      title: "Check on Spouse / Partner",
                      date: checkLoverDate,
                      contact: checkLoverContact,
                      phoneNumber: checkLoverPhoneNumber, // <-- Pass the selected number here
                      onDateTimePressed: () => _pickDateTime(context, "Check on Spouse / Partner", (dateTime) {
                        setState(() {
                          checkLoverDate = dateTime; // Store the combined DateTime
                          checkLoverTime = TimeOfDay.fromDateTime(dateTime); // Extract TimeOfDay for display
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
                          selfTreatDate = dateTime; // Store the combined DateTime
                          selfTreatTime = TimeOfDay.fromDateTime(dateTime); // Extract TimeOfDay for display
                        });
                      }),
                      onLocationChanged: (location) {
                        setState(() {
                          selfTreatLocation = location; // Update the location
                        });
                      },
                      onSavePressed: () {
                        if (selfTreatDate != null && selfTreatLocation != null && selfTreatLocation!.isNotEmpty) {
                          _saveWellBeingReminder(
                            "Give Yourself a Treat",
                            selfTreatDate,
                            selfTreatLocation,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please set both date/time and location before saving.")),
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
                    backgroundColor: const Color(0xFF66C3A7).withOpacity(0.2), // Updated background color
                    child: icon
                  // Icon(icon, color: Color(0xFF66C3A7), size: 24), // Updated icon color
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

  Widget _buildReminderTile({required String title, TimeOfDay? time, required VoidCallback onPressed}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(time != null ? "Set for ${time.format(context)}" : "Not set"),
      trailing: IconButton(
        icon: const Icon(Icons.alarm, color: Color(0xFF66C3A7)), // Updated icon color
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildReminderTileWithDateAndContact({
    required String title,
    DateTime? date,
    String? contact,
    String? phoneNumber, // <-- Add this parameter
    required VoidCallback onDateTimePressed,
    required VoidCallback onContactPressed,
    VoidCallback? onSavePressed,
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
                  onPressed: onContactPressed,
                ),
                // Call button
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: (phoneNumber != null && phoneNumber.isNotEmpty)
                      ? () async {
                          final cleanedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
                          print('Calling number: $cleanedNumber');
                          final Uri callUri = Uri(scheme: 'tel', path: cleanedNumber);
                          if (await canLaunchUrl(callUri)) {
                            await launchUrl(callUri);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Could not launch phone call")),
                            );
                          }
                        }
                      : null,
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
    // Only update the controller's text if the location changes
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
}