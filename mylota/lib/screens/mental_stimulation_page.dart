import 'package:flutter/material.dart';
import '../widgets/mental_stimulation_widget.dart';

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
  TimeOfDay? checkLoverTime;
  TimeOfDay? selfTreatTime;

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
        title: const Text(
          'Mental Stimulation',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color:  Colors.white),
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
              const Text(
                'Boost your brainpower with fun and engaging challenges designed to enhance focus, memory, and problem-solving skills',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 20),

              _buildSection(
                title: 'learning journey',
                subtitle: 'Engage in new learning.',
                icon: Icons.lightbulb,
                child: MentalStimulationWidget(),
              ),

              _buildSection(
                title: 'Challenge Your Thinking',
                subtitle: 'Select an activity to challenge your brain:',
                child: DropdownButton<String>(
                  value: selectedChallenge,
                  hint: const Text('Select a challenge'),
                  items: const [
                    DropdownMenuItem(value: 'Puzzles & Games', child: Text('Puzzles & Games (e.g., Sudoku, chess)')),
                    DropdownMenuItem(value: 'Cognitive Tasks', child: Text('Cognitive Tasks (e.g., math problems, quick decision-making tests)')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedChallenge = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              _buildSection(
                title: 'Stay Focused',
                subtitle: 'Select an activity to improve focus:',
                child: Column(
                  children: [
                    DropdownButton<String>(
                      value: selectedFocusActivity,
                      hint: const Text('Select an activity'),
                      items: const [
                        DropdownMenuItem(value: 'Meditation & Mindfulness', child: Text('Meditation & Mindfulness (e.g., breathing exercises, guided focus)')),
                        DropdownMenuItem(value: 'Learning Modules', child: Text('Learning Modules (e.g., new words, languages, or skills)')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedFocusActivity = value;
                        });
                      },
                    ),
                    if (selectedFocusActivity == 'Learning Modules')
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          TextField(
                            controller: _learningModuleController,
                            decoration: const InputDecoration(
                              hintText: 'Enter a new learning module...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              if (_learningModuleController.text.isNotEmpty) {
                                setState(() {
                                  learningModules.add(_learningModuleController.text);
                                  _learningModuleController.clear();
                                });
                              }
                            },
                            child: const Text('Add Learning Module'),
                          ),
                        ],
                      ),
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
                    const Text('Puzzles & Games Score:'),
                    LinearProgressIndicator(value: puzzleScore / 100),
                    const SizedBox(height: 10),
                    const Text('Cognitive Tasks Score:'),
                    LinearProgressIndicator(value: cognitiveScore / 100),
                    const SizedBox(height: 10),
                    const Text('Meditation Minutes:'),
                    LinearProgressIndicator(value: meditationMinutes / 60),
                    const SizedBox(height: 10),
                    const Text('Learning Progress:'),
                    LinearProgressIndicator(value: learningProgress / 100),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildSection(
                title: 'Well-being Reminders',
                subtitle: 'Take care of yourself with these friendly reminders:',
                icon: Icons.favorite,
                child: Column(
                  children: [
                    _buildReminderTile(
                      title: "Call Someone (Family/Friend)",
                      time: callSomeoneTime,
                      onPressed: () => _pickTime(context, "Call Someone", (time) {
                        setState(() {
                          callSomeoneTime = time;
                        });
                      }),
                    ),
                    _buildReminderTile(
                      title: "Check on Spouse / Partner",
                      time: checkLoverTime,
                      onPressed: () => _pickTime(context, "Check on Spouse / Partner", (time) {
                        setState(() {
                          checkLoverTime = time;
                        });
                      }),
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

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
    IconData? icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, color: Color(0xFF66C3A7)), // Updated icon color
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
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
}
