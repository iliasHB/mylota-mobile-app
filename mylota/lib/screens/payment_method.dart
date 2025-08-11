import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mylota/screens/paystack_web_view.dart';
import '../core/services/initial_payment_service.dart';
import '../core/services/stripe_service.dart';
import '../utils/styles.dart';
import '../widgets/custom_button.dart';

class PaymentGateway extends StatefulWidget {
  final String email,
      price,
      description,
      type;
  final String? contact,
      password,
      firstname,
      lastname,
      country,
      address;
  const PaymentGateway(
      {super.key,
      required this.email,
      required this.price,
      required this.description,
      required this.type,
        this.password,
        this.firstname,
        this.lastname,
        this.country,
        this.address,
        this.contact});

  @override
  State<PaymentGateway> createState() => _PaymentGatewayState();
}

class _PaymentGatewayState extends State<PaymentGateway> {
  bool isPaystackChecked = false;
  bool isStripeChecked = false;
  bool isProcessing = false;
  Future<PaystackResponse>? response;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("assets/images/atm.png"),
            const Text(
              "Choose choice of payment",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                // Paystack Option
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.asset("assets/images/Paystack.png"),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text("Paystack", style: AppStyle.cardSubtitle),
                      const Spacer(),
                      Checkbox(
                        value: isPaystackChecked,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            isPaystackChecked = value ?? false;
                            if (isPaystackChecked) {
                              isStripeChecked = false; // Uncheck Stripe
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // Stripe Option
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.credit_card,
                          color: Colors.blue[800],
                          size: 24,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text("Stripe (Card Payment)", style: AppStyle.cardSubtitle),
                      const Spacer(),
                      Checkbox(
                        value: isStripeChecked,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          setState(() {
                            isStripeChecked = value ?? false;
                            if (isStripeChecked) {
                              isPaystackChecked = false; // Uncheck Paystack
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Amount to pay", style: AppStyle.cardSubtitle),
                    const SizedBox(
                      width: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "\$" + widget.price,
                          style: AppStyle.cardSubtitle
                              .copyWith(color: Colors.green),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  widget.description,
                  style: AppStyle.cardfooter,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomPrimaryButton(
                        label: isProcessing ? 'Processing...' : 'Proceed to pay',
                        onPressed: isProcessing ? null : () {
                          if (!isPaystackChecked && !isStripeChecked) {
                            // Show snackbar if no payment method is selected
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please select a payment method.",
                                  style: AppStyle.cardfooter,
                                ),
                                backgroundColor: Colors.black,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else if (isPaystackChecked) {
                            // Process Paystack payment
                            initiatePaystackPayment(
                                widget.email,
                                widget.price,
                                widget.contact!,
                                widget.password!,
                                widget.country!,
                                widget.address!,
                                widget.type,
                                widget.firstname!,
                                widget.lastname!);
                          } else if (isStripeChecked) {
                            initiateStripePayment(widget.email, widget.price, context);
                            // Process Stripe payment
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        )),
      ),
    );
  }

  void initiateStripePayment(String email, String price, BuildContext context){
    try {
      setState(() {
        isProcessing = true;
      });
      StripeService.instance.makePayment(
          email, price, context);
    } catch(e){
      print("Paystack error: $e");
      _showErrorSnackBar("Payment failed. Please try again.");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  // Existing Paystack payment method (renamed for clarity)
  void initiatePaystackPayment(
      email,
      amount,
      String contact,
      String password,
      String country,
      String address,
      String type,
      String firstname,
      String lastname) async {
    
    setState(() {
      isProcessing = true;
    });

    try {
      final result = await createPaystackTransaction(email, amount);
      if (result != null) {
        final url = result.data.authorization_url;
        print("Redirect user to Paystack URL: $url");
        
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PayStackWebView(
                    auth_url: result.data.authorization_url,
                    callbackUrl: '',
                    reference: result.data.reference,
                    email: email,
                    amount: amount,
                    contact: contact,
                    address: address,
                    type: type,
                    firstname: firstname,
                    lastname: lastname,
                  password: password,
                  country: country
                )));
      } else {
        print("Paystack transaction failed to initialize.");
        _showErrorSnackBar("Payment initialization failed. Please try again.");
      }
    } catch (e) {
      print("Paystack error: $e");
      _showErrorSnackBar("Payment failed. Please try again.");
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  // // Create payment intent (you'll need to implement this on your backend)
  // Future<String> _createPaymentIntent(int amount, String currency) async {
  //   try {
  //     // Use your actual IP address from ipconfig
  //     const String backendUrl = 'http://10.0.2.2:8081';
  //
  //     print('🔄 Attempting to connect to: $backendUrl/create-payment-intent');
  //     print('💰 Amount: $amount cents');
  //     print('💱 Currency: $currency');
  //     print('📧 Email: ${widget.email}');
  //
  //     final requestBody = {
  //       'amount': amount,
  //       'currency': currency,
  //       'email': widget.email,
  //       'description': widget.description,
  //       'metadata': {
  //         'type': widget.type,
  //         'firstname': widget.firstname ?? '',
  //         'lastname': widget.lastname ?? '',
  //       }
  //     };
  //
  //     print('📤 Request body: ${json.encode(requestBody)}');
  //
  //     final response = await http.post(
  //       Uri.parse('$backendUrl/create-payment-intent'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode(requestBody),
  //     ).timeout(Duration(seconds: 60)); // Increase timeout to 60 seconds
  //
  //     print('💳 Payment intent request sent to: $backendUrl/create-payment-intent');
  //     print('📊 Response status: ${response.statusCode}');
  //     print('📊 Response body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       print('✅ Payment intent created successfully');
  //       print('🔑 Client secret: ${data['client_secret'].substring(0, 20)}...');
  //       return data['client_secret'];
  //     } else {
  //       print('❌ Server error: ${response.statusCode} - ${response.body}');
  //       throw Exception('Server returned ${response.statusCode}: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('❌ Error creating payment intent: $e');
  //     print('🔍 Error type: ${e.runtimeType}');
  //     rethrow; // Re-throw to maintain the original error
  //   }
  // }
  //
  // Future<void> _handleSuccessfulPayment() async {
  //   // TODO: Implement your success logic here
  //   // - Save payment record to database
  //   // - Update user subscription status
  //   // - Navigate to success screen
  //   // - Send confirmation email, etc.
  //
  //   print('Payment successful for ${widget.email}');
  //   print('Amount: ${widget.price}');
  //   print('Type: ${widget.type}');
  //
  //   // Navigate back or to success screen
  //   Navigator.pop(context, true); // Return true to indicate success
  // }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppStyle.cardfooter),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppStyle.cardfooter),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Commented out the old initiate payment method
  /*
  void initiatePayment(
      email,
      amount,
      String contact,
      String password,
      String country,
      String address,
      String type,
      String firstname,
      String lastname) async {
    final result =
        await createPaystackTransaction(email, amount);
    if (result != null) {
      final url = result.data.authorization_url;
      print("Redirect user to Paystack URL: $url");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PayStackWebView(
                  auth_url: result.data.authorization_url,
                  callbackUrl: '',
                  reference: result.data.reference,
                  email: email,
                  amount: amount,
                  contact: contact,
                  address: address,
                  type: type,
                  firstname: firstname,
                  lastname: lastname,
                password: password,
                country: country
              )));
    } else {
      print("Transaction failed to initialize.");
    }
  }
  */
}
