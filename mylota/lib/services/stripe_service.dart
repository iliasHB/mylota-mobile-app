import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:mylota/utils/constants.dart';

import '../models/payment_intent.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<void> makePayment () async {
    try {
      PaymentIntentModel? result = await createPaymentIntent(10, "usd");
      if(result?.clientSecret == null) return;
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: result?.clientSecret,
            merchantDisplayName: "Habeeb Soliu"
          ));
      await processPayment();
    } catch (e){
      print(e);
    }
  }

  Future<PaymentIntentModel?> createPaymentIntent(int amount, String currency) async {
    try {
      Map<String, dynamic> data = {
        "amount": calculateAmount(amount),
        "currency": currency,
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: data,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $stripeSecretKey', // Replace with your key
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return PaymentIntentModel.fromJson(jsonData);
      }
      // if(response.body != null){
      //   print(response.body);
      //   return response.body;
      // }
      return null;
    } catch(e){
      print(e);
    }
    return null;
  }

  Future<void> processPayment() async{
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e){
      print(e);
    }
  }

  String calculateAmount (int amount) {
    int calc = amount * 100;
    return calc.toString();
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// // import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
//
// class StripeService {
//   static const String _baseUrl = '192.168.0.5:8081'; // Your Dart backend URL
//
//   // Create Payment Intent using Dart backend
//   static Future<Map<String, dynamic>> createPaymentIntent({
//     required int amount, // Amount in cents
//     required String currency,
//     String? customerId,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/create-payment-intent'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'amount': amount,
//           'currency': currency,
//           'customer': customerId,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else {
//         final error = jsonDecode(response.body);
//         throw Exception('Failed to create payment intent: ${error['error']}');
//       }
//     } catch (e) {
//       throw Exception('Error creating payment intent: $e');
//     }
//   }
//
//   // Create Customer using Dart backend
//   static Future<Map<String, dynamic>> createCustomer({
//     required String email,
//     String? name,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/create-customer'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'email': email,
//           'name': name,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else {
//         final error = jsonDecode(response.body);
//         throw Exception('Failed to create customer: ${error['error']}');
//       }
//     } catch (e) {
//       throw Exception('Error creating customer: $e');
//     }
//   }
//
//   // Initialize Payment Sheet
//   static Future<void> initPaymentSheet({
//     required String paymentIntentClientSecret,
//     required String merchantDisplayName,
//     String? customerId,
//     String? customerEphemeralKeySecret,
//   }) async {
//     try {
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntentClientSecret,
//           merchantDisplayName: merchantDisplayName,
//           customerId: customerId,
//           customerEphemeralKeySecret: customerEphemeralKeySecret,
//           style: ThemeMode.system,
//           billingDetails: const BillingDetails(
//             name: 'Customer Name',
//             email: 'customer@example.com',
//           ),
//         ),
//       );
//     } catch (e) {
//       throw Exception('Error initializing payment sheet: $e');
//     }
//   }
//
//   // Present Payment Sheet
//   static Future<void> presentPaymentSheet() async {
//     try {
//       await Stripe.instance.presentPaymentSheet();
//     } catch (e) {
//       if (e is StripeException) {
//         throw Exception('Payment cancelled: ${e.error.localizedMessage}');
//       } else {
//         throw Exception('Error presenting payment sheet: $e');
//       }
//     }
//   }
//
//   // Complete payment flow
//   static Future<bool> makePayment({
//     required int amount,
//     required String currency,
//     required String merchantDisplayName,
//     String? customerId,
//   }) async {
//     try {
//       // Step 1: Create Payment Intent
//       final paymentIntentData = await createPaymentIntent(
//         amount: amount,
//         currency: currency,
//         customerId: customerId,
//       );
//
//       // Step 2: Initialize Payment Sheet
//       await initPaymentSheet(
//         paymentIntentClientSecret: paymentIntentData['client_secret'],
//         merchantDisplayName: merchantDisplayName,
//         customerId: customerId,
//       );
//
//       // Step 3: Present Payment Sheet
//       await presentPaymentSheet();
//
//       return true;
//     } catch (e) {
//       print('Payment failed: $e');
//       return false;
//     }
//   }
// }