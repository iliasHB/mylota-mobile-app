import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mylota/utils/styles.dart';
import 'package:mylota/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/water_intake_controller.dart';
import '../core/usecase/provider/water_intake_provider.dart';

class WaterTracker extends StatefulWidget {
  const WaterTracker({super.key});

  @override
  _WaterTrackerState createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> {
  double _waterIntake = 1.0; // Default water intake goal in litres
  TimeOfDay? reminderPeriod;

  bool isLoading = false;
  void _startLoading() => setState(() => isLoading = true);
  void _stopLoading() => setState(() => isLoading = false);
  @override
  void initState() {
    super.initState();
    // _loadWaterIntake();
  }

  // // Load saved water intake goal
  // Future<void> _loadWaterIntake() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _waterIntake = prefs.getDouble('waterIntake') ?? 2.0;
  //   });
  // }

  Future<void> _pickTime(BuildContext context, String title,
      Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      onTimeSelected(pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Your Daily Water Intake (Litres)',
            style: AppStyle.cardfooter,
          ),
          const SizedBox(height: 5),

          // Water intake slider
          Slider(
            value: _waterIntake,
            min: 1.0,
            max: 5.0,
            divisions: 8,
            activeColor: const Color(0xFF66C3A7), // Updated slider color
            thumbColor: const Color(0xFF2A7F67), // Thumb color for consistency
            label: '${_waterIntake.toStringAsFixed(1)} L',
            onChanged: (value) {
              setState(() {
                _waterIntake = value;
              });
            },
          ),
          const SizedBox(height: 10),
          Text(
            "Set Reminder Period (Everyday)",
            style: AppStyle.cardfooter,
          ),
          const SizedBox(height: 5),
          TextFormField(
            keyboardType: TextInputType.datetime,
            readOnly: true,
            decoration: InputDecoration(
              // enabled: isDisable,
              prefixIcon: const Icon(
                Icons.alarm,
                color: Colors.green,
              ),
              filled: true,
              fillColor: const Color(0xFF2A7F67).withOpacity(0.3),
              hintStyle: AppStyle.cardfooter.copyWith(
                fontSize: 12,
              ),
              hintText: reminderPeriod?.format(context) == null
                  ? 'Set reminder period'
                  : reminderPeriod!.format(context),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(5)),
            ),
            onTap: () => _pickTime(context, "Reminder period", (time) {
              setState(() {
                reminderPeriod = time;
              });
            }),
          ),
          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                Text(
                  'Goal: ${_waterIntake.toStringAsFixed(1)} Litres daily',
                  style: AppStyle.cardfooter,
                ),
                Text(
                  'Reminder: ${reminderPeriod?.format(context) ?? const TimeOfDay(hour: 12, minute: 0).format(context)}',
                  style: AppStyle.cardfooter,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Save button
          Center(
              child: CustomPrimaryButton(
            label: 'Save Goal',
            onPressed: () => saveWaterIntake(reminderPeriod, context, _waterIntake)
                // WaterInTakeController.saveWaterIntake(
                // reminderPeriod, context, _waterIntake),
          )),
        ],
      ),
    );
  }

  saveWaterIntake(TimeOfDay? reminderPeriod, BuildContext context, double waterIntake) {
    WaterInTakeController.saveWaterIntake(
        reminderPeriod,
      context,
      _waterIntake,
      onStartLoading: _startLoading,
      onStopLoading: _stopLoading);
  }
}
