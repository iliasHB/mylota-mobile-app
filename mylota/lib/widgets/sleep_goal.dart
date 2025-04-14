import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/sleep_schedule_controller.dart';
import '../core/usecase/provider/sleep_timer_provider.dart';
import '../utils/styles.dart';

class SleepGoal extends StatefulWidget {
  @override
  _SleepGoalState createState() => _SleepGoalState();
}

class _SleepGoalState extends State<SleepGoal> {
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;

  Future<void> _pickTime(BuildContext context, bool isBedTime) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: isBedTime
          ? (_bedTime ?? const TimeOfDay(hour: 22, minute: 0))
          : (_wakeTime ?? const TimeOfDay(hour: 6, minute: 0)),
    );

    if (pickedTime != null) {
      setState(() {
        if (isBedTime) {
          _bedTime = pickedTime;
        } else {
          _wakeTime = pickedTime;
        }
      });
      if(_bedTime != null && _wakeTime != null){
        SleepScheduleController.saveSleepGoal(_bedTime, _wakeTime, context);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _pickTime(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A7F67), // Default here
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _bedTime == null
                        ? 'Set Bedtime'
                        : 'Bedtime: ${_bedTime!.format(context)}',
                    style: AppStyle.cardSubtitle
                        .copyWith(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _pickTime(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A7F67), // Default here
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _wakeTime == null
                        ? 'Set Wake-up Time'
                        : 'Wake: ${_wakeTime!.format(context)}',
                    style: AppStyle.cardSubtitle
                        .copyWith(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_bedTime != null && _wakeTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Sleep Duration: ${_calculateSleepDuration()} hours',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
      ],
    );
  }

  String _calculateSleepDuration() {
    final bedTimeMinutes = (_bedTime!.hour * 60) + _bedTime!.minute;
    final wakeTimeMinutes = (_wakeTime!.hour * 60) + _wakeTime!.minute;

    int durationMinutes;
    if (wakeTimeMinutes >= bedTimeMinutes) {
      durationMinutes = wakeTimeMinutes - bedTimeMinutes;
    } else {
      durationMinutes = (24 * 60 - bedTimeMinutes) + wakeTimeMinutes;
    }

    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '$hours:$minutes';
  }
}
