import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controller/verify_payment_controller.dart';
import '../widgets/payment_alert.dart';

class PayStackWebView extends StatefulWidget {
  final String auth_url, callbackUrl, reference;
  const PayStackWebView(
      {super.key,
        required this.auth_url,
        required this.callbackUrl,
        required this.reference});

  @override
  State<PayStackWebView> createState() => _PayStackWebViewState();
}

class _PayStackWebViewState extends State<PayStackWebView> {
  late final WebViewController controller;
  var loadingPercentage = 0;
  List<String>? userMeterInfo;
  bool reprint = false;
  // var meter_number;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          print('onPageStarted: $url');
          if (mounted) {
            setState(() {
              loadingPercentage = 0;
            });
          }
        },
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              loadingPercentage = progress;
            });
          }
        },
        onPageFinished: (url) {
          print('onPageFinished: $url');
          if (mounted) {
            setState(() {
              loadingPercentage = 100;
            });
          }
        },
        onNavigationRequest: (navigation) {
          final host = Uri.parse(navigation.url).host;
          final address = Uri.parse(navigation.url);
          print("host: ${host}");
          print("address: ${address}");
          debugPrint(">>>>>>>> callbackUrl: ${widget.callbackUrl}");
          if (host.contains('https://standard.paystack.co/close')) {
            //Navigator.of(context).pop(); //close webview
          }
          if (host.toString().contains(widget.callbackUrl) ||
              address.toString().contains(widget.callbackUrl)) {
            print("-----------------verify payment here--------------------");
            // Navigator.of(context).pop();
            verifyPayment(widget.reference, context);
          }
          return NavigationDecision.navigate;
        },
      ))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(widget.auth_url),
      )
      ..setUserAgent('Paystack;Webview');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          elevation: 0,
          title: const Text('Paystack Payment'),
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back))),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            WebViewWidget(
              controller: controller,
            ),
            if (loadingPercentage < 100)
              LinearProgressIndicator(
                value: loadingPercentage / 100.0,
              ),
          ],
        ),
      ),
    );
  }
}


void verifyPayment(String reference, BuildContext context) async {
  final result = await verifyPaystackTransaction(reference);

  if (result != null && result.status && result.data.status == "success") {
    print("Payment verified for ${result.data.reference}");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const PaymentAlert(isSuccess: true)));
  } else {
    print("Payment verification failed.");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const PaymentAlert(isSuccess: false)));
  }
}
