import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mylota/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/styles.dart';
import 'custom_input_decorator.dart';

class MealPlanner extends StatefulWidget {
  @override
  _MealPlannerState createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _mealTimeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // Meal categories
  Map<String, String> meals = {
    'Morning': 'Breakfast',
    'Afternoon': 'Lunch',
    'Evening': 'Dinner',
  };


  Map<String, String> days = {
    'day 1': 'Sunday',
    'day 2': 'Monday',
    'day 3': 'Tuesday',
    'day 4': 'Wednesday',
    'day 5': 'Thursday',
    'day 6': 'Friday',
    'day 7': 'Saturday',
  };

  // Selected category and vegetables
  String _selectedCategory = 'Breakfast';
  String _selectedDayCategory = 'Monday';

  List<String> dropdownItems = [];
  String? selectedItem;
  List<String> dropdownItemsVeg2 = [];
  String? selectedItem2;
  @override
  void initState() {
    super.initState();
    fetchDropdownDataVeg1();
  }

  Future<void> fetchDropdownDataVeg1() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection("user-inputs")
          .doc("yQtkG0iE0dA0tcrQ8RAW") // Change this to your document ID
          .get();

      if (docSnapshot.exists) {
        List<dynamic> data = docSnapshot["vegetable1"];
        setState(() {
          dropdownItems = List<String>.from(data);
          dropdownItemsVeg2 = List<String>.from(data);
          if (dropdownItems.isNotEmpty) {
            selectedItem = dropdownItems.first; // Default selection
          }
          if (dropdownItemsVeg2.isNotEmpty) {
            selectedItem2 = dropdownItemsVeg2.first; // Default selection
          }
        });
      }
    } catch (e) {
      print("Error fetching dropdown data: $e");
    }
  }


  // Future<void> _saveMeals() async {
  //   if (_mealController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Meal name cannot be empty!'),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   try {
  //     // Get current user ID
  //     User? user = FirebaseAuth.instance.currentUser;
  //     if (user == null) {
  //       print("User not logged in!");
  //       return;
  //     }
  //
  //     // Firestore document reference
  //     DocumentReference userDoc = FirebaseFirestore.instance
  //         .collection('meal-planner')
  //         .doc(user.uid);
  //
  //     // Fetch existing meals data
  //     DocumentSnapshot docSnapshot = await userDoc.get();
  //     Map<String, dynamic> mealData = {};
  //
  //     if (docSnapshot.exists && docSnapshot.data() != null) {
  //       mealData = docSnapshot.data() as Map<String, dynamic>;
  //     }
  //
  //     // Ensure categories exist in Firestore
  //     Map<String, dynamic> mealsByCategory = mealData[_selectedDayCategory] ?? {};
  //     String timeString = '${_mealTime!.hour}:${_mealTime!.minute}';
  //
  //     // Create new meal object
  //     Map<String, dynamic> newMeal = {
  //       'meal-time': timeString,//_mealTime,
  //       'name': _mealController.text,
  //       'vegetable1': selectedItem,
  //       'vegetable2': selectedItem2,
  //       'createdAt': DateTime.now().toIso8601String(),
  //     };
  //
  //     // Check if category exists and update or add a meal
  //     if (mealsByCategory.containsKey(_selectedDayCategory) && mealsByCategory.containsKey(_selectedCategory)) {
  //       print('category is: ${_selectedDayCategory}');
  //       print('category is: ${_selectedCategory}');
  //       // Update existing category (append new meal)
  //       mealsByCategory[_selectedCategory].add(newMeal);
  //     } else {
  //       // Create new category and add meal
  //       mealsByCategory[_selectedCategory] = [newMeal];
  //     }
  //
  //     // Save updated data back to Firestore
  //     await userDoc.set({_selectedDayCategory: mealsByCategory});
  //
  //     // Save to SharedPreferences for local storage
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     // await prefs.setString('savedMeals', jsonEncode(mealsByCategory));
  //
  //     // Reset input fields
  //     setState(() {
  //       _mealController.clear();
  //       selectedItem = dropdownItems.isNotEmpty ? dropdownItems.first : null;
  //       selectedItem2 = dropdownItemsVeg2.isNotEmpty ? dropdownItemsVeg2.first : null;
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Meal saved successfully!'),
  //         backgroundColor: Colors.green,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   } catch (e) {
  //     print("Error saving meal: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Failed to save meal. Please try again.'),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }

  TimeOfDay? _mealTime;
  // TimeOfDay? _wakeTime;

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
            // Title
            // Row(
            //   children: [
            //     Icon(Icons.restaurant_menu, color: Colors.green, size: 28),
            //     SizedBox(width: 10),
            //     Text(
            //       'Meal Planner',
            //       style: AppStyle.cardSubtitle
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 20),

            // Category dropdown
            DropdownButtonFormField<String>(
                value: _selectedDayCategory,
                items: days.entries.map<DropdownMenuItem<String>>((category) {
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
                items: meals.entries.map<DropdownMenuItem<String>>((category) {
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
                  prefixIcon:
                  const Icon(Icons.timelapse, color: Colors.green),
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
                  hintStyle:  AppStyle.cardfooter.copyWith(fontSize: 12,),
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
                  prefixIcon: const Icon(Icons.restaurant_menu, color: Colors.green),
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
                items: dropdownItems.map<DropdownMenuItem<String>>((category) {
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
                    selectedItem = value!;
                  });
                },
                decoration: customInputDecoration(
                  labelText: 'Select vegetable 1',
                  hintText: 'Choose second veges',
                  prefixIcon:
                  const Icon(Icons.set_meal, color: Colors.green),
                )),

            // DropdownButtonFormField<String>(
            //   decoration: customInputDecoration(
            //     labelText: 'Select a first veges color',
            //     hintText: 'Choose a veges',
            //     prefixIcon:
            //     const Icon(Icons.warehouse, color: Colors.green),
            //   ),
            //   value: selectedItem,
            //   items: dropdownItems.map((exercise) {
            //     return DropdownMenuItem<String>(
            //       value: exercise,
            //       child: Row(
            //         children: [
            //           const SizedBox(width: 10),
            //           Text(exercise),
            //         ],
            //       ),
            //     );
            //   }).toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       selectedItem = value!;
            //     });
            //   },
            // ),
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
                  prefixIcon:
                  const Icon(Icons.set_meal, color: Colors.green),
                )),

            // DropdownButtonFormField<String>(
            //   decoration: const InputDecoration(
            //     border: OutlineInputBorder(),
            //     labelText: 'Choose second veges color',
            //   ),
            //   value: selectedItem2,
            //   items: dropdownItemsVeg2.map((exercise) {
            //     return DropdownMenuItem<String>(
            //       value: exercise,
            //       child: Row(
            //         children: [
            //           const SizedBox(width: 10),
            //           Text(exercise),
            //         ],
            //       ),
            //     );
            //   }).toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       selectedItem2 = value!;
            //     });
            //   },
            // ),
            const SizedBox(height: 20),

            // Add meal button
            Center(
              child: CustomPrimaryButton(
                  label: 'Add Meal',
                  onPressed: (){
                    // uploadNationalitiesToFirestore();
                      if (_formKey.currentState?.validate() ?? false) {
                        _saveMeals();
                      }
                  })
              // ElevatedButton(
              //   onPressed: () {
              //     if (_formKey.currentState?.validate() ?? false) {
              //       _saveMeals();
              //     }
              //   },
              //   child: const Text('Add Meal'),
              //   style: ElevatedButton.styleFrom(
              //       padding: const EdgeInsets.symmetric(
              //           horizontal: 30, vertical: 15),
              //       shadowColor: Colors.grey),
              // ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Future<void> _saveMeals() async {
  //   if (_mealController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Meal name cannot be empty!'),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   try {
  //     User? user = FirebaseAuth.instance.currentUser;
  //     if (user == null) {
  //       print("User not logged in!");
  //       return;
  //     }
  //
  //     DocumentReference userDoc = FirebaseFirestore.instance
  //         .collection('meal-planner')
  //         .doc(user.uid);
  //
  //     DocumentSnapshot docSnapshot = await userDoc.get();
  //     Map<String, dynamic> mealData = {};
  //
  //     if (docSnapshot.exists && docSnapshot.data() != null) {
  //       mealData = docSnapshot.data() as Map<String, dynamic>;
  //     }
  //
  //     Map<String, dynamic> mealsByDay = mealData[_selectedDayCategory] ?? {};
  //     List<dynamic> mealList = mealsByDay[_selectedCategory] ?? [];
  //
  //     if(!mealList.isEmpty){
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Meal already exist'),
  //           backgroundColor: Colors.black,
  //           duration: Duration(seconds: 2),
  //         ),
  //       );
  //       return;
  //     }
  //
  //     String timeString = '${_mealTime!.hour}:${_mealTime!.minute}';
  //
  //     Map<String, dynamic> newMeal = {
  //       'meal-time': timeString,
  //       'name': _mealController.text,
  //       'vegetable1': selectedItem,
  //       'vegetable2': selectedItem2,
  //       'createdAt': DateTime.now().toIso8601String(),
  //     };
  //
  //     // Check if a similar meal already exists (by name or meal-time)
  //     // int existingIndex = mealList.indexWhere((meal) =>
  //     // meal['name'] == newMeal['name'] &&
  //     //     meal['meal-time'] == newMeal['meal-time']);
  //     // // meal['name'] == newMeal['name'] &&
  //     // //     meal['meal-time'] == newMeal['meal-time']);
  //     //
  //     // if (existingIndex != -1) {
  //     //   // Update the existing meal
  //     //   // mealList[existingIndex] = newMeal;
  //     //   print("Meal updated.");
  //     // } else {
  //     //   // Add new meal
  //     //   mealList.add(newMeal);
  //     //   print("Meal added.");
  //     // }
  //
  //     // Assign updated meal list back
  //     mealsByDay[_selectedCategory] = mealList;
  //     mealData[_selectedDayCategory] = mealsByDay;
  //
  //     await userDoc.set(mealData, SetOptions(merge: true));
  //
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     // await prefs.setString('savedMeals', jsonEncode(mealsByDay));
  //
  //     setState(() {
  //       _mealController.clear();
  //       selectedItem = dropdownItems.isNotEmpty ? dropdownItems.first : null;
  //       selectedItem2 = dropdownItemsVeg2.isNotEmpty ? dropdownItemsVeg2.first : null;
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Meal saved successfully!'),
  //         backgroundColor: Colors.green,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   } catch (e) {
  //     print("Error saving meal: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Failed to save meal. Please try again.'),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }

  Future<void> _saveMeals() async {
    if (_mealController.text.isEmpty) {
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

      DocumentReference userDoc = FirebaseFirestore.instance
          .collection('meal-planner')
          .doc(user.uid);

      DocumentSnapshot docSnapshot = await userDoc.get();
      Map<String, dynamic> mealData = {};

      if (docSnapshot.exists && docSnapshot.data() != null) {
        mealData = docSnapshot.data() as Map<String, dynamic>;
      }

      Map<String, dynamic> mealsByDay = mealData[_selectedDayCategory] ?? {};

      // Check if meal already exists for the category (e.g., Breakfast, Lunch, etc.)
      if (mealsByDay.containsKey(_selectedCategory)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal already exists for this time. Updating...'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // String timeString = '${_mealTime!.hour}:${_mealTime!.minute}';
      String timeString = _mealTime!.format(context);

      Map<String, dynamic> newMeal = {
        'meal-time': timeString,
        'name': _mealController.text,
        'vegetable1': selectedItem,
        'vegetable2': selectedItem2,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Set/Update the meal directly as an object
      mealsByDay[_selectedCategory] = newMeal;
      mealData[_selectedDayCategory] = mealsByDay;

      await userDoc.set(mealData, SetOptions(merge: true));

      setState(() {
        _mealController.clear();
        selectedItem = dropdownItems.isNotEmpty ? dropdownItems.first : null;
        selectedItem2 = dropdownItemsVeg2.isNotEmpty ? dropdownItemsVeg2.first : null;
      });

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

}




// // Add a new meal with vegetable validation
// void _addMeal() {
//   if (_mealController.text.isNotEmpty &&
//       _selectedVegetable1 != null &&
//       _selectedVegetable2 != null &&
//       _selectedVegetable1 != _selectedVegetable2) {
//     setState(() {
//       meals[_selectedCategory]?.add(
//           '${_mealController.text} (with $_selectedVegetable1 and $_selectedVegetable2)');
//       _mealController.clear();
//       _selectedVegetable1 = null;
//       _selectedVegetable2 = null;
//       _saveMeals();
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Meal added successfully!'),
//         backgroundColor: Colors.green,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content:
//             Text('Please include at least 2 different colors of vegetables.'),
//         backgroundColor: Colors.red,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
// }
///

// // Remove a meal from the list
// void _removeMeal(String category, int index) {
//   setState(() {
//     meals[category]?.removeAt(index);
//     _saveMeals();
//   });
// }
///

// // Meal list with delete option
// meals.isEmpty
//     ? const Center(
//   child: Text(
//     'No meals planned yet. Add one!',
//     style: TextStyle(color: Colors.grey),
//   ),
// )
//     : ListView(
//   shrinkWrap: true,
//   physics: const NeverScrollableScrollPhysics(),
//   children: meals.entries.map((entry) {
//     String category = entry.key;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           category,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         const SizedBox(height: 10),
// ListView.builder(
//   shrinkWrap: true,
//   physics: const NeverScrollableScrollPhysics(),
//   itemCount: entry.value.length,
//   itemBuilder: (context, index) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 5),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: ListTile(
//         title: Text(entry.value[index]),
//         trailing: IconButton(
//           icon: const Icon(Icons.delete, color: Colors.red),
//           onPressed: () =>
//               _removeMeal(category, index),
//         ),
//       ),
//     );
//   },
// ),
//     ],
//   );
// }).toList(),
// ),
