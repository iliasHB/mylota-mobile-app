import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:mylota/utils/constants.dart';

import '../../models/payment_intent.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<void> makePayment (String email, String price, BuildContext context) async {
    try {
      PaymentIntentModel? result = await createPaymentIntent(int.parse(price), "usd", context);
      if(result?.clientSecret == null) return;
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: result?.clientSecret,
            merchantDisplayName: email,
          ));
      await processPayment();
    } catch (e){
      print(e);
    }
  }

  Future<PaymentIntentModel?> createPaymentIntent(int amount, String currency, context) async {
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
      final jsonData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentIntentModel.fromJson(jsonData);
      } else {
        // Stripe error
        if (jsonData is Map && jsonData.containsKey('error')) {
          String errorMessage = jsonData['error']['message'] ?? 'Unknown error occurred';
          print("Stripe Error: $errorMessage");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
          // You can also show a dialog or snackbar here
        } else {
          print("Unexpected error: ${response.body}");
        }
        return null;
      }
    } catch(e){
      print(e);
    }
    return null;
  }

  Future<void> processPayment() async{
    try {
      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();
    } catch (e){
      print(e);
    }
  }

  String calculateAmount (int amount) {
    int calc = amount * 100;
    return calc.toString();
  }
}

