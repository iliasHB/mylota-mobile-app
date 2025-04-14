// import 'package:shared_preferences/shared_preferences.dart';
//
// class LeaderboardService {
//   static const String _scoreKey = "high_score";
//
//   static Future<void> saveHighScore(int score) async {
//     final prefs = await SharedPreferences.getInstance();
//     int highScore = prefs.getInt(_scoreKey) ?? 0;
//     if (score > highScore) {
//       prefs.setInt(_scoreKey, score);
//     }
//   }
//
//   static Future<int> getHighScore() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt(_scoreKey) ?? 0;
//   }
// }
