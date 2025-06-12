// https://api.paystack.co/transaction/verify/:reference
import 'dart:convert';

import 'package:http/http.dart' as http;


Future<PaystackResponse?> verifyPaystackTransaction(String reference) async {
  try {
    final response = await http.get(
      Uri.parse('https://api.paystack.co/transaction/verify/$reference'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer sk_test_e54bf2f6ed0da3e19e8749c2e01961ba62cd13fc', // Replace with your key
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return PaystackResponse.fromJson(jsonData);
    } else {
      print("Failed: ${response.statusCode} - ${response.body}");
      return null;
    }
  } catch (e) {
    print("Exception occurred: ${e.toString()}");
    return null;
  }
}


class PaystackResponse {
  final bool status;
  final String message;
  final DataModel data;

  const PaystackResponse({required this.status, required this.message, required this.data});

  factory PaystackResponse.fromJson(Map<String, dynamic> json) => PaystackResponse(
    status: json["status"],
    message: json["message"],
    data: DataModel.fromJson(json["data"]),
  );
}


class DataModel {
  final String status;
  final String reference;
  final int amount;
  final String gatewayResponse;
  final String paidAt;
  final String createdAt;
  final String currency;

  const DataModel({
    required this.status,
    required this.reference,
    required this.amount,
    required this.gatewayResponse,
    required this.paidAt,
    required this.createdAt,
    required this.currency,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      status: json["status"],
      reference: json["reference"],
      amount: json["amount"],
      gatewayResponse: json["gateway_response"],
      paidAt: json["paid_at"],
      createdAt: json["created_at"],
      currency: json["currency"],
    );
  }
}
