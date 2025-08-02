import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/notification_service.dart';

class MealPlannerProvider with ChangeNotifier {
  double _mealProgress = 0.0;
  List<Map<String, dynamic>> _todaysMeals = [];
  int _completedMeals = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _plannedMeals = [];
  
  // Getters
  double get mealProgress => _mealProgress;
  List<Map<String, dynamic>> get todaysMeals => _todaysMeals;
  int get completedMeals => _completedMeals;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get plannedMeals => _plannedMeals;
  
  // Constructor
  MealPlannerProvider() {
    print('✅ MealPlannerProvider created');
  }
  
  // Initialize method
  Future<void> initialize() async {
    try {
      print('🔄 Initializing MealPlannerProvider...');
      await loadTodaysMeals();
      await loadMealProgress();
      await loadPlannedMeals();
      print('✅ MealPlannerProvider initialized');
    } catch (e) {
      print('❌ Error initializing MealPlannerProvider: $e');
    }
  }
  
  // ✅ ADD THE MISSING startMealPlanner METHOD
  Future<void> startMealPlanner(
    String mealName,
    String selectedCategory,
    String selectedDayCategory,
    String calories,
    String protein,
    String carbs,
    String fat,
    String fiber,
    String sugar,
    String sodium,
    String cholesterol,
    String vitaminA,
    String vitaminC,
    String calcium,
    String iron,
    String ingredients,
    String instructions,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No authenticated user for meal planner');
        return;
      }
      
