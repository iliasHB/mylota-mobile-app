import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mylota/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/meal_planner_controller.dart';
import '../core/common/constant.dart';
import '../utils/styles.dart';
import 'custom_input_decorator.dart';

class MealPlanner extends StatefulWidget {
  const MealPlanner({super.key});

  @override
  _MealPlannerState createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _mealTimeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Selected category and vegetables
  String _selectedCategory = 'Breakfast';
  String _selectedDayCategory = 'Monday';

  List<String> dropdownItems = [];
  String? selectedItem;
  List<String> dropdownItemsVeg2 = [];
  String? selectedItem2;

  bool isLoading = false;
  void _startLoading() => setState(() => isLoading = true);
  void _stopLoading() => setState(() => isLoading = false);
  @override
  void initState() {
    super.initState();
    fetchDropdownDataVeg1();
  }

  Future<void> fetchDropdownDataVeg1() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection("user-inputs")
          .doc("yQtkG0iE0dA0tcrQ8RAW") // Replace with your document ID
          .get();

      if (docSnapshot.exists) {
        List<dynamic> data = docSnapshot["vegetable1"] ?? [];
        List<dynamic> data2 = docSnapshot["vegatable-2"] ?? [];
        setState(() {
          dropdownItems = List<String>.from(data);
          dropdownItemsVeg2 = List<String>.from(data2);
          if (dropdownItems.isNotEmpty) {
            selectedItem = dropdownItems.first; // Default selection
          }
          if (dropdownItemsVeg2.isNotEmpty) {
            selectedItem2 = dropdownItemsVeg2.first; // Default selection
          }
        });
      } else {
        print("Document does not exist.");
      }
    } catch (e) {
      print("Error fetching dropdown data: $e");
    }
  }

  TimeOfDay? _mealTime;

  Future<void> _pickTime(BuildContext context, bool isMealTime) async {
    final pickedTime = await showTimePicker(
        context: context,
        initialTime: (_mealTime ?? TimeOfDay(hour: 22, minute: 0))
        // isMealTime
        //     ? (_mealTime ?? TimeOfDay(hour: 22, minute: 0))
        //     : (_wakeTime ?? TimeOfDay(hour: 6, minute: 0)),
        );

    if (pickedTime != null) {
      setState(() {
        // if (isMealTime) {
        _mealTime = pickedTime;
        // } else {
        //   _wakeTime = pickedTime;
        // }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
                value: _selectedDayCategory,
                items: Constant.days.entries
                    .map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category.value,
                    child: Text(
                      category.value,
                      style: AppStyle.cardfooter.copyWith(fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDayCategory = value!;
                  });
                },
                decoration: customInputDecoration(
                  labelText: 'Day of the week',
                  hintText: '',
                  prefixIcon:
                      const Icon(Icons.today_sharp, color: Colors.green),
                )),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: Constant.meals.entries
                    .map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category.value,
                    child: Text(
                      category.value,
                      style: AppStyle.cardfooter.copyWith(fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: customInputDecoration(
                  labelText: 'Select Meal Period',
                  hintText: '',
                  prefixIcon: const Icon(Icons.timelapse, color: Colors.green),
                )),

            const SizedBox(height: 10),

            // Meal input field
            TextFormField(
              controller: _mealTimeController,
              readOnly: true,
              decoration: InputDecoration(
                // enabled: isDisable,
                prefixIcon: const Icon(Icons.access_time, color: Colors.green),
                filled: true,
                fillColor: Color(0xFF2A7F67).withOpacity(0.3),
                //labelStyle: AppStyle.cardfooter.copyWith(fontSize: 12),
                hintStyle: AppStyle.cardfooter.copyWith(
                  fontSize: 12,
                ),
                hintText: _mealTime == null
                    ? 'Set meal time'
                    : 'Meal time: ${_mealTime!.format(context)}',
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(5)),
              ),
              onTap: () => _pickTime(context, true),
            ),
            const SizedBox(height: 10),
            // Meal input field
            TextFormField(
                controller: _mealController,
                // obscureText: true,
                decoration: customInputDecoration(
                  labelText: 'Enter meal',
                  hintText: 'e.g. Rice, Chicken',
                  prefixIcon:
                      const Icon(Icons.restaurant_menu, color: Colors.green),
                )),
            // TextFormField(
            //   controller: _mealController,
            //   decoration: const InputDecoration(
            //     labelText: 'Enter your meal (e.g., Rice, Chicken)',
            //     border: OutlineInputBorder(),
            //   ),
            //   validator: (value) {
            //     if (value!.isEmpty || value == "") {
            //       return "Meal can not be empty";
            //     }
            //     return null;
            //   },
            // ),
            const SizedBox(height: 10),

            // Vegetable color dropdown 1

            DropdownButtonFormField<String>(
              value: selectedItem,
              items: dropdownItems.isNotEmpty
                  ? dropdownItems.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          style: AppStyle.cardfooter.copyWith(fontSize: 12),
                        ),
                      );
                    }).toList()
                  : null,
              onChanged: dropdownItems.isNotEmpty
                  ? (value) {
                      setState(() {
                        selectedItem = value!;
                      });
                    }
                  : null,
              decoration: customInputDecoration(
                labelText: 'Select vegetable 1',
                hintText: dropdownItems.isNotEmpty
                    ? 'Choose first veges'
                    : 'No options available',
                prefixIcon: const Icon(Icons.set_meal, color: Colors.green),
              ),
            ),

            const SizedBox(height: 10),

            // Category dropdown
            DropdownButtonFormField<String>(
                value: selectedItem2,
                items: dropdownItemsVeg2.map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: AppStyle.cardfooter.copyWith(fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedItem2 = value!;
                  });
                },
                decoration: customInputDecoration(
                  labelText: 'Select vegetable 2',
                  hintText: 'Choose second veges',
                  prefixIcon: const Icon(Icons.set_meal, color: Colors.green),
                )),
            const SizedBox(height: 20),

            // Add meal button
            Center(
                child: isLoading
                    ? const CustomContainerLoadingButton()
                    : CustomPrimaryButton(
                        label: 'Add Meal',
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _saveMeals();
                          }
                        }, )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _saveMeals() {
    MealPlannerController.saveMeals(
        context: context,
        mealController: _mealController.text.trim(),
        selectedCategory: _selectedCategory,
        selectedDayCategory: _selectedDayCategory,
        mealTime: _mealTime,
        selectedItem: selectedItem,
        selectedItem2: selectedItem2,
        onStartLoading: _startLoading,
        onStopLoading: _stopLoading
    );
  }
}
