import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mylota/core/usecase/provider/meal_planner_provider.dart';
import 'package:provider/provider.dart';

class MealPlannerController {
  static Future<void> saveMeals({
    required BuildContext context,
    required String mealController,
    required String selectedCategory,
    required String selectedDayCategory,
    TimeOfDay? mealTime,
    String? selectedItem,
    String? selectedItem2,
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
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in!");
        return;
      }

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
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
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

      Provider.of<MealPlannerProvider>(context, listen: false).startMealPlanner(
          mealController,
          // selectedCategory,
          // selectedDayCategory,
          mealTime.format(context),
          selectedItem,
          selectedItem2,
          acknowledged);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error saving meal: $e");
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
    if (uid == null) {
      print("User not logged in.");
      return;
    }

    final docSnapshot = await FirebaseFirestore.instance
        .collection('meal-planner')
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      final bool isAcknowledged = data?['acknowledged'] ?? false;
      final String lastAcknowledgedDate = data?['reminder-date'] ?? '';

      final today = DateTime.now();
      final todayStr =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // Check if today is a new day and acknowledgment is already done
      if (isAcknowledged && lastAcknowledgedDate != todayStr) {
        // Reset acknowledged status
        await FirebaseFirestore.instance
            .collection('meal-planner')
            .doc(uid)
            .update({
          'acknowledged': false, // Reset acknowledged for new day
          'reminder-date': todayStr, // Update today's date
        });

        // Reschedule the reminder for today
        final reminderTime = data?['meal-time'] ?? "08:00"; // Get reminder time from Firestore
        final meal = data?['name'] ?? "";
        // final selectedCategory = data?[''] ?? "";
        // final selectedDayCategory = data?[''] ?? "";
        final selectedItem = data?['vegetable1'] ?? "";
        final selectedItem2 = data?['vegetable2'] ?? "";

        Provider.of<MealPlannerProvider>(context, listen: false)
            .startMealPlanner(
                meal,
                selectedCategory,
                selectedDayCategory,
                // reminderTime,
                // selectedItem,
                selectedItem2,
                false); // false indicates new day reminder
      }
    }
  }
}
