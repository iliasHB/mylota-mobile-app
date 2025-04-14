import 'package:flutter/material.dart';

class MentalStimulationWidget extends StatefulWidget {
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
        const Text(
          'Track your learning journey:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  labelText: "Enter a learning task",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _checkTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66C3A7), // Green theme color
              ),
              child: const Text("Submit"),
            ),
          ],
        ),
      ],
    );
  }
}
