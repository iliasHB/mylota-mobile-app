import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:mylota/utils/styles.dart';
import 'package:mylota/widgets/custom_button.dart';
import 'dart:convert';

import '../controller/todo_controller.dart';
import 'custom_input_decorator.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescController = TextEditingController();
  List<Map<String, dynamic>> tasks = [];
  bool isDisable = false;
  bool isLoading = false;
  void _startLoading() => setState(() => isLoading = true);
  void _stopLoading() => setState(() => isLoading = false);
  // TimeOfDay? reminderPeriod;

  Future<void> _pickTime(BuildContext context, String title,
      Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      onTimeSelected(pickedTime);
    }
  }

  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  DateTime? fromDate;
  // DateTime? toDate;
  // String dropdownValue1 = speedType.first;

  // void _setDateRange(int daysAgo) {
  //   final now = DateTime.now();
  //   setState(() {
  //     fromDate = DateTime(now.year, now.month, now.day - daysAgo, 0, 0, 0);
  //     // toDate = DateTime(now.year, now.month, now.day - daysAgo, 23, 59, 59);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              // enabled: isDisable,
              prefixIcon: const Icon(
                Icons.calendar_month,
                color: Colors.green,
              ),
              filled: true,
              fillColor: const Color(0xFF2A7F67).withOpacity(0.3),
              hintStyle: AppStyle.cardfooter.copyWith(
                fontSize: 12,
              ),
              hintText: fromDate == null
                  ? 'Select Start Date and Time'
                  : fromDate.toString(),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(5)),
            ),
            onTap: () {
              DatePicker.showDateTimePicker(
                context,
                showTitleActions: true,
                onConfirm: (date) {
                  setState(() {
                    fromDate = date;
                    // isDisable = true;
                  });
                },
                currentTime: DateTime.now(),
              );
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _taskTitleController,
            cursorColor: const Color(0xFF66C3A7),
            decoration: customInputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter task',
                prefixIcon: const Icon(Icons.task, color: Colors.green)),
            validator: (value) {
              if (_taskTitleController.text.isEmpty ||
                  _taskTitleController.text == "") {
                return "Task title is empty";
              }
              return null;
            },
          ),
          /* const SizedBox(height: 10),
          TextFormField(
            controller: _taskDescController,
            cursorColor: const Color(0xFF66C3A7),
            decoration: customInputDecoration(
                labelText: 'Task Description',
                hintText: 'Enter task description',
                prefixIcon: const Icon(Icons.book, color: Colors.green)),
            validator: (value) {
              if (_taskDescController.text.isEmpty ||
                  _taskDescController.text == "") {
                return "Task title is empty";
              }
              return null;
            },
          ), */
          /* const SizedBox(height: 10),
          tasks.isEmpty
              ? const Center(child: Text('No tasks added yet.'))
              : Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(tasks[index]['title']),
                          subtitle: Text(tasks[index]['description']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeTask(index),
                          ),
                        ),
                      );
                    },
                  ),
                ), */
          const SizedBox(height: 20),
          Center(
              child: isLoading
                  ? const CustomContainerLoadingButton()
                  : CustomPrimaryButton(
                      label: 'Save',
                      onPressed: () async {
                        List<Map<String, dynamic>> tasks = [
                          {
                            'reminder-date': fromDate,
                            'title': _taskTitleController.text.trim(),
                            'description': _taskDescController.text.trim(),
                            'acknowledgment': false,
                            'createdAt': Timestamp.now().toDate().toIso8601String(),
                          },
                        ];
                        saveTodo(tasks, context);
                        // await TodoController.saveTasks(tasks, context);
                      }, 
                    )
          ),
        ],
      ),
    );
  }

  void saveTodo(List<Map<String, dynamic>> tasks, BuildContext context) async {
    await TodoController.saveTasks(
      tasks,
      context,
      onStartLoading: _startLoading,
      onStopLoading: _stopLoading,);
  }
}

// // Task List with constraints
// tasks[_selectedDay]!.isEmpty
//     ? const Center(
//   child: Text(
//     'No tasks yet. Add one!',
//     style: TextStyle(color: Colors.grey),
//   ),
// )
//     : ListView.builder(
//   shrinkWrap: true,
//   physics: const NeverScrollableScrollPhysics(),
//   itemCount: tasks[_selectedDay]?.length ?? 0,
//   itemBuilder: (context, index) {
//     return ListTile(
//       title: Text(tasks[_selectedDay]![index]),
//       trailing: IconButton(
//         icon: const Icon(Icons.delete, color: Colors.red),
//         onPressed: () => (){}//_removeTask(index),
//       ),
//     );
//   },
// ),
//
// const SizedBox(height: 20),

/// Save button
///
///
// void _addTask() {
//   if (_taskTitleController.text.isEmpty ||
//       _taskDescController.text.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Please enter both title and description'),
//         backgroundColor: Colors.orange,
//         duration: Duration(seconds: 2),
//       ),
//     );
//     return;
//   }
//
//   setState(() {
//     tasks.add({
//       'period': fromDate,
//       'title': _taskTitleController.text,
//       'description': _taskDescController.text,
//       'timestamp': Timestamp.now(),
//     });
//
//     _taskTitleController.clear();
//     _taskDescController.clear();
//   });
// }
