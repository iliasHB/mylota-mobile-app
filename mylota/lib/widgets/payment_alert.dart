import 'package:flutter/material.dart';

import '../screens/login_page.dart';
import '../utils/styles.dart';


class PaymentAlert extends StatelessWidget {
  final bool isSuccess;
  const PaymentAlert({super.key, required this.isSuccess,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          isSuccess ? const Icon(
            Icons.check,
            size: 150,
            color: Colors.green,
          ) : const Icon(
            Icons.cancel_outlined,
            size: 150,
            color: Colors.red,
          ),
          const SizedBox(
            height: 30,
          ),
          isSuccess ? Text(
            "Payment Successful",
            style: AppStyle.cardTitle
                .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ) : Text(
            "Payment Failed",
            style: AppStyle.cardTitle
                .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          // Text(
          //   pageRoute == "service"
          //       ? desc!
          //       : "Your ordered is confirmed. You will receive a confirmation email shortly with your order details",
          //   style: AppStyle.cardTitle.copyWith(fontWeight: FontWeight.w400),
          //   textAlign: TextAlign.center,
          // ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                    onPressed: () =>
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage())),
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        "Continue",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
