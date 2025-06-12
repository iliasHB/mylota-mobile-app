import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mylota/core/usecase/provider/todo_schedule_provider.dart';
import 'package:provider/provider.dart';

class TodoController {
  static Future<void> saveTasks(
      List<Map<String, dynamic>> tasks, BuildContext context,
      {required VoidCallback onStartLoading,
      required VoidCallback onStopLoading}) async {
    try {
      onStartLoading();
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in!");
        onStopLoading();
        return;
      }

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('todo-goals').doc(user.uid);

      DocumentSnapshot docSnapshot = await userDoc.get();
      List<dynamic> existingTasks = [];

      if (docSnapshot.exists && docSnapshot.data() != null) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        existingTasks = List<Map<String, dynamic>>.from(data['tasks'] ?? []);
      }

      // print("Existing Tasks Before Update: ${jsonEncode(existingTasks)}");

      for (var newTask in tasks) {
        int existingIndex = existingTasks
            .indexWhere((task) => task['title'] == newTask['title']);

        if (existingIndex != -1) {
          // existingTasks[existingIndex]['description'] = newTask['description'];
          // existingTasks[existingIndex]['timestamp'] = Timestamp.now().toDate().toIso8601String();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('To-Do already exist'),
              backgroundColor: Colors.black,
              duration: Duration(seconds: 2),
            ),
          );
          onStopLoading();
          return;
        } else {
          // final today = DateTime.now();
          // final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
          final time = newTask['reminder-date'].toString().split(' ').last;
          final reminderTime = time.toString().split('.').first;
          final reminderDate = newTask['reminder-date'].toString().split(' ').first;
          bool acknowledged = false;
          existingTasks.add({
            'reminder-date': reminderDate, // Default if null,
            'title': newTask['title'],
            'description': newTask['description'],
            'reminder-time': reminderTime,
            'acknowledged': acknowledged,
            'createdAt': newTask['createdAt'].toString(),
          });
          Provider.of<ToDoScheduleProvider>(context, listen: false)
              .startTodoSchedule(newTask['title'], reminderTime, acknowledged,
                  reminderDate); // false ind
        }
      }
      if (existingTasks.isNotEmpty) {
        await userDoc.set({
          'tasks': existingTasks,
        }, SetOptions(merge: true));
        print("Firestore update completed!");
      } else {
        print("No tasks to save!");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('To-Do List saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      onStopLoading();
    } catch (e) {
      onStopLoading();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save tasks. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // static void checkAndResetAcknowledgedFlag(BuildContext context) async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid == null) return;
  //
  //   final docSnapshot = await FirebaseFirestore.instance
  //       .collection('todo-goals')
  //       .doc(uid)
  //       .get();
  //
  //   if (!docSnapshot.exists) return;
  //
  //   final data = docSnapshot.data();
  //   if (data == null) return;
  //
  //   final today = DateTime.now();
  //   // final todayWeekday = DateFormat('EEEE').format(today); // e.g., "Monday"
  //   final todayTodos = data['tasks']; // Access "Monday" block
  //
  //   if (todayTodos == null || todayTodos is! Map<String, dynamic>) return;
  //
  //   for (final todoType in todayTodos.keys) {
  //     final todoData = todayTodos[todoType];
  //     if (todoData is! Map<String, dynamic>) continue;
  //
  //     // String reminderTime = todoData['period'].toString().split(" ") as String;
  //
  //     final mealTimeStr = todoData['reminder-time'] ?? "08:00";
  //     final acknowledged = todoData['acknowledged'] ?? false;
  //     // final reminderDate = mealData['reminder-date'];
  //
  //     final mealTimeParts = mealTimeStr.split(":");
  //     final reminderTime = DateTime(
  //       today.year,
  //       today.month,
  //       today.day,
  //       int.parse(mealTimeParts[0]),
  //       int.parse(mealTimeParts[1]),
  //     );
  //
  //     final hasTimePassed = DateTime.now().isAfter(reminderTime);
  //
  //     if (acknowledged == true && hasTimePassed) {
  //       // Reset acknowledged flag only for this meal
  //       await FirebaseFirestore.instance
  //           .collection('todo-goals')
  //           .doc(uid)
  //           .update({
  //         "$todoData.$todoType.acknowledged": true,
  //         "$todoData.$todoType.reminder-date": DateFormat('yyyy-MM-dd').format(today),
  //       });
  //
  //       // Optional: log or handle this case
  //       debugPrint("Reset acknowledged for $todoType on $todoData");
  //     }
  //
  //     // Schedule notification only if not acknowledged
  //     // if (acknowledged == false) {
  //     //   final mealName = mealData['meal'] ?? '';
  //     //   final selectedItem = mealData['vegetable1'] ?? '';
  //     //   final selectedItem2 = mealData['vegetable2'] ?? '';
  //     //   final selectedCategory = mealData['name'] ?? "";
  //     //   final selectedDayCategory = mealData[todayWeekday] ?? "";
  //     //   final reminderTime = mealTimeStr ?? "08:00";
  //     //   bool acknowledge = false;
  //     //
  //     //   Provider.of<ToDoScheduleProvider>(context, listen: false)
  //     //       .startTodoSchedule(mealName, selectedCategory, selectedDayCategory,
  //     //       reminderTime, selectedItem, selectedItem2, acknowledge);
  //     // }
  //   }
  // }
}
