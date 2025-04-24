import 'package:flutter/material.dart';
import 'package:mylota/utils/styles.dart';


class MoreMealSchedule extends StatelessWidget {
  const MoreMealSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Schedule', style: AppStyle.cardTitle,),
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
          Center(child: Text('All Meal Schedule'))
        ],
      ),
    );
  }
}
