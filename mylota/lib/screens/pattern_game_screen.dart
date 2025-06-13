import 'dart:math';
import 'package:flutter/material.dart';

import '../widgets/appBar_widget.dart';

class PatternGameScreen extends StatefulWidget {
  @override
  _PatternGameScreenState createState() => _PatternGameScreenState();
}

class _PatternGameScreenState extends State<PatternGameScreen> {
  final List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow];
  List<int> pattern = [];
  List<int> userInput = [];
  int difficulty = 4;

  @override
  void initState() {
    super.initState();
    _generatePattern();
  }

  void _generatePattern() {
    Random random = Random();
    pattern.clear();
    for (int i = 0; i < difficulty; i++) {
      pattern.add(random.nextInt(colors.length));
    }
    setState(() {});
  }

  void _userSelect(int index) {
    userInput.add(index);
    if (userInput.length == pattern.length) {
      bool correct = userInput.every((val) => val == pattern[userInput.indexOf(val)]);
      _showResult(correct);
    }
  }

  void _showResult(bool correct) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(correct ? "Correct!" : "Try Again!"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
        ],
      ),
    );
    setState(() {
      userInput.clear();
      _generatePattern();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context: context, title: 'Pattern Game'),
      // AppBar(title: Text("Pattern Game")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Remember this pattern:"),
            const SizedBox(height: 10),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: pattern.map((index) => Container(
                  width: 50,
                  height: 50,
                  color: colors[index],
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Text("Tap the colors in the same order:"),
            const SizedBox(height: 10),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: List.generate(colors.length, (index) =>
                  GestureDetector(
                    onTap: () => _userSelect(index),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: colors[index],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
