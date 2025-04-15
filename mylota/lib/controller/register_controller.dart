import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mylota/screens/login_page.dart';

import '../utils/styles.dart';

class RegisterController {
  static Future<void> registerUser(String email, String password,
      String firstname, lastname, subscription, country, address,
      {required VoidCallback onStartLoading,
      required VoidCallback onStopLoading, required BuildContext context}) async {
    try {
      onStartLoading();
      // Check if user already exists in Firebase Authentication
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

      if (methods.isNotEmpty) {
        SnackBar(
          content: Text("User Already exist", style: AppStyle.cardfooter),
        );
        return; // Stop function execution
      }
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'password': password,
        'firstname': firstname,
        'lastname': lastname,
        'subscription': subscription,
        'nationality': country,
        'address': address,
        'uid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      SnackBar(
        content:
            Text("User registered successfully", style: AppStyle.cardfooter),
      );
      onStopLoading();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      SnackBar(
        content: Text("Error registering user: $e", style: AppStyle.cardfooter),
      );
    }
  }
}
