import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mylota/screens/login_page.dart';

import '../utils/styles.dart';

class RegisterController {
  static Future<void> registerUser(
      String email,
      String password,
      String firstname,
      String lastname,
      String subscriptionType,
      String country,
      String address,
      String subscriptionAmount,
      String contact,
      {VoidCallback? onStartLoading, VoidCallback? onStopLoading,
      required BuildContext context}) async {
    try {
      onStartLoading!();
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

      // Create the subscription object
      final subscriptionData = {
        'type':
            subscriptionType, // assuming `subscription` is the selected type like "Basic"
        'amount': subscriptionAmount,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Store user details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'password': "",
        'firstname': firstname,
        'lastname': lastname,
        'subscription': subscriptionData,
        'nationality': country,
        'address': address,
        'uid': userCredential.user!.uid,
        'contact': contact,
        'createdAt': FieldValue.serverTimestamp(),
      });
      SnackBar(
        content:
            Text("User registered successfully", style: AppStyle.cardfooter),
      );
      onStopLoading!();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      onStopLoading!();
      SnackBar(
        content: Text("Error registering user: $e", style: AppStyle.cardfooter),
      );
    }
  }
}

// await FirebaseFirestore.instance
//     .collection('users')
// .doc(userId)
//     .update({
// 'subscription.type': newSubscription,
// 'subscription.updatedAt': FieldValue.serverTimestamp(),
// });