      final mealData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': mealName,
        'category': selectedCategory,
        'day_category': selectedDayCategory,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'sugar': sugar,
        'sodium': sodium,
        'cholesterol': cholesterol,
        'vitamin_a': vitaminA,
        'vitamin_c': vitaminC,
        'calcium': calcium,
        'iron': iron,
        'ingredients': ingredients,
        'instructions': instructions,
        'created_at': FieldValue.serverTimestamp(),
        'completed': false,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };
      
      // Add to local planned meals
      _plannedMeals.add(mealData);
      
      // Add to today's meals if it's for today
      if (selectedDayCategory.toLowerCase() == 'today' || 
          selectedDayCategory.toLowerCase() == DateFormat('EEEE').format(DateTime.now()).toLowerCase()) {
        _todaysMeals.add(mealData);
        _calculateMealProgress();
      }
      
      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('meal-planner')
          .doc(user.uid)
          .collection('planned-meals')
          .doc(mealData['id'] as String?)
          .set(mealData);
      
      // Update daily meals collection
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await FirebaseFirestore.instance
          .collection('meal-planner')
          .doc(user.uid)
          .collection('daily-meals')
          .doc(today)
          .set({
        'meals': _todaysMeals,
        'date': today,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('✅ Meal planner started successfully: $mealName');
      
    } catch (e) {
      print('❌ Error starting meal planner: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // // ✅ ADD OVERLOADED startMealPlanner METHOD (for simpler calls)
  // Future<void> startMealPlanner(String mealName, String selectedCategory, String selectedDayCategory) async {
  //   await startMealPlanner(
  //     mealName,
  //     selectedCategory,
  //     selectedDayCategory,
  //     '0', // calories
  //     '0', // protein
  //     '0', // carbs
  //     '0', // fat
  //     '0', // fiber
  //     '0', // sugar
  //     '0', // sodium
  //     '0', // cholesterol
  //     '0', // vitaminA
  //     '0', // vitaminC
  //     '0', // calcium
  //     '0', // iron
  //     '', // ingredients
  //     '', // instructions
  //   );
  // }
  
  // ✅ Load planned meals
  Future<void> loadPlannedMeals() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('meal-planner')
          .doc(user.uid)
          .collection('planned-meals')
          .orderBy('created_at', descending: true)
          .get();
      
      _plannedMeals = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      print('✅ Planned meals loaded: ${_plannedMeals.length} meals');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading planned meals: $e');
    }
  }
  
  // ✅ Calculate meal progress
  void _calculateMealProgress() {
    _completedMeals = _todaysMeals.where((meal) => meal['completed'] == true).length;
    _mealProgress = _todaysMeals.isNotEmpty ? (_completedMeals / _todaysMeals.length) : 0.0;
  }
  
  // Mark meal as done for today (for compatibility with notification system)
  Future<void> markMealAsDoneForToday(String mealType) async {
    try {
      print('🍽️ Marking meal as done: $mealType');
      
      // Find meal by type and mark as completed
      for (var meal in _todaysMeals) {
        if (meal['type']?.toLowerCase() == mealType.toLowerCase() ||
            meal['category']?.toLowerCase() == mealType.toLowerCase()) {
          await updateMealCompletion(meal['id'] ?? meal['name'] ?? mealType, true);
          break;
        }
      }
    } catch (e) {
      print('❌ Error marking meal as done: $e');
    }
  }
  
  // Update meal completion
  Future<void> updateMealCompletion(String mealId, bool isCompleted) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('⚠️ No authenticated user for meal update');
        return;
      }
      
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Update local state
      for (var meal in _todaysMeals) {
        if (meal['id'] == mealId || meal['name'] == mealId) {
          meal['completed'] = isCompleted;
          break;
        }
      }
      
      // Update planned meals too
      for (var meal in _plannedMeals) {
        if (meal['id'] == mealId || meal['name'] == mealId) {
          meal['completed'] = isCompleted;
          break;
        }
      }
      
      // Recalculate progress
      _calculateMealProgress();
      
      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('meal-planner')
          .doc(user.uid)
          .collection('daily-progress')
          .doc(today)
          .set({
        'meals': _todaysMeals,
        'completed_meals': _completedMeals,
        'total_meals': _todaysMeals.length,
        'progress': _mealProgress,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Update the specific meal in planned meals
      if (_plannedMeals.any((meal) => meal['id'] == mealId)) {
        await FirebaseFirestore.instance
            .collection('meal-planner')
            .doc(user.uid)
            .collection('planned-meals')
            .doc(mealId)
            .update({'completed': isCompleted});
      }
      
      print('✅ Meal progress updated: ${(_mealProgress * 100).toStringAsFixed(1)}%');
      
    } catch (e) {
      print('❌ Error updating meal completion: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load meal progress
  Future<void> loadMealProgress() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      final doc = await FirebaseFirestore.instance
          .collection('meal-planner')
          .doc(user.uid)
          .collection('daily-progress')
          .doc(today)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        _todaysMeals = List<Map<String, dynamic>>.from(data['meals'] ?? []);
        _completedMeals = data['completed_meals'] ?? 0;
        _mealProgress = data['progress']?.toDouble() ?? 0.0;
        
        print('✅ Meal progress loaded: ${(_mealProgress * 100).toStringAsFixed(1)}%');
      } else {
        print('ℹ️ No meal progress found for today');
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error loading meal progress: $e');
    }
  }
  
  // Load today's meals
  Future<void> loadTodaysMeals() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      final doc = await FirebaseFirestore.instance
          .collection('meal-planner')
          .doc(user.uid)
          .collection('daily-meals')
          .doc(today)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        _todaysMeals = List<Map<String, dynamic>>.from(data['meals'] ?? []);
        _calculateMealProgress();
        
        print('✅ Today\'s meals loaded: ${_todaysMeals.length} meals');
      } else {
        // Create default meals if none exist
        _todaysMeals = [
          {
            'id': 'breakfast',
            'name': 'Breakfast',
            'category': 'breakfast',
            'type': 'breakfast',
            'completed': false,
            'date': today,
          },
          {
            'id': 'lunch',
            'name': 'Lunch',
            'category': 'lunch',
            'type': 'lunch',
            'completed': false,
            'date': today,
          },
          {
            'id': 'dinner',
            'name': 'Dinner',
            'category': 'dinner',
            'type': 'dinner',
            'completed': false,
            'date': today,
          },
        ];
        print('ℹ️ Created default meals for today');
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error loading today\'s meals: $e');
    }
  }
  
  // Get meal progress data
  Map<String, dynamic> getMealProgressData() {
    return {
      'progress': _mealProgress,
      'completed_meals': _completedMeals,
      'total_meals': _todaysMeals.length,
      'progress_percentage': (_mealProgress * 100).toStringAsFixed(1),
      'is_loading': _isLoading,
    };
  }
  
  // ✅ Add method to get meal by ID
  Map<String, dynamic>? getMealById(String mealId) {
    try {
      return _plannedMeals.firstWhere((meal) => meal['id'] == mealId);
    } catch (e) {
      return null;
    }
  }
  
  // ✅ Add method to delete meal
  Future<void> deleteMeal(String mealId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // Remove from local lists
      _plannedMeals.removeWhere((meal) => meal['id'] == mealId);
      _todaysMeals.removeWhere((meal) => meal['id'] == mealId);
      
      // Recalculate progress
      _calculateMealProgress();
      
      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('meal-planner')
          .doc(user.uid)
          .collection('planned-meals')
          .doc(mealId)
          .delete();
      
      print('✅ Meal deleted: $mealId');
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting meal: $e');
    }
  }
  
  // Reset meal progress
  void resetMealProgress() {
    _mealProgress = 0.0;
    _completedMeals = 0;
    _todaysMeals.clear();
    _plannedMeals.clear();
    _isLoading = false;
    
    notifyListeners();
    print('🔄 Meal progress reset');
  }
}
