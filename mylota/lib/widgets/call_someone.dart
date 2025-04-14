// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class CallSomeone extends StatelessWidget {
//   final String phoneNumber = "tel:+1234567890";
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       onPressed: () async {
//         if (await canLaunch(phoneNumber)) {
//           await launch(phoneNumber);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Could not launch phone call')),
//           );
//         }
//       },
//       icon: Icon(Icons.phone),
//       label: Text('Call Family/Friend'),
//     );
//   }
// }
