import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/styles.dart';
import '../widgets/exercise_goal.dart';
import '../widgets/sleep_goal.dart';
import '../widgets/todo_list.dart';
import '../widgets/water_tracker.dart';
import '../widgets/meal_planner.dart';
import '../widgets/mental_stimulation_widget.dart'; // Import the Mental Stimulation widget

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wellness Planner',
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
            colors: [
              Color(0xFFE0F2F1), // Blush
              Color(0xFFB2DFDB), // Light Purple
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Goal
                _buildSectionCard(
                  title: 'Exercise Goal',
                  subtitle: 'Track your daily fitness targets.',
                  icon: const Text(
                    '🏋️‍♂️',
                    style: TextStyle(fontSize: 20)),
                  // Icons.fitness_center,
                  child: const ExerciseGoal(),
                ),
                const SizedBox(height: 20),

                // To-Do List
                _buildSectionCard(
                  title: 'To-Do List',
                  subtitle: 'Plan your tasks for the day.',
                  icon:  const Text(
                    '📝',
                    style: TextStyle(fontSize: 20),
                  ),
                  // Icons.checklist,
                  child: const ToDoList(),
                ),
                const SizedBox(height: 20),

                // Water Tracker
                _buildSectionCard(
                  title: 'Water Tracker',
                  subtitle: 'Stay hydrated and track your intake.',
                  icon: const Text(
                    '💧',
                    style: TextStyle(fontSize: 20),
                  ),
                  // Icons.local_drink,
                  child: const WaterTracker(),
                ),
                const SizedBox(height: 20),

                // Meal Planner
                _buildSectionCard(
                  title: 'Meal Planner',
                  subtitle: 'Plan colorful, balanced meals.',
                  icon: const Text(
                    '🍱',
                    style: TextStyle(fontSize: 20),
                  ),
                  child: const MealPlanner(),
                ),
                const SizedBox(height: 20),

                // Sleep Goal
                _buildSectionCard(
                  title: 'Sleep Goal',
                  subtitle: 'Set your ideal sleep and wake times.',
                  icon: const Text(
                    '🌙',
                    style: TextStyle(fontSize: 20),
                  ),
                  // Icons.nightlight_round,
                  child: SleepGoal(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
  // Widget for building a section card
  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget icon,
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
  }}