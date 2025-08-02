import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mylota/widgets/appBar_widget.dart';
import 'package:mylota/widgets/custom_button.dart';
import 'package:mylota/widgets/custom_input_decorator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChallengePage extends StatefulWidget {
  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  final TextEditingController _taskController = TextEditingController();
  List<String> userAnswers = [];
  int score = 0;
  Map<String, List<String>> weeklyTasks = {};
  bool isLoadingTasks = true;

  String? selectedDateKey;
  String? selectedTask;
  Map<String, int> rememberedPerDay = {};

  bool showCongratsImage = false;
  String congratsImagePath = 'assets/images/congrts.png'; // or whichever path you want
  double congratsImageScale = 0.5; // For animation

  @override
  void initState() {
    super.initState();
    _fetchWeeklyTasks();
  }

  Future<void> _fetchWeeklyTasks() async {
    setState(() { isLoadingTasks = true; });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() { isLoadingTasks = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to view your to-do list.')),
      );
      return;
    }

    try {
      final userDoc = FirebaseFirestore.instance.collection('todo-goals').doc(user.uid);
      final doc = await userDoc.get();
      if (doc.exists && doc.data() != null && doc.data()!.isNotEmpty) {
        final data = doc.data()!;
        Map<String, List<String>> groupedTasks = {};

        if (data['tasks'] is List) {
          for (var task in data['tasks']) {
            if (task is Map && task['reminder-date'] != null && task['title'] != null) {
              final date = task['reminder-date'].toString().trim();
              final title = task['title'].toString().trim();
              if (date.isNotEmpty && title.isNotEmpty) {
                groupedTasks.putIfAbsent(date, () => []).add(title);
              }
            }
          }
        }

        setState(() {
          weeklyTasks = groupedTasks;
          isLoadingTasks = false;
        });
      } else {
        setState(() { isLoadingTasks = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No to-do data found for your account.')),
        );
      }
    } catch (e) {
      setState(() { isLoadingTasks = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading to-do data: $e')),
      );
    }
  }

  List<String> get dayTasks {
    if (selectedDateKey == null) return [];
    return weeklyTasks[selectedDateKey!] ?? [];
  }

  int get progressPercent {
    final total = weeklyTasks.values.fold<int>(0, (sum, list) => sum + list.length);
    final remembered = rememberedPerDay.values.fold<int>(0, (sum, val) => sum + val);
    if (total == 0) return 0;
    return ((remembered / total) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context: context, title: "Weekly Challenge"),
      // AppBar(
      //   title: const Text(
      //     "Weekly Challenge",
      //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
      //   ),
      //   flexibleSpace: Container(
      //     decoration: const BoxDecoration(
      //       gradient: LinearGradient(
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //         colors: [Color(0xFF66C3A7), Color(0xFF2A7F67)],
      //       ),
      //     ),
      //   ),
      //   elevation: 5,
      // ),
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
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     launchEmail(
      //       toEmail: 'mylota138@gmail.com',
      //       subject: 'Help Request',
      //       body: 'Hi, I need assistance with...',
      //     );
      //   },
      //   label: const Text("Need Help?"),
      //   icon: const Icon(Icons.help_outline),
      //   backgroundColor: const Color(0xFF66C3A7),
      // ),
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
            // Calendar picker using customInputDecoration
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF2A7F67),
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xFF2A7F67),
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    selectedDateKey =
                        "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    selectedTask = null;
                  });
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  readOnly: true,
                  decoration: customInputDecoration(
                    labelText: 'Select Date',
                    hintText: 'Choose a date',
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.green),
                    suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                  ),
                  controller: TextEditingController(
                    text: selectedDateKey != null
                        ? _formattedDateLabel(selectedDateKey!)
                        : '',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                if (selectedDateKey != null && selectedDateKey!.isNotEmpty && selectedTask != null && selectedTask!.isNotEmpty) {
                  _checkTask();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a date and enter a task before submitting.")),
                  );
                }
              },
            ),
            Text(
              "Score: $score / ${weeklyTasks.values.expand((x) => x).length}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            //if (selectedDateKey != null && weeklyTasks[selectedDateKey!] != null)
              // Padding(
              //   padding: const EdgeInsets.only(top: 8.0),
              //   child: Text(
              //     "Tasks for ${_formattedDateLabel(selectedDateKey!)}: ${weeklyTasks[selectedDateKey!]!.join(', ')}",
              //     style: const TextStyle(fontSize: 13, color: Colors.grey),
              //   ),
              // ),
            if (showCongratsImage)
              Center(
                child: AnimatedScale(
                  scale: congratsImageScale,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  child: Image.asset(
                    congratsImagePath,
                    width: 180,
                    height: 180,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _checkTask() {
    if (selectedDateKey == null || selectedTask == null) return;

    final dateKey = selectedDateKey!;
    final userTask = selectedTask!.trim().toLowerCase();
    final taskGoalList = weeklyTasks[dateKey];

    bool correct = taskGoalList != null &&
        taskGoalList.any((t) => t.trim().toLowerCase() == userTask);

    setState(() {
      if (correct && !(userAnswers.contains("$dateKey:$userTask"))) {
        userAnswers.add("$dateKey:$userTask");
        score++;
        rememberedPerDay[dateKey] = (rememberedPerDay[dateKey] ?? 0) + 1;

        // Optionally update Firestore user score here
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'score': score});
        }

        _showCongratsImage();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Correct! Task remembered.")),
        );
      } else if (!correct) {
        _showTryAgainDialog();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect. That task does not match the day's to-do list.")),
        );
      }
      selectedDateKey = null;
      selectedTask = null;
      _taskController.clear();
    });
  }

  void _showCongratsImage() {
    // Randomly choose between two images if you want
    final images = [
      'assets/images/congrts.png',
      'assets/images/congrts2.png',
    ];
    final randomIndex = Random().nextInt(images.length);

    setState(() {
      congratsImagePath = images[randomIndex];
      showCongratsImage = true;
      congratsImageScale = 0.5;
    });

    // Animate scale up
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          congratsImageScale = 2.0;
        });
      }
    });

    // Hide after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showCongratsImage = false;
        });
      }
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

  Widget _buildLeaderboard() {
    final currentUser = FirebaseAuth.instance.currentUser;
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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs;
                // Sort users by score descending
                users.sort((a, b) {
                  final aScore = (a.data() as Map<String, dynamic>)['score'] ?? 0;
                  final bScore = (b.data() as Map<String, dynamic>)['score'] ?? 0;
                  return bScore.compareTo(aScore);
                });
                return Column(
                  children: users.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final uid = data['uid'] ?? '';
                    final name = '${data['firstname'] ?? ''} ${data['lastname'] ?? ''}'.trim();
                    final score = data['score'] ?? 0;

                    // Mask other users' names
                    String displayName;
                    if (currentUser != null && currentUser.uid == uid) {
                      displayName = name.isNotEmpty ? name : "You";
                    } else {
                      // Mask: show first letter + *** + last letter (if available)
                      if (name.isNotEmpty && name.length > 2) {
                        displayName = '${name[0]}***${name[name.length - 1]}';
                      } else if (name.isNotEmpty) {
                        displayName = '${name[0]}***';
                      } else {
                        displayName = "User***";
                      }
                    }

                    return ListTile(
                      leading: const Icon(Icons.emoji_events, color: Colors.amber),
                      title: Text(
                        displayName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        "Score: $score",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // void launchEmail({
  //   required String toEmail,
  //   String subject = '',
  //   String body = '',
  // }) async {
  //   final gmailUrl = Uri.parse(
  //     "googlegmail://co?to=$toEmail&subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}"
  //   );
  //   final mailtoUrl = Uri(
  //     scheme: 'mailto',
  //     path: toEmail,
  //     queryParameters: {
  //       'subject': subject,
  //       'body': body,
  //     },
  //   );

  //   // Try to launch Gmail app
  //   if (await canLaunchUrl(gmailUrl)) {
  //     await launchUrl(gmailUrl);
  //   } else if (await canLaunchUrl(mailtoUrl)) {
  //     // Fallback to default mail client
  //     await launchUrl(mailtoUrl);
  //   } else {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('No email app found. Please install or set up an email app.')),
  //       );
  //     }
  //   }
  // }

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
      final dateKey = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      return {
        'label': "${days[i]} ($formatted)",
        'value': dateKey,
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

  String _formattedDateLabel(String dateKey) {
    try {
      final parts = dateKey.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}";
    } catch (_) {
      return dateKey;
    }
  }
}
