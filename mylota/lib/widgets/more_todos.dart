import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/styles.dart';
import 'details_item.dart';


class MoreTodos extends StatelessWidget {
  const MoreTodos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Todos', style: AppStyle.cardTitle,),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66C3A7), Color(0xFF2A7F67)],
            ),
          ),
        ),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('todo-goals')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
                child: Text("No tasks available"));
          }

          Map<String, dynamic>? data = snapshot.data!
              .data() as Map<String, dynamic>?;

          if (data == null ||
              !data.containsKey('tasks') ||
              (data['tasks'] as List).isEmpty) {
            return const Center(
                child: Text("No tasks available"));
          }

          List<dynamic> tasks = data['tasks'];

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Expanded(
                  // height: 200,
                  child: ListView.builder(
                    // physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      var task = tasks[index];
                      return Column(
                        children: [
                          DetailItem(
                              title: task['title'].toString(),
                              desc: task['description'],
                              period: task['period'] ?? "No period"),
                          const Divider(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // const Column(
      //   children: [
      //     Center(child: Text('All Todo'))
      //   ],
      // ),
    );
  }
}
