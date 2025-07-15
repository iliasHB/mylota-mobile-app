import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mylota/core/usecase/provider/meal_planner_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/subscription_alert.dart';

class MealPlannerController {
  static Future<void> saveMeals({
    required BuildContext context,
    required String mealController,
    required String selectedCategory,
    required String selectedDayCategory,
    TimeOfDay? mealTime,
    String? selectedItem,
    String? selectedItem2,
    required VoidCallback onStartLoading,
    required VoidCallback onStopLoading,
  }) async {
    if (mealController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal name cannot be empty!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      onStartLoading();
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in!");
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
          FirebaseFirestore.instance.collection('meal-planner').doc(user.uid);

          DocumentSnapshot docSnapshot = await userDoc.get();
          Map<String, dynamic> mealData = {};

          if (docSnapshot.exists && docSnapshot.data() != null) {
            mealData = docSnapshot.data() as Map<String, dynamic>;
          }

          Map<String, dynamic> mealsByDay = mealData[selectedDayCategory] ?? {};

          // Check if meal already exists for the category (e.g., Breakfast, Lunch, etc.)
          if (mealsByDay.containsKey(selectedCategory)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Meal already exists for this time. Updating...'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
          final today = DateTime.now();
          final todayStr =
              "${today.year}-${today.month.toString().padLeft(2, '0')}-${today
              .day.toString().padLeft(2, '0')}";
          // String formattedTime = reminderPeriod!.format(context);
          bool acknowledged = false;

          // String timeString = '${_mealTime!.hour}:${_mealTime!.minute}';
          String timeString = mealTime!.format(context);

          Map<String, dynamic> newMeal = {
            'meal-time': timeString,
            'name': mealController,
            'vegetable1': selectedItem,
            'vegetable2': selectedItem2,
            'reminder-date': todayStr,
            'acknowledgment': acknowledged,
            'createdAt': today.toIso8601String(),
          };

          // Set/Update the meal directly as an object
          mealsByDay[selectedCategory] = newMeal;
          mealData[selectedDayCategory] = mealsByDay;

          await userDoc.set(mealData, SetOptions(merge: true));

          // setState(() {
          //   mealController.clear();
          //   selectedItem = dropdownItems.isNotEmpty ? dropdownItems.first : null;
          //   selectedItem2 =
          //       dropdownItemsVeg2.isNotEmpty ? dropdownItemsVeg2.first : null;
          // });

          Provider.of<MealPlannerProvider>(context, listen: false)
              .startMealPlanner(
              mealController,
              selectedCategory, // category
              selectedDayCategory, // day_category
              '0', // calories
              '0', // protein
              '0', // carbs
              '0', // fat
              '0', // fiber
              '0', // sugar
              '0', // sodium
              '0', // cholesterol
              '0', // vitaminA
              '0', // vitaminC
              '0', // calcium
              '0', // iron
              selectedItem!, // ingredients
              selectedItem2!, // instructions
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meal saved successfully!'),
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
          content: Text('Failed to save meal. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  static Future<void> checkAndResetAcknowledgedFlag(
      BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docSnapshot = await FirebaseFirestore.instance
        .collection('meal-planner')
        .doc(uid)
        .get();

    if (!docSnapshot.exists) return;

    final data = docSnapshot.data();
    if (data == null) return;

    final today = DateTime.now();
    final todayWeekday = DateFormat('EEEE').format(today); // e.g., "Monday"
    final todayMeals = data[todayWeekday]; // Access "Monday" block

    if (todayMeals == null || todayMeals is! Map<String, dynamic>) return;

    for (final mealType in todayMeals.keys) {
      final mealData = todayMeals[mealType];
      if (mealData is! Map<String, dynamic>) continue;

      final mealTimeStr = mealData['meal-time'] ?? "08:00";
      final acknowledged = mealData['acknowledged'] ?? false;
      // final reminderDate = mealData['reminder-date'];

      final mealTimeParts = mealTimeStr.split(":");
      final reminderTime = DateTime(
        today.year,
        today.month,
        today.day,
        int.tryParse((mealTimeParts.isNotEmpty ? mealTimeParts[0] : '0')) ?? 0,
        int.tryParse((mealTimeParts.length > 1 ? mealTimeParts[1] : '0')) ?? 0,
      );

      final hasTimePassed = DateTime.now().isAfter(reminderTime);

      if (acknowledged == true && hasTimePassed) {
        // Reset acknowledged flag only for this meal
        await FirebaseFirestore.instance
            .collection('meal-planner')
            .doc(uid)
            .update({
          "$todayWeekday.$mealType.acknowledged": false,
          "$todayWeekday.$mealType.reminder-date":
              DateFormat('yyyy-MM-dd').format(today),
        });

        // Optional: log or handle this case
        debugPrint("Reset acknowledged for $mealType on $todayWeekday");
      }

      // Schedule notification only if not acknowledged
      if (acknowledged == false) {
        final mealName = mealData['meal'] ?? '';
        final selectedItem = mealData['vegetable1'] ?? '';
        final selectedItem2 = mealData['vegetable2'] ?? '';
        final selectedCategory = mealData['name'] ?? "";
        final selectedDayCategory = mealData[todayWeekday] ?? "";
        final reminderTime = mealTimeStr ?? "08:00";
        bool acknowledge = false;

        Provider.of<MealPlannerProvider>(context, listen: false)
            .startMealPlanner(
            mealName,
            selectedCategory,
            selectedDayCategory,
            '0', // calories
            '0', // protein
            '0', // carbs
            '0', // fat
            '0', // fiber
            '0', // sugar
            '0', // sodium
            '0', // cholesterol
            '0', // vitaminA
            '0', // vitaminC
            '0', // calcium
            '0', // iron
            selectedItem, // ingredients
            selectedItem2, // instructions
        );
      }
    }
  }
}
