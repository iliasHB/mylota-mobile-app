import 'package:flutter/material.dart';
import 'dart:math';

class PatternRecognitionGame extends StatefulWidget {
  const PatternRecognitionGame({Key? key}) : super(key: key);

  @override
  _PatternRecognitionGameState createState() => _PatternRecognitionGameState();
}

class _PatternRecognitionGameState extends State<PatternRecognitionGame> {
  final Random _random = Random();
  late List<int> pattern; // The pattern to recognize
  late List<int> userInput; // User's input
  int currentLevel = 1; // Game level
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      currentLevel = 1;
      isGameOver = false;
      _generatePattern();
      userInput = [];
    });
  }

  void _generatePattern() {
    pattern = List.generate(currentLevel, (_) => _random.nextInt(4)); // 4 colors
  }

  void _handleUserInput(int input) {
    if (isGameOver) return;

    setState(() {
      userInput.add(input);

      // Check if the user's input matches the pattern so far
      for (int i = 0; i < userInput.length; i++) {
        if (userInput[i] != pattern[i]) {
          isGameOver = true;
          return;
        }
      }

      // If the user completes the pattern, move to the next level
      if (userInput.length == pattern.length) {
        currentLevel++;
        _generatePattern();
        userInput = [];
      }
    });
  }

  Widget _buildColorButton(int colorIndex, Color color) {
    return GestureDetector(
      onTap: () => _handleUserInput(colorIndex),
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pattern Recognition Game'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isGameOver)
              Column(
                children: [
                  const Text(
                    'Memorize the Pattern!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Allow horizontal scrolling
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pattern
                          .map((colorIndex) => Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: _getColor(colorIndex),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Repeat the Pattern Below:',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            if (isGameOver)
              const Text(
                'Game Over! Try Again!',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0, // Horizontal spacing between buttons
              runSpacing: 8.0, // Vertical spacing between rows
              alignment: WrapAlignment.center,
              children: [
                _buildColorButton(0, Colors.red),
                _buildColorButton(1, Colors.green),
                _buildColorButton(2, Colors.blue),
                _buildColorButton(3, Colors.yellow),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startNewGame,
              child: const Text('Restart Game'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(int index) {
    switch (index) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}