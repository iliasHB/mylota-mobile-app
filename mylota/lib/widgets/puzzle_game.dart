import 'package:flutter/material.dart';
import 'dart:math';

import 'package:mylota/widgets/custom_button.dart';

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({Key? key}) : super(key: key);

  @override
  _PuzzleGameState createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  final int gridColumns = 4; // Number of columns
  final int gridRows = 3; // Number of rows
  late List<int> tiles;

  @override
  void initState() {
    super.initState();
    _initializeTiles();
  }

  void _initializeTiles() {
    tiles = List.generate(gridColumns * gridRows, (index) => index);
    tiles.shuffle(Random());
  }

  void _onTileTap(int index) {
    int emptyIndex = tiles.indexOf(0);
    if (_isAdjacent(index, emptyIndex)) {
      setState(() {
        tiles[emptyIndex] = tiles[index];
        tiles[index] = 0;
      });
    }
  }

  bool _isAdjacent(int index1, int index2) {
    int row1 = index1 ~/ gridColumns;
    int col1 = index1 % gridColumns;
    int row2 = index2 ~/ gridColumns;
    int col2 = index2 % gridColumns;

    return (row1 == row2 && (col1 - col2).abs() == 1) ||
        (col1 == col2 && (row1 - row2).abs() == 1);
  }

  bool _isSolved() {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles.last == 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Game'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add this description
            const Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Text(
                'How to play:\n\n'
                'Tap a tile next to the empty space to move it. '
                'Arrange the numbers in order from 1 to 11, with the empty space at the end, to solve the puzzle.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridColumns, // Set the number of columns
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: tiles.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onTileTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tiles[index] == 0 ? Colors.grey[300] : Colors.teal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        tiles[index] == 0 ? '' : tiles[index].toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            if (_isSolved())
              const Text(
                'Congratulations! You solved the puzzle!',
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
            CustomPrimaryButton(
              label: 'Restart',
              onPressed: () {
                setState(() {
                  _initializeTiles();
                });
              },
            ),
            //child: const Text('Restart'),
          ],
        ),
      ),
    );
  }
}