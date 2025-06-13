import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/main_screen.dart';


class LoginController {
  static Future<void> loginUser({
    required String email,
    required String password,
    required BuildContext context,
    required VoidCallback onStartLoading,
    required VoidCallback onStopLoading,
  }) async {
    print(email);
    print(password);

    try {
      onStartLoading();

      // Query Firestore
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        // User exists, attempt login
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        onStopLoading();

        print("User logged in: ${userCredential.user!.email}");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        onStopLoading();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User does not exist')),
        );
      }
    } catch (e) {
      onStopLoading();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging in: connection unreachable')),
      );
      print("Error: $e");
    }
  }
}


// class LoginController {
//   static Future<void> loginUser({required email, required password, required BuildContext context, required void Function() onStartLoading, required void Function() onStopLoading}) async {
//     print(email);
//     print(password);
//     try {
//       setState(() {
//         isLoading = true;
//       });
//       // Query Firestore to check if the user exists
//       QuerySnapshot userQuery = await FirebaseFirestore.instance
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .get();
//
//       if (userQuery.docs.isNotEmpty) {
//         // User exists, proceed with authentication
//         UserCredential userCredential =
//         await FirebaseAuth.instance.signInWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//         setState(() {
//           isLoading = false;
//         });
//         print("User logged in successfully: ${userCredential.user!.email}");
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => MainScreen(),
//           ),
//         );
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text(
//               'User does not exist',
//               style: AppStyle.cardSubtitle,
//             )));
//
//         print("User does not exist");
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(
//             "Error logging in: connection unreachable",
//             style: AppStyle.cardSubtitle,
//           )));
//       print("Error logging in: $e");
//     }
//   }
//
// }