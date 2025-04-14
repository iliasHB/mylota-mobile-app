import 'package:flutter/material.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher for email

// Sample data (To-Do List for the week)
final Map<String, List<String>> weeklyTasks = {
  "Monday": ["Exercise", "Read a book", "Work on project"],
  "Tuesday": ["Buy groceries", "Write a report", "Call Mom"],
  "Wednesday": ["Attend meeting", "Code review", "Cook dinner"],
  "Thursday": ["Go to gym", "Watch a documentary", "Plan weekend"],
  "Friday": ["Finish assignment", "Team discussion", "Relax"],
  "Saturday": ["Go hiking", "Visit friends", "Watch movie"],
  "Sunday": ["Attend church", "Meal prep", "Family time"]
};

class ChallengePage extends StatefulWidget {
  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  final TextEditingController _taskController = TextEditingController();
  List<String> userAnswers = [];
  int score = 0;
  int patternLevel = 1;

  // Function to send email when "Need Help?" button is clicked
  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'mylota138@gmail.com',
      queryParameters: {'subject': 'Customer Support Inquiry'},
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open email client.")),
      );
    }
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
            colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)], // Gradient
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
                  _buildPatternGame(),
                  const SizedBox(height: 20),
                  _buildLeaderboard(),
                ],
              ),
            ),
          ],
        ),
      ),

      // Floating "Need Help?" Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendEmail,
        label: const Text("Need Help?"),
        icon: const Icon(Icons.help_outline),
        backgroundColor: const Color(0xFF66C3A7), // Matches theme color
      ),
    );
  }

  // Memory Test Section
  Widget _buildMemoryTest() {
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
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(labelText: "Enter a remembered task"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _checkTask,
              child: const Text("Submit Task"),
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
    String userTask = _taskController.text.trim();
    bool correct = weeklyTasks.values.any((tasks) => tasks.contains(userTask));
    setState(() {
      if (correct && !userAnswers.contains(userTask)) {
        userAnswers.add(userTask);
        score++;
      }
    });
    _taskController.clear();
  }

  // Pattern Recognition Game Section
  Widget _buildPatternGame() {
    return Card(
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Pattern Recognition Game",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("Level: $patternLevel"),
            ElevatedButton(
              onPressed: _generatePattern,
              child: const Text("Play Game"),
            ),
          ],
        ),
      ),
    );
  }

  void _generatePattern() {
    List<int> pattern = List.generate(patternLevel + 2, (index) => Random().nextInt(9));
    List<int> userPattern = List.from(pattern);
    userPattern.shuffle();

    // List of colors for the pattern game buttons
    List<Color> colors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.pink, Colors.brown, Colors.amber
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pattern Recognition"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Memorize this pattern: ${pattern.join(', ')}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("Select the correct pattern in order"),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8.0,
                children: userPattern.map((num) {
                  return ElevatedButton(
                    onPressed: () {
                      if (userPattern.join(',') == pattern.join(',')) {
                        setState(() {
                          patternLevel++;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Correct! Level Up! 🎉"))
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Wrong Pattern. Try Again! ❌"))
                        );
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors[num % colors.length], // Assign color based on number
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      "$num",
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // Leaderboard Section
  Widget _buildLeaderboard() {
    return Card(
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Leaderboard",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.amber),
              title: const Text("User123"),
              trailing: const Text("Score: 45"),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.grey),
              title: const Text("User456"),
              trailing: const Text("Score: 40"),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.brown),
              title: const Text("User789"),
              trailing: const Text("Score: 38"),
            ),
          ],
        ),
      ),
    );
  }
}
