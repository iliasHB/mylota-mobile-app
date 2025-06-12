import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mylota/utils/styles.dart';

import 'details_item.dart';

class MoreMealSchedule extends StatelessWidget {
  const MoreMealSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meal Schedule',
          style: AppStyle.cardTitle,
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('meal-planner')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(
                    child: Text(
                      "No meals available",
                      style: AppStyle.cardSubtitle,
                    ),
                  );
                }

                String currentDay = DateFormat('EEEE').format(DateTime.now());
                Map<String, dynamic>? data =
                    snapshot.data!.data() as Map<String, dynamic>?;

                if (data == null || !data.containsKey(currentDay)) {
                  return Center(
                    child: Text(
                      "No meals schedule set for today",
                      style: AppStyle.cardfooter,
                    ),
                  );
                }

                Map<String, dynamic> categories = data[currentDay]
                    as Map<String, dynamic>; // e.g., Breakfast, Lunch...

                return Column(
                  children: [
                    Expanded(
                      // height: 300,
                      child: ListView(
                        // physics:
                        // const NeverScrollableScrollPhysics(),
                        children: categories.entries.map((entry) {
                          String mealType = entry.key; // Breakfast, Lunch, Dinner
                          Map<String, dynamic> meal = entry.value; // The meal object

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    currentDay,
                                    style: AppStyle.cardSubtitle
                                        .copyWith(fontSize: 14),
                                  ),
                                  Text(
                                    mealType,
                                    style: AppStyle.cardSubtitle
                                        .copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                              _buildMealItem(meal),
                              const Divider(),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildMealItem(Map<String, dynamic> meal) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: DetailItem(
      title: meal['name']?.toString() ?? "No name",
      desc: '${meal['vegetable1']?.toString() ?? "No vegetable 1"}, '
          '${meal['vegetable1']?.toString() ?? "No vegetable 2"}',
      period: '${meal['meal-time']?.toString() ?? "No period"}',
    ),
  );
}