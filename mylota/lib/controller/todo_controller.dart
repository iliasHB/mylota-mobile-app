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
      {required Function onStartLoading,
      required Function onStopLoading}) async {
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
          List<Map<String, dynamic>> existingTasks = [];

          if (docSnapshot.exists && docSnapshot.data() != null) {
            Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
            existingTasks = List<Map<String, dynamic>>.from(data['tasks'] ?? []);
          }

          // print("Existing Tasks Before Update: ${jsonEncode(existingTasks)}");

          for (var newTask in tasks) {
            int existingIndex = existingTasks.indexWhere((task) => task['title'] == newTask['title']);

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
              final reminderDateTime = newTask['reminder-date'] as DateTime;
              existingTasks.add({
                'reminder-date': reminderDateTime,
                'title': newTask['title'],
                'description': newTask['description'],
                'acknowledgment': newTask['acknowledgment'] ?? false,
                'createdAt': DateTime.now().toString(), // Store current time
              });
              Provider.of<ToDoScheduleProvider>(context, listen: false)
                  .startTodoSchedule(
                      newTask['title'],
                      DateFormat('HH:mm:ss').format(reminderDateTime),
                      newTask['acknowledgment'] ?? false,
                      DateFormat('yyyy-MM-dd')
                          .format(reminderDateTime)); // false ind
            }
          }

          // Sort the tasks based on createdAt in descending order
          existingTasks.sort((a, b) {
            DateTime dateA = DateTime.parse(a['createdAt']);
            DateTime dateB = DateTime.parse(b['createdAt']);
            return dateB.compareTo(dateA); // Sort in descending order
          });

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
