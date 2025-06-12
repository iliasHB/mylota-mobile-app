
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'verify_payment_controller.dart';

class TransactionController {
  static Future<void> saveTransactions(DataModel data) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in!");
        // onStopLoading();
        return;
      }
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(user.uid)
          .collection('user_transactions')
          .add({
        'reference': data.reference,
        'status': data.status,
        'amount': data.amount,
        'amount_display': (data.amount / 100).toStringAsFixed(2),
        'currency': data.currency,
        'gatewayResponse': data.gatewayResponse,
        'paidAt': data.paidAt,
        'createdAt': data.createdAt,
        'savedAt': DateTime.now().toIso8601String(),
      });

      print("Transaction saved successfully");
    } catch (e) {
      print("exeception: "+e.toString());
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Failed to save tasks. Please try again.'),
      //     backgroundColor: Colors.red,
      //     duration: Duration(seconds: 2),
      //   ),
      // );
    }
  }
}