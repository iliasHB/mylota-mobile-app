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

      // Calculate expiredAt based on the subscription amount
      DateTime expiredAt;
      if (subscriptionAmount == "0.00") {
        expiredAt = DateTime.now().add(const Duration(days: 7));
      } else {
        // For 1 month, add 30 days (or use DateTime extension for better accuracy if you want)
        expiredAt = DateTime.now().add(const Duration(days: 30));
      }

     // Create the subscription object
      final subscriptionData = {
        'type': subscriptionType, // assuming `subscription` is the selected type like "Basic"
        'amount': subscriptionAmount,
        'createdAt': DateTime.now().toIso8601String(),
        'expiredAt': expiredAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
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
        'image': "",
        'subscription': subscriptionData,
        'nationality': country,
        'address': address,
        'uid': userCredential.user!.uid,
        'contact': contact,
        'createdAt': DateTime.now().toIso8601String(),//FieldValue.serverTimestamp(),
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
