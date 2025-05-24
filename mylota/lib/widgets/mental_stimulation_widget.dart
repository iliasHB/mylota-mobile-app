import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/styles.dart';
import 'custom_button.dart';
import 'custom_input_decorator.dart';

class MentalStimulationWidget extends StatefulWidget {
  const MentalStimulationWidget({super.key});

  @override
  _MentalStimulationWidgetState createState() => _MentalStimulationWidgetState();
}

class _MentalStimulationWidgetState extends State<MentalStimulationWidget> {
  final TextEditingController _taskController = TextEditingController();

  // Method to push the task to Firebase
  Future<void> _checkTask() async {
    String task = _taskController.text.trim();
    if (task.isNotEmpty) {
      try {
        // Push the task to Firestore
        await FirebaseFirestore.instance
            .collection("Mental stimulation") // Firestore collection
            .doc("hiIyyqWGzb9eR4RgAHAl") // Replace with your document ID
            .collection("learning-tasks") // Sub-collection for tasks
            .add({
          "task": task,
          "timestamp": FieldValue.serverTimestamp(), // Add a timestamp
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Task Added: $task")),
        );

        // Clear the input field
        _taskController.clear();
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add task: $e")),
        );
      }
    } else {
      // Show error if the input is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task cannot be empty")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Track your learning journey:',
          style: AppStyle.cardfooter,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _taskController,
          decoration: customInputDecoration(
            labelText: "Enter a learning task",
            prefixIcon: const Icon(Icons.bookmark_add_outlined),
            hintText: "e.g I want to learn French",
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: CustomPrimaryButton(
            label: 'Submit',
            onPressed: _checkTask, // Call the method to push the task
          ),
        ),
      ],
    );
  }
}
