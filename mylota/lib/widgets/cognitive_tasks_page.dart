import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mylota/widgets/custom_button.dart';

class CognitiveTasksPage extends StatefulWidget {
  const CognitiveTasksPage({Key? key}) : super(key: key);

  @override
  _CognitiveTasksPageState createState() => _CognitiveTasksPageState();
}

class _CognitiveTasksPageState extends State<CognitiveTasksPage> {
  final List<String> words = [
    'Dog', 'Apple', 'Hammer', 'Cat', 'Banana', 'Wrench', 'Elephant', 'Carrot',
    'Screwdriver', 'Lion', 'Orange', 'Drill', 'Tiger', 'Grapes', 'Saw',
    'Horse', 'Peach', 'Pliers', 'Monkey', 'Strawberry','Pear', 'Shovel',
    'Zebra', 'Watermelon', 'Axe', 'Giraffe', 'Blueberry', 'Mallet', 'Bear', 'Fox'
  ];
  final Map<String, List<String>> categories = {
    'Animals': [],
    'Fruits': [],
    'Tools': [],
  };
  String? selectedCategory;
  int currentWordIndex = 0;
  bool isGameOver = false;
  Timer? timer;
  int timeLeft = 90; // 90 seconds

  @override
  void initState() {
    super.initState();
    words.shuffle(); // Shuffle the words for randomness
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          isGameOver = true;
          timer.cancel();
        }
      });
    });
  }

  void _categorizeWord(String category) {
    if (isGameOver) return;

    setState(() {
      categories[category]?.add(words[currentWordIndex]);
      currentWordIndex++;
      if (currentWordIndex >= words.length) {
        isGameOver = true;
        timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cognitive Tasks'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isGameOver
            ? _buildGameOverScreen()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Description on how to play
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'How to play:\n\n'
                      'A word will appear on the screen. Your task is to quickly decide if it is an Animal, Fruit, or Tool and tap the correct category button. '
                      'You have 90 seconds to categorize as many words as you can. Try to be fast and accurate!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                  Text(
                    'Time Left: $timeLeft seconds',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Word: ${words[currentWordIndex]}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select a Category:',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10.0,
                    children: categories.keys.map((category) {
                      return ElevatedButton(
                        onPressed: () => _categorizeWord(category),
                        child: Text(category),
                      );
                    }).toList(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Game Over!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'Your Categorized Words:',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        ...categories.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${entry.key}:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(entry.value.join(', ')),
              const SizedBox(height: 10),
            ],
          );
        }).toList(),
        const SizedBox(height: 20),
        Center( // Center the button
          child: CustomPrimaryButton(
            label: 'Play Again',
            onPressed: () {
              setState(() {
                _resetGame();
              });
            },
          ),
        ),
      ],
    );
  }

  void _resetGame() {
    setState(() {
      words.shuffle();
      categories.forEach((key, value) => value.clear());
      currentWordIndex = 0;
      isGameOver = false;
      timeLeft = 90;
      _startTimer();
    });
  }
}