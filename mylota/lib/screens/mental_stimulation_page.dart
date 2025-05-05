import 'package:flutter/material.dart';
import 'package:mylota/utils/styles.dart';
import 'package:mylota/widgets/pattern_recognition_game.dart';
import 'package:mylota/widgets/puzzle_game.dart';
import 'package:mylota/widgets/cognitive_tasks_page.dart';
import '../widgets/custom_input_decorator.dart';
import '../widgets/mental_stimulation_widget.dart';
import 'package:mylota/widgets/mindfulness_activities_widget.dart';

class MentalStimulationPage extends StatefulWidget {
  @override
  _MentalStimulationPageState createState() => _MentalStimulationPageState();
}

class _MentalStimulationPageState extends State<MentalStimulationPage> {
  // Dropdown selections
  String? selectedChallenge;
  String? selectedFocusActivity;

  // User input for learning modules
  final TextEditingController _learningModuleController = TextEditingController();
  List<String> learningModules = [];

  // Progress tracking
  int puzzleScore = 0;
  int cognitiveScore = 0;
  int meditationMinutes = 0;
  int learningProgress = 0;

  // Well-being reminders
  TimeOfDay? callSomeoneTime;
  DateTime? callSomeoneDate;
  String? callSomeoneContact;

  TimeOfDay? checkLoverTime;
  DateTime? checkLoverDate;
  String? checkLoverContact;

  TimeOfDay? selfTreatTime;

  List<String> dropdownItems = [];

