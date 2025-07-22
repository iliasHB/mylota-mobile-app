import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mylota/utils/styles.dart';

class MoreTodos extends StatefulWidget {
  final List<dynamic> tasks;
  final Map<String, bool> taskCompletions;

  const MoreTodos({Key? key, required this.tasks, required this.taskCompletions}) : super(key: key);

  @override
  State<MoreTodos> createState() => _MoreTodosState();
}

class _MoreTodosState extends State<MoreTodos> {
  late Map<String, bool> taskCompletions;

  @override
  void initState() {
    super.initState();
    taskCompletions = widget.taskCompletions;
  }

  Future<void> _updateTodoProgress(String taskId, bool isCompleted) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('todo-goals')
        .doc(user.uid)
        .update({
      'tasks': FieldValue.arrayRemove([
        {
          'id': taskId,
          'completed': !isCompleted, // Remove the old task
        }
      ])
    });

    await FirebaseFirestore.instance
        .collection('todo-goals')
        .doc(user.uid)
        .update({
      'tasks': FieldValue.arrayUnion([
        {
          'id': taskId,
          'completed': isCompleted, // Add the updated task
        }
      ])
    });

    setState(() {
      taskCompletions[taskId] = isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All To-Dos', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A7F67),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: widget.tasks.length,
          itemBuilder: (context, index) {
            var task = widget.tasks[index];
            final taskId = task['id'] ?? task['title'];
            DateTime? reminderDate;
            if (task['reminder-date'] is Timestamp) {
              reminderDate = (task['reminder-date'] as Timestamp).toDate();
            } else if (task['reminder-date'] is DateTime) {
              reminderDate = task['reminder-date'] as DateTime;
            }

            final period = reminderDate != null
                ? DateFormat('h:mm a').format(reminderDate)
                : "No time set";

            final isCompleted = taskCompletions[taskId] ?? false;

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['title'].toString(),
                            style: AppStyle.cardSubtitle,
                          ),
                          Text(
                            task['description'] ?? "",
                            style: AppStyle.cardfooter,
                          ),
                          Text(
                            'Time: $period',
                            style: AppStyle.cardfooter,
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: isCompleted,
                      onChanged: (value) {
                        _updateTodoProgress(taskId, value ?? false);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
