import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';

class BoxBreathingAudioWidget extends StatefulWidget {
  @override
  _BoxBreathingAudioWidgetState createState() => _BoxBreathingAudioWidgetState();
}

class _BoxBreathingAudioWidgetState extends State<BoxBreathingAudioWidget> {
  // final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  void dispose() {
    // _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    // if (isPlaying) {
    //   await _audioPlayer.pause();
    //   setState(() => isPlaying = false);
    // } else {
    //   await _audioPlayer.play(AssetSource('audio/box_breathing.mp3'));
    //   await _audioPlayer.setPlaybackRate(0.8); // Slow down to 0.5x
    //   setState(() => isPlaying = true);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Box Breathing Audio",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, size: 48, color: Colors.green),
              onPressed: _toggleAudio,
              tooltip: isPlaying ? "Pause" : "Play",
            ),
            Text(isPlaying ? "Playing..." : "Tap to play"),
          ],
        ),
      ),
    );
  }
}