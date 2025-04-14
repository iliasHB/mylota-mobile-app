// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class BedtimeSlider extends StatefulWidget {
//   @override
//   _BedtimeSliderState createState() => _BedtimeSliderState();
// }
//
// class _BedtimeSliderState extends State<BedtimeSlider> {
//   double _bedtime = 22; // Default 10:00 PM in 24-hour format
//
//   @override
//   void initState() {
//     super.initState();
//     _loadBedtime();
//   }
//
//   Future<void> _loadBedtime() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _bedtime = prefs.getDouble('bedtime') ?? 22;
//     });
//   }
//
//   Future<void> _saveBedtime(double value) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setDouble('bedtime', value);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Bedtime set for ${value.round()}:00')),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Set Your Bedtime',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             SizedBox(height: 10),
//             Slider(
//               value: _bedtime,
//               min: 18, // 6:00 PM
//               max: 24, // 12:00 AM
//               divisions: 6,
//               label: '${_bedtime.round()}:00',
//               onChanged: (value) {
//                 setState(() {
//                   _bedtime = value;
//                 });
//               },
//               onChangeEnd: (value) => _saveBedtime(value),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Bedtime Reminder: ${_bedtime.round()}:00',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: _bedtime < 22 ? Colors.green : Colors.red,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
