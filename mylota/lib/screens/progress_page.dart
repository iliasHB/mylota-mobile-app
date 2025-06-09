import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mylota/utils/styles.dart';
import 'package:provider/provider.dart';
import '../core/usecase/provider/exercise_timer_provider.dart';
import '../core/usecase/provider/sleep_timer_provider.dart';
import '../widgets/more_meal_schedule.dart';
import '../widgets/more_todos.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProgressPage extends StatefulWidget {
  final double exerciseGoal;
  final double sleepGoal;
  // final double waterIntakeGoal;
  // final List<String> todoList;
  // final List<String> meals;

  const ProgressPage({
    Key? key,
    required this.exerciseGoal,
    required this.sleepGoal,
    // required this.waterIntakeGoal,
    // required this.todoList,
    // required this.meals,
  }) : super(key: key);

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  double exerciseProgress = 0.0;
  double sleepProgress = 0.0;
  double waterIntakeProgress = 0.0;
  double todoProgress = 0.0;
  double mealProgress = 0.0;

  List<String> completedTodos = [];
  List<String> completedMeals = [];
  double waterConsumed = 0.0;

  Duration exerciseCountdown = const Duration();
  Duration sleepCountdown = const Duration();
  Timer? exerciseTimer;
  Timer? sleepTimer;

  @override
  void initState() {
    super.initState();
    exerciseCountdown = Duration(minutes: widget.exerciseGoal.toInt());
    sleepCountdown = Duration(hours: widget.sleepGoal.toInt());
    _startCountdownTimers();
  }

  @override
  void dispose() {
    exerciseTimer?.cancel();
    sleepTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimers() {
    exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (exerciseCountdown.inSeconds > 0) {
          exerciseCountdown -= const Duration(seconds: 1);
          exerciseProgress = 100.0 -
              (exerciseCountdown.inSeconds / (widget.exerciseGoal * 60)) *
                  100.0;
        } else {
          exerciseTimer?.cancel();
        }
      });
    });

    sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (sleepCountdown.inSeconds > 0) {
          sleepCountdown -= const Duration(seconds: 1);
          sleepProgress = 100.0 -
              (sleepCountdown.inSeconds / (widget.sleepGoal * 3600)) * 100.0;
        } else {
          sleepTimer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width
    // final isExercise = context.watch<ExerciseTimerProvider>().remainingTime;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Progress',
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
          elevation: 5,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    // height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A7F67).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DashboardComponentTitle(
                              logo: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    '🏋️‍♂️',
                                    style: TextStyle(fontSize: 20),
                                  )),
                              title: 'Exercise goal',
                              subTitle: "Recent exercise goal",
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Consumer<ExerciseTimerProvider>(
                          builder: (context, timerProvider, child) {
                            int minutes = timerProvider.remainingTime ~/ 60;
                            int seconds = timerProvider.remainingTime % 60;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  timerProvider.exerciseName == ""
                                      ? "No Exercise"
                                      : timerProvider.exerciseName,
                                  style: AppStyle.cardfooter,
                                ),
                                Text(
                                    '$minutes:${seconds.toString().padLeft(2, '0')}',
                                    style: AppStyle.cardTitle
                                        .copyWith(fontSize: 50)),
                              ],
                            );
                          },
                        ),
                        // Column(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     // Row(
                        //     //   children: [
                        //     //     Text('Task', style: AppStyle.cardSubtitle),
                        //     //     const Spacer(),
                        //     //     Text('Period', style: AppStyle.cardSubtitle),
                        //     //   ],
                        //     // ),
                        //     Consumer<ExerciseTimerProvider>(
                        //       builder: (context, timerProvider, child) {
                        //         int minutes = timerProvider.remainingTime ~/ 60;
                        //         int seconds = timerProvider.remainingTime % 60;
                        //         return Text(
                        //           '$minutes:${seconds.toString().padLeft(2, '0')}',
                        //           style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                        //         );
                        //       },
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16.0),
                    // height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A7F67).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DashboardComponentTitle(
                              logo: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    '📝',
                                    style: TextStyle(fontSize: 20),
                                  )
                                  // Icon(
                                  //   Icons.today_outlined,
                                  //   size: 25,
                                  //   color: Colors.green,
                                  // ),
                                  ),
                              title: 'To-do',
                              subTitle: "Recent To-dos",
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Task', style: AppStyle.cardSubtitle),
                                const Spacer(),
                                Text('Period', style: AppStyle.cardSubtitle),
                              ],
                            ),
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('to-do-goals')
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

                                return SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: tasks.length,
                                    itemBuilder: (context, index) {
                                      var task = tasks[index];
                                      return Column(
                                        children: [
                                          _DetailItem(
                                              title: task['title'].toString(),
                                              desc: task['description'],
                                              period: task['period'] ??
                                                  "No period"),
                                          const Divider(),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_)=>const MoreTodos()));
                              },
                              child: Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      'See more',
                                      style: AppStyle.cardfooter.copyWith(
                                        color: Colors.green[800],
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  )),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    // height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A7F67).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DashboardComponentTitle(
                              logo: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    '💧',
                                    style: TextStyle(fontSize: 20),
                                  )),
                              title: 'Water Intake',
                              subTitle: "Daily water intake schedule",
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('water-intake-schedule')
                                  .doc(FirebaseAuth.instance.currentUser?.uid)
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return Center(
                                      child: Text(
                                    "No water intake schedule available",
                                    style: AppStyle.cardSubtitle,
                                  ));
                                }

                                Map<String, dynamic> data = snapshot.data!
                                    .data() as Map<String, dynamic>;
                                // .data() as Map<String, dynamic>?;
                                if (data == null) {
                                  return Center(
                                      child: Text(
                                    "No water intake schedule available",
                                    style: AppStyle.cardSubtitle,
                                  ));
                                }
                                return _buildWaterTracker(
                                    data['daily-water-intake']);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A7F67).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DashboardComponentTitle(
                              logo: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    '🍱',
                                    style: TextStyle(fontSize: 20),
                                  )),
                              title: 'Meal Planner',
                              subTitle: "Recent meal schedule",
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('meal-planner')
                                  .doc(FirebaseAuth.instance.currentUser?.uid)
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return Center(
                                    child: Text(
                                      "No meals available",
                                      style: AppStyle.cardSubtitle,
                                    ),
                                  );
                                }

                                String currentDay =
                                    DateFormat('EEEE').format(DateTime.now());
                                Map<String, dynamic>? data = snapshot.data!
                                    .data() as Map<String, dynamic>?;

                                if (data == null ||
                                    !data.containsKey(currentDay)) {
                                  return Center(
                                    child: Text(
                                      "No meals schedule set for today",
                                      style: AppStyle.cardfooter,
                                    ),
                                  );
                                }

                                Map<String, dynamic> categories =
                                    data[currentDay] as Map<String,
                                        dynamic>; // e.g., Breakfast, Lunch...

                                return SizedBox(
                                  height: 300,
                                  child: ListView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: categories.entries.map((entry) {
                                      String mealType =
                                          entry.key; // Breakfast, Lunch, Dinner
                                      Map<String, dynamic> meal =
                                          entry.value; // The meal object

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                );
                              },
                            ),
                            InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const MoreMealSchedule())),
                              child: Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      'See more',
                                      style: AppStyle.cardfooter.copyWith(
                                        color: Colors.green[800],
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  )),
                            )

                            // StreamBuilder(
                            //   stream: FirebaseFirestore.instance
                            //       .collection('meal-planner')
                            //       .doc(FirebaseAuth.instance.currentUser?.uid)
                            //       .snapshots(),
                            //   builder: (context,
                            //       AsyncSnapshot<DocumentSnapshot> snapshot) {
                            //     if (!snapshot.hasData || !snapshot.data!.exists) {
                            //       return Center(
                            //           child: Text(
                            //         "No meals available",
                            //         style: AppStyle.cardSubtitle,
                            //       ));
                            //     }
                            //     String currentDay = DateFormat('EEEE').format(DateTime.now());
                            //     Map<String, dynamic>? data = snapshot.data!
                            //         .data() as Map<String, dynamic>?;
                            //
                            //     if (data == null ||
                            //         !data.containsKey('categories')) {
                            //       return Center(
                            //           child: Text(
                            //         "No meals available",
                            //         style: AppStyle.cardSubtitle,
                            //       ));
                            //     }
                            //
                            //     Map<String, dynamic> categories =
                            //         data[currentDay]; // Treat as Map
                            //
                            //     return SizedBox(
                            //       height: 300, // Adjust as needed
                            //       child: ListView(
                            //         physics:
                            //             const NeverScrollableScrollPhysics(),
                            //         children: categories.entries.map((entry) {
                            //           String mealType = entry.key; // "Breakfast", "Lunch", "Dinner"
                            //           List<dynamic> meals =
                            //               entry.value; // Extract the list
                            //
                            //           return Column(
                            //             crossAxisAlignment:
                            //                 CrossAxisAlignment.start,
                            //             children: [
                            //               Text(mealType,
                            //                   style: const TextStyle(
                            //                       fontSize: 18,
                            //                       fontWeight: FontWeight.bold)),
                            //               ...meals
                            //                   .map((meal) =>
                            //                       _buildMealItem(meal))
                            //                   .toList(),
                            //               const Divider(),
                            //             ],
                            //           );
                            //         }).toList(),
                            //       ),
                            //     );
                            //   },
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    // height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A7F67).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DashboardComponentTitle(
                              logo: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    '🌙',
                                    style: TextStyle(fontSize: 20),
                                  )),
                              title: 'Sleeping',
                              subTitle: "Recent sleeping goal",
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Consumer<SleepTimerProvider>(
                          builder: (context, timerProvider, _) {
                            if (timerProvider.isCounting &&
                                timerProvider.remaining != null) {
                              final r = timerProvider.remaining!;
                              final h = r.inHours.toString().padLeft(2, '0');
                              final m =
                                  (r.inMinutes % 60).toString().padLeft(2, '0');
                              final s =
                                  (r.inSeconds % 60).toString().padLeft(2, '0');
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sleeping Countdown',
                                      style: AppStyle.cardfooter),
                                  Text('$h:$m:$s',
                                      // '${sleepCountdown.inHours.toString().padLeft(2, '0')}:${(sleepCountdown.inMinutes % 60).toString().padLeft(2, '0')}:${(sleepCountdown.inSeconds % 60).toString().padLeft(2, '0')}',
                                      style: AppStyle.cardTitle
                                          .copyWith(fontSize: 50)),
                                ],
                              );
                            } else {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('No sleep countdown running.'),
                                  Text('00:00:00',
                                      style: AppStyle.cardTitle
                                          .copyWith(fontSize: 50)),
                                ],
                              );
                            }
                          },
                        )

                        // Consumer<ExerciseTimerProvider>(
                        //   builder: (context, timerProvider, child) {
                        //     int minutes = timerProvider.remainingTime ~/ 60;
                        //     int seconds = timerProvider.remainingTime % 60;
                        //     return Column(
                        //       mainAxisAlignment: MainAxisAlignment.start,
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Text('Sleeping Countdown',
                        //             style: AppStyle.cardSubtitle),
                        //         Text(
                        //           '${sleepCountdown.inHours.toString().padLeft(2, '0')}:${(sleepCountdown.inMinutes % 60).toString().padLeft(2, '0')}:${(sleepCountdown.inSeconds % 60).toString().padLeft(2, '0')}',
                        //           style: const TextStyle(
                        //               fontSize: 24,
                        //               fontWeight: FontWeight.bold),
                        //         ),
                        //         //   _buildCountdownDisplay(
                        //         //   'Sleep Countdown', sleepCountdown
                        //         // Text(
                        //         //   timerProvider.exerciseName == ""
                        //         //       ? "No Exercise"
                        //         //       : timerProvider.exerciseName,
                        //         //   style: AppStyle.cardSubtitle,
                        //         // ),
                        //         // Text(
                        //         //   '$minutes:${seconds.toString().padLeft(2, '0')}',
                        //         //   style: const TextStyle(
                        //         //       fontSize: 50,
                        //         //       fontWeight: FontWeight.bold),
                        //         // ),
                        //       ],
                        //     );
                        //   },
                        // ),
                        ///
                        // Column(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     // Row(
                        //     //   children: [
                        //     //     Text('Task', style: AppStyle.cardSubtitle),
                        //     //     const Spacer(),
                        //     //     Text('Period', style: AppStyle.cardSubtitle),
                        //     //   ],
                        //     // ),
                        //     Consumer<ExerciseTimerProvider>(
                        //       builder: (context, timerProvider, child) {
                        //         int minutes = timerProvider.remainingTime ~/ 60;
                        //         int seconds = timerProvider.remainingTime % 60;
                        //         return Text(
                        //           '$minutes:${seconds.toString().padLeft(2, '0')}',
                        //           style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                        //         );
                        //       },
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 20),
                  // _buildFullWidthContainer(
                  //   screenWidth: screenWidth,
                  //   child: _buildCountdownDisplay(
                  //       'Sleep Countdown', sleepCountdown),
                  // ),
                  _buildFullWidthContainer(
                    screenWidth: screenWidth,
                    child: _buildChartContainer(),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildFullWidthContainer(
      {required double screenWidth, required Widget child}) {
    return Container(
      width: screenWidth * 0.95, // Stretch to 95% of screen width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
  //
  // Widget _buildCheckListProgress({
  //   required String title,
  //   required List<String> items,
  //   required List<String> completedItems,
  //   required Function(String, bool) onItemChecked,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(title,
  //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //       const SizedBox(height: 10),
  //       if (items.isEmpty)
  //         const Text("No items added yet!",
  //             style: TextStyle(
  //                 color: Colors.grey, fontSize: 14)), // Handle empty list
  //       ...items.map((item) {
  //         return CheckboxListTile(
  //           title: Text(item),
  //           value: completedItems.contains(item),
  //           onChanged: (bool? isChecked) {
  //             setState(() {
  //               if (isChecked == true) {
  //                 completedItems.add(item);
  //               } else {
  //                 completedItems.remove(item);
  //               }
  //               todoProgress =
  //                   (completedTodos.length / widget.todoList.length) * 100;
  //               mealProgress =
  //                   (completedMeals.length / widget.meals.length) * 100;
  //             });
  //           },
  //           controlAffinity:
  //               ListTileControlAffinity.leading, // Aligns checkbox to left
  //           activeColor: Colors.green, // Set checkbox color
  //         );
  //       }).toList(),
  //     ],
  //   );
  // }

  Widget _buildCountdownDisplay(String title, Duration countdown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(
          '${countdown.inHours.toString().padLeft(2, '0')}:${(countdown.inMinutes % 60).toString().padLeft(2, '0')}:${(countdown.inSeconds % 60).toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildWaterTracker(String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text('Water Intake',
        //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Slider(
          value: double.parse(data.toString()),
          min: 0,
          max: 5.0,
          activeColor: const Color(0xFF66C3A7), // Updated slider color
          thumbColor: const Color(0xFF2A7F67), // Thumb color for consistency
          onChanged: (value) {
            setState(() {
              waterConsumed = double.parse(data.toString());
              waterIntakeProgress = (waterConsumed / 5.0) * 100;
            });
          },
        ),
        Text('${double.parse(data.toString()) ?? waterConsumed}L / 5.0L'),
      ],
    );
  }

  Widget _buildChartContainer() {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey),
          ),
          lineBarsData: [
            _buildLineChartBarData(todoProgress, Colors.red, Colors.pink),
            _buildLineChartBarData(
                waterIntakeProgress, Colors.blue, Colors.lightBlue),
            _buildLineChartBarData(
                mealProgress, Colors.green, Colors.lightGreen),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(
      double progress, Color startColor, Color endColor) {
    return LineChartBarData(
      spots: [
        FlSpot(0, progress / 100 * 5),
        const FlSpot(1, 5.0)
      ], // Adjusted scaling
      isCurved: true,
      barWidth: 4,
      belowBarData: BarAreaData(show: true, color: startColor.withOpacity(0.3)),
      gradient: LinearGradient(colors: [startColor, endColor]),
      dotData: const FlDotData(show: false),
    );
  }

  Widget DashboardComponentTitle(
      {required String title,
      required String subTitle,
      required CircleAvatar logo}) {
    return Row(
      children: [
        logo,
        const SizedBox(
          width: 10,
        ),
        Expanded(
          // Ensures the text wraps and respects constraints
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyle.cardSubtitle.copyWith(fontSize: 14),
                ),
                Text(
                  subTitle,
                  style: AppStyle.cardfooter.copyWith(fontSize: 12),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis, // Adds ellipsis for overflow
                  maxLines: 2, // Restricts to 2 lines
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildMealItem(Map<String, dynamic> meal) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: _DetailItem(
      title: meal['name']?.toString() ?? "No name",
      desc: '${meal['vegetable1']?.toString() ?? "No vegetable 1"}, '
          '${meal['vegetable1']?.toString() ?? "No vegetable 2"}',
      period: '${meal['meal-time']?.toString() ?? "No period"}',
    ),
  );
}

class _DetailItem extends StatelessWidget {
  final String title;
  final String desc;
  final String period;

  const _DetailItem({
    super.key,
    required this.title,
    required this.desc,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppStyle.cardSubtitle.copyWith(fontSize: 14)),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Text(period,
                      style: AppStyle.cardfooter
                          .copyWith(fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
            ],
          ),
          Text(desc, style: AppStyle.cardfooter.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
