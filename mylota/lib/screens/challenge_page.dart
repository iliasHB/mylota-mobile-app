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
        onPressed: _sendEmail,
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
            DropdownButtonFormField<String>(
              value: selectedDay,
              items: weeklyTasks.keys.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
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
            DropdownButtonFormField<String>(
              value: selectedTask,
              items: (selectedDay != null && weeklyTasks[selectedDay!] != null)
                  ? weeklyTasks[selectedDay!]!.map((task) {
                      return DropdownMenuItem(
                        value: task,
                        child: Text(task),
                      );
                    }).toList()
                  : [],
              onChanged: (value) {
                setState(() {
                  selectedTask = value;
                });
              },
              decoration: customInputDecoration(
                labelText: 'Select Task',
                hintText: 'Choose a task to remember',
                prefixIcon: const Icon(Icons.bookmark, color: Colors.green),
              ),
            ),
            const SizedBox(height: 10),
            CustomPrimaryButton(
              label: "Submit Task",
              onPressed: (selectedDay != null && selectedTask != null)
                  ? _checkTask
                  : () {},
            ),
            Text(
              "Score: $score / ${weeklyTasks.values.expand((x) => x).length}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _checkTask() {
    if (selectedDay == null || selectedTask == null) return;
    bool correct = weeklyTasks[selectedDay!]!.contains(selectedTask!);
    setState(() {
      if (correct && !(userAnswers.contains("$selectedDay:$selectedTask"))) {
        userAnswers.add("$selectedDay:$selectedTask");
        score++;
        rememberedPerDay[selectedDay!] = (rememberedPerDay[selectedDay!] ?? 0) + 1;
        _showTrophyDialog();
      } else if (!correct) {
        _showTryAgainDialog();
      }
      selectedTask = null;
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
        content: const Text("That task does not match today's to-do list."),
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

  void _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'mylota138@yahoo.com',
      query: Uri.encodeFull('subject=Weekly Challenge Feedback&body=Hello,'),
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open email app")),
      );
    }
  }
}
