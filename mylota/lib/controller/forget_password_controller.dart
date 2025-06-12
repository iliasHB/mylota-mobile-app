
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mylota/screens/login_page.dart';

import '../screens/main_screen.dart';


class ForgetPwdController {
  static Future<void> resetPwd({
    required String email,
    required BuildContext context,
    required VoidCallback onStartLoading,
    required VoidCallback onStopLoading,
  }) async {
    try {
      onStartLoading();

      // Query Firestore
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        // User exists, attempt login
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent')));

        onStopLoading();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
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
        const SnackBar(content: Text('Error logging in: connection unreachable')),
      );
      print("Error: $e");
    }
  }
}

