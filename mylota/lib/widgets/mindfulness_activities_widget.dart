import 'package:flutter/material.dart';

class MindfulnessActivitiesWidget extends StatelessWidget {
  final String activity;

  const MindfulnessActivitiesWidget({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String instructions = _getInstructions(activity);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              instructions,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  String _getInstructions(String activity) {
    switch (activity) {
      case 'Box Breathing':
        return '''
Breathe in for 4 seconds → Hold for 4 seconds → Breathe out for 4 seconds → Hold for 4 seconds.

Repeat for 2–5 minutes.

Clears mental chatter and centers attention fast.
''';
      case '5-4-3-2-1 Grounding Exercise':
        return '''
5 things you can see
4 things you can touch
3 things you can hear
2 things you can smell
1 thing you can taste

Great for bringing your mind back when it starts to drift.
''';
      case 'Single-Task Focus':
        return '''
Pick one small task (like drinking tea, brushing teeth, or writing a sentence).

Focus only on that task — how it feels, sounds, smells.

Helps strengthen attention muscle over time.
''';
      case 'Mindful Walking':
        return '''
Walk slowly (even just around your room).

Pay attention to how your feet lift and touch the ground, the sway of your arms, the rhythm of your steps.

Builds awareness and regulates your breathing too.
''';
      case 'Mindful Listening':
        return '''
Put on soft background sounds (like rain, birds, instrumental music).

Listen intentionally — notice shifts in tone, volume, or pattern without judging.

Trains sustained attention and mental quietness.
''';
      default:
        return 'Select an activity to see instructions.';
    }
  }
}