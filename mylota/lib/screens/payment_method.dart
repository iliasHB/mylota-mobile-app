import 'package:flutter/material.dart';
import 'package:mylota/screens/paystack_web_view.dart';

import '../controller/initial_payment_controller.dart';
import '../utils/styles.dart';
import '../widgets/custom_button.dart';

// class PaymentGateway extends StatelessWidget {
//   final String email, price;
//   const PaymentGateway({
//     super.key,
//     required this.email,
//     required this.price,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Align(
//       alignment: Alignment.topCenter,
//       child: PaymentMethod(email: email, price: price)
//       // Container(
//       //     constraints: BoxConstraints(
//       //         maxHeight: MediaQuery.of(context).size.height * 0.65),
//       //     width: double.infinity,
//       //     margin: const EdgeInsets.only(top: 50),
//       //     decoration: BoxDecoration(
//       //       color: Colors.white,
//       //       borderRadius: BorderRadius.circular(15),
//       //     ),
//       //     child: PaymentMethod(email: email, price: price)),
//     ));
//   }
// }

class PaymentGateway extends StatefulWidget {
  final String email;
  final String price;
  const PaymentGateway({super.key, required this.email, required this.price});

  @override
  State<PaymentGateway> createState() => _PaymentGatewayState();
}

class _PaymentGatewayState extends State<PaymentGateway> {
  bool isPaystackChecked = false;
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        // Image.asset(
                        //   "assets/images/naira.png",
                        //   height: 20,
                        //   width: 20,
                        // ),
                        Text(
                          widget.price,
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
                Row(
                  children: [
                    Expanded(
                      child: CustomPrimaryButton(
                        label: 'Proceed to pay',
                        onPressed: () {
                          if (!isPaystackChecked) {
                            // Show snackbar if checkbox is not checked
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
                          } else {
                            // setState(() {
                            //   response = createPaystackTransaction(widget.email, widget.price);
                            //
                            //   response == null ? Container() : buildFutureBuilder();
                            //
                            // });
                            initiatePayment();
                            // / if (_formKey.currentState?.validate() ?? false) {
                            // final loginReqEntity = InitiatePaymentReqEntity(
                            //   email: widget.email,
                            //   quantity: widget.quantity,
                            //   contact_phone: widget.contact,
                            //   delivery_address: widget.address,
                            //   location_id: widget.locationId,
                            //   product_id: widget.productId,
                            // );
                            // context
                            //     .read<InitiatePaymentBloc>()
                            //     .add(InitiatePaymentEvent(loginReqEntity));
                          }

                          // }
                        },
                      ),
                    ),
                  ],
                ),
                // BlocConsumer<InitiatePaymentBloc, EshopState>(
                //   listener: (context, state) {
                //     if (state is InitiatePaymentDone) {
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (_) => PayStackWebView(
                //                     auth_url: state.resp.authorization_url,
                //                     callbackUrl: '',
                //                   )));
                //     } else if (state is EshopFailure) {
                //       ScaffoldMessenger.of(context)
                //           .showSnackBar(SnackBar(content: Text(state.message)));
                //     }
                //   },
                //   builder: (context, state) {
                //     if (state is EshopLoading) {
                //       return const Center(
                //           child: CustomContainerLoadingButton());
                //     }
                //     return Row(
                //       children: [
                //         Expanded(
                //           child: CustomPrimaryButton(
                //             label: 'Proceed to pay',
                //             onPressed: () {
                //               if (!isPaystackChecked) {
                //                 // Show snackbar if checkbox is not checked
                //                 ScaffoldMessenger.of(context).showSnackBar(
                //                   SnackBar(
                //                     content: Text(
                //                         "Please select a payment method.", style: AppStyle.cardfooter,),
                //                     backgroundColor: Colors.black,
                //                     duration: const Duration(seconds: 2),
                //                   ),
                //                 );
                //               } else {
                //                 // / if (_formKey.currentState?.validate() ?? false) {
                //                 final loginReqEntity = InitiatePaymentReqEntity(
                //                   email: widget.email,
                //                   quantity: widget.quantity,
                //                   contact_phone: widget.contact,
                //                   delivery_address: widget.address,
                //                   location_id: widget.locationId,
                //                   product_id: widget.productId,
                //                 );
                //                 context
                //                     .read<InitiatePaymentBloc>()
                //                     .add(InitiatePaymentEvent(loginReqEntity));
                //               }
                //
                //               // }
                //             },
                //           ),
                //         ),
                //       ],
                //     );
                //   },
                // ),
                ///
                // const SizedBox(
                //   height: 10,
                // ),
                //
                // CustomSecondaryButton(
                //     label: 'Cancel', onPressed: () => Navigator.pop(context))
              ],
            )
          ],
        )),
      ),
    );
  }

  void initiatePayment() async {
    final result = await createPaystackTransaction('user@example.com', '100000');
    if (result != null) {
      final url = result.data.authorization_url;
      print("Redirect user to Paystack URL: $url");
      // You can launch with `url_launcher`
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PayStackWebView(
                          auth_url: result.data.authorization_url,
                          callbackUrl: '',
                      reference: result.data.reference
                        )));
    } else {
      print("Transaction failed to initialize.");
    }
  }


///--------------------
  // FutureBuilder<Response> buildFutureBuilder() {
  //   return FutureBuilder<Response>(
  //     future: response,
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         return Text(snapshot.data!.message);
  //       } else if (snapshot.hasError) {
  //         return Text('${snapshot.error}');
  //       }
  //
  //       return const CircularProgressIndicator();
  //     },
  //   );
  // }
}
