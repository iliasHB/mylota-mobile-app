import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TodoController {
  static Future<void> saveTasks(List<Map<String, dynamic>> tasks, TimeOfDay? reminderPeriod, BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in!");
        return;
      }

      DocumentReference userDoc = FirebaseFirestore.instance.collection('todo-goals').doc(user.uid);

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
          return;
        } else {
          existingTasks.add({
            'period': newTask['period'].toString(), // Default if null,
            'title': newTask['title'],
            'description': newTask['description'],
            'reminder': reminderPeriod!.format(context),
            'createdAt': Timestamp.now().toDate().toIso8601String(),
          });
        }
      }

      print("Final Tasks to Save: ${jsonEncode(existingTasks)}");

      if (existingTasks.isNotEmpty) {
        await userDoc.set({
          // 'user_id': user.uid,
          'tasks': existingTasks,
        }, SetOptions(merge: true));
        print("Firestore update completed!");
      } else {
        print("No tasks to save!");
      }

      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setString('tasks', jsonEncode(existingTasks));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('To-Do List saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error saving tasks: $e");
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