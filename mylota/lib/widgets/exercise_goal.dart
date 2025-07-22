import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mylota/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../controller/exercise_schedule_controller.dart';
import '../core/usecase/provider/exercise_timer_provider.dart';
import '../utils/styles.dart';
import 'custom_input_decorator.dart';

class ExerciseGoal extends StatefulWidget {
  const ExerciseGoal({super.key});

  @override
  _ExerciseGoalState createState() => _ExerciseGoalState();
}

class _ExerciseGoalState extends State<ExerciseGoal> with WidgetsBindingObserver {
  double _exerciseGoal = 0.0;
  bool isLoading = false;
  List<String> dropdownItems = [];
  String? selectedItem;

  void _startLoading() {
    if (mounted) setState(() => isLoading = true);
  }
  
  void _stopLoading() {
    if (mounted) setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchDropdownData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> fetchDropdownData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection("user-inputs")
          .doc("yQtkG0iE0dA0tcrQ8RAW")
          .get();

      if (docSnapshot.exists) {
        List<dynamic> data = docSnapshot["exercise-goal"];
        if (mounted) {
          setState(() {
            dropdownItems = List<String>.from(data);
            if (dropdownItems.isNotEmpty) {
              selectedItem = dropdownItems.first;
            }
          });
        }
      }
    } catch (e) {
      print("Error fetching dropdown data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch exercise options: $e")),
        );
      }
    }
  }

  // ✅ IMPROVED SAVE GOAL with proper mounted checks
  Future<void> _saveGoal(String? selectedItem, double exerciseGoal, BuildContext context) async {
    if (!mounted) return;
    
    if (selectedItem == null || exerciseGoal == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an exercise and set a goal first.')),
      );
      return;
    }

    _startLoading();
    
    try {
      // ✅ IMMEDIATELY UPDATE PROVIDER
      final timerProvider = Provider.of<ExerciseTimerProvider>(context, listen: false);
      timerProvider.setExerciseGoal(
        targetDuration: Duration(minutes: exerciseGoal.toInt()),
        exerciseType: selectedItem,
      );

      // Save to backend
      await ExerciseScheduleController.saveExerciseGoal(
        selectedItem,
        exerciseGoal,
        context,
        onStartLoading: _startLoading,
        onStopLoading: _stopLoading,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Exercise goal saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving exercise goal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _stopLoading();
    }
  }

  // ✅ IMPROVED TOGGLE with better state management
  Future<void> _toggleExercise(BuildContext context) async {
    if (!mounted) return;
    
    final timerProvider = Provider.of<ExerciseTimerProvider>(context, listen: false);

    print('🔍 Button pressed - Current state:');
    print('   isRunning: ${timerProvider.isRunning}');
    print('   hasProgress: ${timerProvider.duration.inSeconds}s');
    print('   totalDuration: ${timerProvider.totalDuration.inSeconds}s');
    print('   isCompleted: ${timerProvider.isCompleted}');
    print('   hasActiveTimer: ${timerProvider.hasActiveTimer}');

    // PAUSE if currently running
    if (timerProvider.isRunning) {
      print('🔍 Action: Pausing exercise');
      timerProvider.pauseExercise();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏸️ Exercise paused'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    // Check if we have a goal set
    if (timerProvider.totalDuration.inSeconds == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Please save your exercise goal first'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Check if exercise is already completed
    if (timerProvider.isCompleted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Exercise already completed!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return;
    }

    // RESUME if there's progress but not running
    if (timerProvider.duration.inSeconds > 0) {
      print('🔍 Action: Resuming exercise from ${timerProvider.duration.inSeconds}s');
      timerProvider.resumeExercise();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('▶️ Exercise resumed'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    // START NEW EXERCISE
    print('🔍 Action: Starting new exercise');
    try {
      // Start background service if available
      try {
        final service = FlutterBackgroundService();
        await service.startService();
      } catch (e) {
        print('⚠️ Background service not available: $e');
      }
      
      timerProvider.startExercise(
        targetDuration: timerProvider.totalDuration,
        exerciseType: timerProvider.exerciseType,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🏃‍♂️ Exercise started!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('❌ Error starting exercise: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set Your Exercise Goal', style: AppStyle.cardfooter),
          const SizedBox(height: 10),
          
          // Dropdown
          DropdownButtonFormField<String>(
            value: selectedItem,
            items: dropdownItems.map<DropdownMenuItem<String>>((exercise) {
              return DropdownMenuItem<String>(
                value: exercise,
                child: Text(exercise, style: AppStyle.cardfooter.copyWith(fontSize: 12)),
              );
            }).toList(),
            onChanged: (value) {
              if (mounted) setState(() => selectedItem = value);
            },
            decoration: customInputDecoration(
              labelText: 'Choose Exercise',
              hintText: 'Choose a exercise',
              prefixIcon: const Icon(Icons.run_circle_outlined, color: Colors.green),
            ),
          ),
          
          const SizedBox(height: 20),
          Text('Set your daily goal (minutes):', style: AppStyle.cardfooter),
          const SizedBox(height: 10),
          
          // Slider
          Slider(
            value: _exerciseGoal,
            min: 0,
            max: 120,
            divisions: 12,
            activeColor: const Color(0xFF66C3A7),
            thumbColor: const Color(0xFF2A7F67),
            label: '${_exerciseGoal.round()} mins',
            onChanged: (value) {
              if (mounted) setState(() => _exerciseGoal = value);
            },
          ),
          
          Center(
            child: Text("${_exerciseGoal.toInt()} min", style: AppStyle.cardfooter),
          ),
          const SizedBox(height: 20),
          
          // Buttons
          isLoading
              ? const CustomContainerLoadingButton()
              : Center(
                  child: Column(
                    children: [
                      // Save Goal Button
                      CustomPrimaryButton(
                        label: 'Save Goal',
                        onPressed: () => _saveGoal(selectedItem, _exerciseGoal, context),
                      ),
                      const SizedBox(height: 16),
                      
                      // ✅ IMPROVED PLAY/PAUSE BUTTON with debug info
                      Consumer<ExerciseTimerProvider>(
                        builder: (context, provider, child) {
                          // ✅ SIMPLE STATE CHECK
                          final hasGoal = provider.totalDuration.inSeconds > 0;
                          final isRunning = provider.isRunning;
                          final isCompleted = provider.isCompleted;
                          final hasProgress = provider.duration.inSeconds > 0;
                          
                          String buttonText;
                          IconData buttonIcon;
                          Color buttonColor;
                          VoidCallback? onPressed;
                          
                          if (!hasGoal) {
                            buttonText = 'Set goal first';
                            buttonIcon = Icons.warning;
                            buttonColor = Colors.grey;
                            onPressed = null;
                          } else if (isCompleted) {
                            buttonText = 'Completed!';
                            buttonIcon = Icons.check_circle;
                            buttonColor = Colors.green;
                            onPressed = null;
                          } else if (isRunning) {
                            buttonText = 'Pause';
                            buttonIcon = Icons.pause_circle_filled;
                            buttonColor = Colors.orange;
                            onPressed = () {
                              provider.pauseExercise();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('⏸️ Paused')),
                              );
                            };
                          } else if (hasProgress) {
                            buttonText = 'Resume';
                            buttonIcon = Icons.play_circle_filled;
                            buttonColor = Colors.green;
                            onPressed = () {
                              provider.resumeExercise();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('▶️ Resumed')),
                              );
                            };
                          } else {
                            buttonText = 'Start';
                            buttonIcon = Icons.play_circle_filled;
                            buttonColor = Colors.green;
                            onPressed = () {
                              provider.startExercise(
                                targetDuration: provider.totalDuration,
                                exerciseType: provider.exerciseType,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('🏃‍♂️ Started!')),
                              );
                            };
                          }
                          
                          return Column(
                            children: [
                              // ✅ LIVE TIMER DISPLAY
                              if (hasGoal) ...[
                                Text(
                                  provider.formattedDuration,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isRunning ? Colors.green : Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  '${provider.exerciseType} • ${(provider.progress * 100).toInt()}%',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                              ],
                              
                              // ✅ SIMPLE BUTTON
                              ElevatedButton.icon(
                                onPressed: onPressed,
                                icon: Icon(buttonIcon, color: Colors.white),
                                label: Text(buttonText),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                              
                              // ✅ DEBUG INFO (remove in production)
                              // if (hasGoal) ...[
                              //   SizedBox(height: 8),
                              //   Text(
                              //     'Debug: ${provider.duration.inSeconds}s / ${provider.totalDuration.inSeconds}s',
                              //     style: const TextStyle(fontSize: 10, color: Colors.red),
                              //   ),
                              // ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
