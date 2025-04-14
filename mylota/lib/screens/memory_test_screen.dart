import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../models/task.dart';

class MemoryTestScreen extends StatefulWidget {
  @override
  _MemoryTestScreenState createState() => _MemoryTestScreenState();
}

class _MemoryTestScreenState extends State<MemoryTestScreen> {
  List<Task> savedTasks = [];
  List<String> userInput = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    List<Task> tasks = await TaskService.loadTasks();
    setState(() => savedTasks = tasks);
  }

  void _checkTask() {
    if (savedTasks.any((task) => task.title.toLowerCase() == _controller.text.toLowerCase())) {
      setState(() {
        userInput.add(_controller.text);
      });
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Memory Test")),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "Enter remembered task"),
          ),
          ElevatedButton(onPressed: _checkTask, child: Text("Check Task")),
          Expanded(
            child: ListView.builder(
              itemCount: savedTasks.length,
              itemBuilder: (context, index) {
                bool correct = userInput.contains(savedTasks[index].title);
                return ListTile(
                  title: Text(savedTasks[index].title,
                      style: TextStyle(color: correct ? Colors.green : Colors.black)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
