import 'package:flutter/material.dart';

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

  void _checkTask() {
    String task = _taskController.text.trim();
    if (task.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Task Added: $task")),
      );
      _taskController.clear(); // Clear input after submission
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
          decoration:  customInputDecoration(
            labelText: "Enter a learning task",
            prefixIcon: const Icon(Icons.bookmark_add_outlined),
            hintText: 'Enter a learning task',
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: CustomPrimaryButton(
            label: 'Submit',
            onPressed: () {  },),
        ),
        const SizedBox(height: 10),
        // ElevatedButton(
        //   onPressed: _checkTask,
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: const Color(0xFF66C3A7), // Green theme color
        //   ),
        //   child: const Text("Submit"),
        // ),
      ],
    );
  }
}
