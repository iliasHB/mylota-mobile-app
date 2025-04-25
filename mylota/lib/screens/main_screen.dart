import 'package:flutter/material.dart';
import 'package:mylota/controller/meal_planner_controller.dart';
import '../controller/todo_controller.dart';
import '../controller/water_intake_controller.dart';
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
    WaterInTakeController.checkAndResetAcknowledgedFlag(context);
    MealPlannerController.checkAndResetAcknowledgedFlag(context);
    // TodoController.checkAndResetAcknowledgedFlag(context);
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

}
