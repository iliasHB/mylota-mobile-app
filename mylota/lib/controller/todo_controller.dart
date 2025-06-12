import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mylota/core/usecase/provider/todo_schedule_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/subscription_alert.dart';

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
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      DocumentSnapshot docSnap = await userDoc.get();

      Map<String, dynamic> sub = {};
      // Map<String, dynamic> email = {};
      if (docSnap.exists && docSnap.data() != null) {
        Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;
        sub = Map<String, dynamic>.from(data['subscription'] ?? {});
        // email = data['email'] ?? {});
        // if (sub.containsKey('expiredAt')) {
        // Parse expiredAt from String to DateTime
        DateTime expiredAt = DateTime.parse(sub['expiredAt']);
        DateTime now = DateTime.now();

        // Compare dates
        if (now.isAfter(expiredAt)) {
          onStopLoading();
          // subscription expired
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      SubscriptionAlert(
                        // plan: sub['type'],
                        // amount: sub['amount'],
                          email: data['email']
                      )));
        } else {
          DocumentReference userDoc =
          FirebaseFirestore.instance.collection('todo-goals').doc(user.uid);

          DocumentSnapshot docSnapshot = await userDoc.get();
          List<dynamic> existingTasks = [];

          if (docSnapshot.exists && docSnapshot.data() != null) {
            Map<String, dynamic> data = docSnapshot.data() as Map<
                String,
                dynamic>;
            existingTasks =
            List<Map<String, dynamic>>.from(data['tasks'] ?? []);
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
              final time = newTask['reminder-date']
                  .toString()
                  .split(' ')
                  .last;
              final reminderTime = time
                  .toString()
                  .split('.')
                  .first;
              final reminderDate = newTask['reminder-date']
                  .toString()
                  .split(' ')
                  .first;
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
                  .startTodoSchedule(
                  newTask['title'], reminderTime, acknowledged,
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
        }
      }
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
}
