import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mylota/screens/payment_selection_screen.dart';
import 'package:mylota/widgets/custom_button.dart';

import '../screens/payment_method.dart';
import '../utils/styles.dart';

class SubscriptionAlert extends StatefulWidget {
  final String email;
  const SubscriptionAlert(
      {super.key,
      required this.email});

  @override
  State<SubscriptionAlert> createState() => _SubscriptionAlertState();
}

class _SubscriptionAlertState extends State<SubscriptionAlert> {
  List<Map<String, dynamic>> subscriptionPlans = [];

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection("user-inputs")
          .doc("yQtkG0iE0dA0tcrQ8RAW") // replace with actual doc ID
          .get();

      if (docSnapshot.exists) {
        List<dynamic> subscription = docSnapshot["subscriptions"];

        setState(() {
          // subscriptionPlans = subscription.map((item) => item["Type"].toString()).toList();
          subscriptionPlans = List<Map<String, dynamic>>.from(subscription);

          if (subscriptionPlans.isNotEmpty) {
            // selectedPlan = subscriptionPlans.first;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error fetching dropdown data: ${e.toString()}')));
      print("Error fetching dropdown data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png', // Path to your logo
                  width: 60,
                  height: 60,
                ),
                Text(
                  'MyLota',
                  style: AppStyle.cardTitle,
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              '🔔 Subscription Expired',
              style: AppStyle.cardTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 20,),
            Text(
              'Your current subscription has expired. '
              'To continue enjoying our services, '
              'please renew your subscription or upgrade to a new plan.',
              textAlign: TextAlign.center,
              style: AppStyle.cardfooter.copyWith(fontSize: 18, fontWeight: FontWeight.w200),
            ),
            const SizedBox(height: 10,),
            Text(
              subscriptionPlans.isNotEmpty ? "${subscriptionPlans[0]['Amount']} per month - Basic plan" : "",
              textAlign: TextAlign.center,
              style: AppStyle.cardfooter.copyWith(fontSize: 20, color: Colors.purple),
            ),
            Text(
              subscriptionPlans.isNotEmpty ? "${subscriptionPlans[1]['Amount']} per month - Premium plan" : "",
              textAlign: TextAlign.center,
              style: AppStyle.cardfooter.copyWith(fontSize: 20, color: Colors.purple),
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomPrimaryButton(
                      label: 'Basic Plan',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentSelectionScreen(
                              amount: subscriptionPlans[0]['Amount'],
                              productName: '${subscriptionPlans[0]['Type']} Subscription',
                              productType: 'subscription',
                              email: widget.email,  // Pass email
                              planDescription: subscriptionPlans[0]['Description'], // Pass description
                            ),
                          ),
                        );

                      }),
                ),
                const SizedBox(width: 20,),
                Expanded(
                  child: CustomSecondaryButton(
                      label: 'Premium Plan',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentGateway(
                            email: widget.email,
                            price: subscriptionPlans[1]['Amount'],
                            description: subscriptionPlans[1]['Description'],
                            type: subscriptionPlans[1]['Type'])));

                      }),
                ),

              ],
            ),
            SizedBox(height: 10,),
            CustomSecondaryButton(
                label: 'Go Back',
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
    );
  }
}
