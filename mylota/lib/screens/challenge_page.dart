import 'package:flutter/material.dart';
import 'package:mylota/widgets/custom_button.dart';
import 'package:mylota/widgets/custom_input_decorator.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengePage extends StatefulWidget {
  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  final TextEditingController _taskController = TextEditingController();
  List<String> userAnswers = [];
  int score = 0;
  int patternLevel = 1;

  // Move these inside the state class
  Map<String, List<String>> weeklyTasks = {};
  bool isLoadingTasks = true;

  String? selectedDay;
  String? selectedTask;
  Map<String, int> rememberedPerDay = {};

  @override
  void initState() {
    super.initState();
    _fetchWeeklyTasks();
  }

  Future<void> _fetchWeeklyTasks() async {
    setState(() {
      isLoadingTasks = true;
    });
    final doc = await FirebaseFirestore.instance
        .collection('to-do-lists')
        .doc('weekly') // Adjust this to your Firestore structure
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        weeklyTasks = data.map((key, value) =>
            MapEntry(key, List<String>.from(value as List)));
        isLoadingTasks = false;
      });
    } else {
      setState(() {
        isLoadingTasks = false;
      });
    }
  }

  // Add these variables for dropdowns and progress
  // Helper to get tasks for the selected day
  List<String> get dayTasks {
    if (selectedDay == null) return [];
    return weeklyTasks[selectedDay!] ?? [];
  }

  // Calculate progress as percentage of all tasks remembered
  int get progressPercent {
    final total = weeklyTasks.values.fold<int>(0, (sum, list) => sum + list.length);
    final remembered = rememberedPerDay.values.fold<int>(0, (sum, val) => sum + val);
    if (total == 0) return 0;
    return ((remembered / total) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weekly Challenge",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
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
            colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildMemoryTest(),
                  const SizedBox(height: 20),
                  _buildLeaderboard(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
    launchEmail(
      toEmail: 'mylota138@gmail.com',
      subject: 'Help Request',
      body: 'Hi, I need assistance with...',
    );
  },
        label: const Text("Need Help?"),
        icon: const Icon(Icons.help_outline),
        backgroundColor: const Color(0xFF66C3A7),
      ),
    );
  }

  // Memory Test Section
  Widget _buildMemoryTest() {
    if (isLoadingTasks) {
      return const Center(child: CircularProgressIndicator());
    }
    return Card(
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Remember Your Weekly Tasks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Change to dropdown for week days
            DropdownButtonFormField<String>(
              value: selectedDay,
              items: weekDaysWithDates.map((dayMap) {
                return DropdownMenuItem(
                  value: dayMap['value'],
                  child: Text(dayMap['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDay = value;
                  selectedTask = null;
                });
              },
              decoration: customInputDecoration(
                labelText: 'Select Day',
                hintText: 'Choose a day of the week',
                prefixIcon: const Icon(Icons.calendar_today, color: Colors.green),
              ),
            ),
            const SizedBox(height: 10),
            // User enters task
            TextField(
              controller: _taskController,
              decoration: customInputDecoration(
                labelText: 'Enter Task',
                hintText: 'e.g. To-do list items',
                prefixIcon: const Icon(Icons.bookmark, color: Colors.green),
              ),
              onChanged: (value) {
                setState(() {
                  selectedTask = value.trim();
                });
              },
            ),
            const SizedBox(height: 10),
            CustomPrimaryButton(
              label: "Submit Task",
              onPressed: () {
                if (selectedDay != null && selectedDay!.isNotEmpty && selectedTask != null && selectedTask!.isNotEmpty) {
                  _checkTask();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a day and enter a task before submitting.")),
                  );
                }
              },
            ),
            Text(
              "Score: $score / ${weeklyTasks.values.expand((x) => x).length}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (selectedDay != null && weeklyTasks[selectedDay!] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Tasks for ${selectedDay!}: ${weeklyTasks[selectedDay!]!.join(', ')}",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _checkTask() {
    if (selectedDay == null || selectedTask == null) return;

    // Normalize user input
    final dayKey = selectedDay!.trim().toLowerCase();
    final userTask = selectedTask!.trim().toLowerCase();

    // Find the matching day in weeklyTasks (case-insensitive)
    final matchingDay = weeklyTasks.keys.firstWhere(
      (k) => k.trim().toLowerCase() == dayKey,
      orElse: () => '',
    );
    final taskGoalList = matchingDay.isNotEmpty ? weeklyTasks[matchingDay] : null;

    // Compare user input with each task title (case-insensitive, trimmed)
    bool correct = taskGoalList != null &&
        taskGoalList.any((t) => t.trim().toLowerCase() == userTask);

    setState(() {
      if (correct && !(userAnswers.contains("$matchingDay:$userTask"))) {
        userAnswers.add("$matchingDay:$userTask");
        score++;
        rememberedPerDay[matchingDay] = (rememberedPerDay[matchingDay] ?? 0) + 1;
        _showTrophyDialog();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Correct! Task remembered.")),
        );
      } else if (!correct) {
        _showTryAgainDialog();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect. That task does not match the day's to-do list.")),
        );
      }
      // Reset fields after submit
      selectedDay = null;
      selectedTask = null;
      _taskController.clear();
    });
  }

  void _showTrophyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🎉 Congratulations!"),
        content: const Text("You remembered the correct task!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showTryAgainDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Try Again"),
        content: const Text("That task does not match the day's to-do list."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Leaderboard Section
  Widget _buildLeaderboard() {
    return Card(
      color: const Color(0xFF2A7F67),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Leaderboard",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.amber),
              title: const Text(
                "You",
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                "Progress: $progressPercent%",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.emoji_events, color: Colors.grey),
              title: Text(
                "User456",
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                "Score: 40",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.emoji_events, color: Colors.brown),
              title: Text(
                "User789",
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                "Score: 38",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void launchEmail({
  required String toEmail,
  String subject = '',
  String body = '',
}) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: toEmail,
    queryParameters: {
      'subject': subject,
      'body': body,
    },
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    throw 'Could not launch email client';
  }
}


  List<Map<String, String>> get weekDaysWithDates {
    final now = DateTime.now();
    // Find the most recent Monday
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return List.generate(7, (i) {
      final date = monday.add(Duration(days: i));
      final formatted = "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)}";
      return {
        'label': "${days[i]} ($formatted)",
        'value': days[i],
      };
    });
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