  Future<void> _pickDate(BuildContext context, String title, Function(DateTime) onDateSelected) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }

  Future<void> _pickTime(BuildContext context, String title, Function(TimeOfDay) onTimeSelected) async {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mental Stimulation',
          style: AppStyle.cardTitle
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66C3A7), Color(0xFF2A7F67)], // Gradient
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
            colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)], // Background gradient
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Boost your brainpower with fun and engaging challenges designed to enhance focus, memory, and problem-solving skills',
                style: AppStyle.cardfooter,
                softWrap: true,
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),

              _buildSection(
                title: 'learning journey',
                subtitle: 'Engage in new learning.',
                icon: const Icon(Icons.lightbulb),
                child: const MentalStimulationWidget(),
              ),
              const SizedBox(height: 10),
              _buildSection(
                title: 'Challenge Your Thinking',
                subtitle: 'Select an activity to challenge your brain:',
                icon: const Icon(Icons.psychology),
                
                child: DropdownButtonFormField<String>(
                  value: selectedChallenge,
                  items: [
                    DropdownMenuItem(
                      value: 'Puzzle',
                      child: Text(
                        'Puzzle',
                        style: AppStyle.cardfooter.copyWith(fontSize: 12),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Pattern Recognition',
                      child: Text(
                        'Pattern Recognition',
                        style: AppStyle.cardfooter.copyWith(fontSize: 12),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Cognitive Tasks',
                      child: Text(
                        'Cognitive Tasks',
                        style: AppStyle.cardfooter.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedChallenge = value;
                    });

                    // Navigate to specific game screens based on the selected challenge
                    if (value == 'Puzzle') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PuzzleGame()),
                      );
                    } 
                    else if (value == 'Pattern Recognition') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PatternRecognitionGame()),
                      );
                    }
                    else if (value == 'Cognitive Tasks') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CognitiveTasksPage()),
                      );
                    }
                  },
                  decoration: customInputDecoration(
                    labelText: 'Choose a challenge',
                    hintText: 'Choose a challenge',
                    prefixIcon: const Icon(Icons.run_circle_outlined, color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildSection(
                title: 'Stay Focused',
                subtitle: 'Select an activity to improve focus:',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedFocusActivity,
                      items: const [
                        DropdownMenuItem(
                          value: 'Box Breathing',
                          child: Text('Box Breathing'),
                        ),
                        DropdownMenuItem(
                          value: '5-4-3-2-1 Grounding Exercise',
                          child: Text('5-4-3-2-1 Grounding Exercise'),
                        ),
                        DropdownMenuItem(
                          value: 'Single-Task Focus',
                          child: Text('Single-Task Focus'),
                        ),
                        DropdownMenuItem(
                          value: 'Mindful Walking',
                          child: Text('Mindful Walking'),
                        ),
                        DropdownMenuItem(
                          value: 'Mindful Listening',
                          child: Text('Mindful Listening'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedFocusActivity = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Choose activity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (selectedFocusActivity != null)
                      MindfulnessActivitiesWidget(activity: selectedFocusActivity!),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildSection(
                title: 'Track Your Progress',
                subtitle: 'See how your skills improve over time:',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Learning Progress:'),
                    LinearProgressIndicator(value: learningProgress / 100),
                    const Text('Puzzle Score:'),
                    LinearProgressIndicator(value: puzzleScore / 100),
                    const SizedBox(height: 10),
                    const Text('Cognitive Tasks Score:'),
                    LinearProgressIndicator(value: cognitiveScore / 100),
                    const SizedBox(height: 10),
                    const Text('Meditation Minutes:'),
                    LinearProgressIndicator(value: meditationMinutes / 60),
                    const SizedBox(height: 10),
                    
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildSection(
                title: 'Well-being Reminders',
                subtitle: 'Take care of yourself with these friendly reminders:',
                icon: const Icon(Icons.favorite),
                child: Column(
                  children: [
                    _buildReminderTileWithDateAndContact(
                      title: "Call Someone (Family/Friend)",
                      time: callSomeoneTime,
                      date: callSomeoneDate,
                      contact: callSomeoneContact,
                      onTimePressed: () => _pickTime(context, "Call Someone", (time) {
                        setState(() {
                          callSomeoneTime = time;
                        });
                      }),
                      onDatePressed: () => _pickDate(context, "Call Someone", (date) {
                        setState(() {
                          callSomeoneDate = date;
                        });
                      }),
                      onContactChanged: (contact) {
                        setState(() {
                          callSomeoneContact = contact;
                        });
                      },
                    ),
                    _buildReminderTileWithDateAndContact(
                      title: "Check on Spouse / Partner",
                      time: checkLoverTime,
                      date: checkLoverDate,
                      contact: checkLoverContact,
                      onTimePressed: () => _pickTime(context, "Check on Spouse / Partner", (time) {
                        setState(() {
                          checkLoverTime = time;
                        });
                      }),
                      onDatePressed: () => _pickDate(context, "Check on Spouse / Partner", (date) {
                        setState(() {
                          checkLoverDate = date;
                        });
                      }),
                      onContactChanged: (contact) {
                        setState(() {
                          checkLoverContact = contact;
                        });
                      },
                    ),
                    _buildReminderTile(
                      title: "Give Yourself a Treat",
                      time: selfTreatTime,
                      onPressed: () => _pickTime(context, "Give Yourself a Treat", (time) {
                        setState(() {
                          selfTreatTime = time;
                        });
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for building a section card
  Widget _buildSection({
    required String title,
    required String subtitle,
    Widget? icon,
    required Widget child,
  }) {
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
            Row(
              children: [
                CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF66C3A7).withOpacity(0.2), // Updated background color
                    child: icon
                  // Icon(icon, color: Color(0xFF66C3A7), size: 24), // Updated icon color
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppStyle.cardSubtitle
                      ),
                      Text(
                        subtitle,
                        style: AppStyle.cardfooter.copyWith(fontSize: 12)

                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTile({required String title, TimeOfDay? time, required VoidCallback onPressed}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(time != null ? "Set for ${time.format(context)}" : "Not set"),
      trailing: IconButton(
        icon: const Icon(Icons.alarm, color: Color(0xFF66C3A7)), // Updated icon color
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildReminderTileWithDateAndContact({
    required String title,
    TimeOfDay? time,
    DateTime? date,
    String? contact,
    required VoidCallback onTimePressed,
    required VoidCallback onDatePressed,
    required ValueChanged<String> onContactChanged,
  }) {
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
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time != null ? "Time: ${time.format(context)}" : "Time: Not set",
                  style: const TextStyle(color: Colors.grey),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time, color: Color(0xFF66C3A7)),
                  onPressed: onTimePressed,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? "Date: ${date.day}/${date.month}/${date.year}"
                      : "Date: Not set",
                  style: const TextStyle(color: Colors.grey),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Color(0xFF66C3A7)),
                  onPressed: onDatePressed,
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: "Contact Name",
                border: OutlineInputBorder(),
              ),
              onChanged: onContactChanged,
              controller: TextEditingController(text: contact),
            ),
          ],
        ),
      ),
    );
  }
}