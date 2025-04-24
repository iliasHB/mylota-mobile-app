import 'package:flutter/material.dart';

import '../utils/styles.dart';


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

      body: const Column(
        children: [
          Center(child: Text('All Todo'))
        ],
      ),
    );
  }
}
