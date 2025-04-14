import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/usecase/provider/water_intake_provider.dart';
import 'home_page.dart';
import 'progress_page.dart';
import 'mental_stimulation_page.dart';
import 'challenge_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  // Define weeklyTodoLists for the ChallengePage
  final Map<String, List<String>> weeklyTodoLists = {
    "Week 1": ["Task 1", "Task 2"],
    "Week 2": ["Task 3", "Task 4"],
  };

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Check and reset the acknowledged flag daily
    checkAndResetAcknowledgedFlag();
    // Initialize pages for the bottom navigation bar
    _pages = [
      HomePage(),
      const ProgressPage(
        exerciseGoal: 30.0,
        sleepGoal: 8.0,
      ),
      MentalStimulationPage(),
      ChallengePage(),
    ];
  }

  // Update selected index on navigation bar tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page

      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ), // Smooth rounded edges
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF66C3A7), Color(0xFF2A7F67)], // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black,
            backgroundColor: Colors.transparent, // Makes background blend with gradient
            elevation: 0, // Removes shadow
            type: BottomNavigationBarType.fixed, // Keeps the height consistent
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
              BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Mental Stimulation'),
              BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Challenge'),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> checkAndResetAcknowledgedFlag() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print("User not logged in.");
      return;
    }

    final docSnapshot = await FirebaseFirestore.instance
        .collection('water-intake-schedule')
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      final bool isAcknowledged = data?['acknowledged'] ?? false;
      final String lastAcknowledgedDate = data?['createdAt'] ?? '';

      final today = DateTime.now();
      final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // Check if today is a new day and acknowledgment is already done
      if (isAcknowledged && lastAcknowledgedDate != todayStr) {
        // Reset acknowledged status
        await FirebaseFirestore.instance
            .collection('water-intake-schedule')
            .doc(uid)
            .update({
          'acknowledged': false, // Reset acknowledged for new day
          'createdAt': todayStr, // Update today's date
        });

        // Reschedule the reminder for today
        final reminderTime = data?['reminder-time'] ?? "08:00"; // Get reminder time from Firestore
        final intakeLiters = data?['daily-water-intake'] ?? "2"; // Get intake amount

        Provider.of<WaterReminderProvider>(context, listen: false)
            .startDailyWaterIntakeTimer(intakeLiters, reminderTime, false); // false indicates new day reminder
      }
    }
  }
}
