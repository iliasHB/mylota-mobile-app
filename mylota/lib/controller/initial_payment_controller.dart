import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<PaystackResponse?> createPaystackTransaction(String email, String amount) async {
  try {
    String priceWithSymbol = amount;
    String cleanedPrice = priceWithSymbol.replaceAll(RegExp(r'[^\d.]'), '');
    double amountDouble = double.parse(cleanedPrice);
    int amountInMinorUnit = (amountDouble * 100).round();
    print("amount: $amountInMinorUnit");
    final response = await http.post(
      Uri.parse('https://api.paystack.co/transaction/initialize'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer sk_test_e54bf2f6ed0da3e19e8749c2e01961ba62cd13fc', // Replace with your key
      },
      body: jsonEncode({
        'email': email,
        'amount': amountInMinorUnit, // Must be in kobox
      }),
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

  const PaystackResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PaystackResponse.fromJson(Map<String, dynamic> json) => PaystackResponse(
    status: json["status"],
    message: json["message"],
    data: DataModel.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}


class DataModel {
  final String authorization_url;
  final String access_code;
  final String reference;

  const DataModel({
    required this.authorization_url,
    required this.access_code,
    required this.reference,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) => DataModel(
    authorization_url: json["authorization_url"],
    access_code: json["access_code"],
    reference: json["reference"],
  );

  Map<String, dynamic> toJson() => {
    "authorization_url": authorization_url,
    "access_code": access_code,
    "reference": reference,
  };
}



// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() {
//     return _MyAppState();
//   }
// }
//
// class _MyAppState extends State<MyApp> {
//   final TextEditingController _controller = TextEditingController();
//   Future<Response>? _futureAlbum;
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Create Data Example',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Create Data Example')),
//         body: Container(
//           alignment: Alignment.center,
//           padding: const EdgeInsets.all(8),
//           child: (_futureAlbum == null) ? buildColumn() : buildFutureBuilder(),
//         ),
//       ),
//     );
//   }
//
//   Column buildColumn() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         TextField(
//           controller: _controller,
//           decoration: const InputDecoration(hintText: 'Enter Title'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             setState(() {
//               _futureAlbum = createAlbum(_controller.text);
//             });
//           },
//           child: const Text('Create Data'),
//         ),
//       ],
//     );
//   }
//
//   FutureBuilder<Response> buildFutureBuilder() {
//     return FutureBuilder<Response>(
//       future: _futureAlbum,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return Text(snapshot.data!.title);
//         } else if (snapshot.hasError) {
//           return Text('${snapshot.error}');
//         }
//
//         return const CircularProgressIndicator();
//       },
//     );
//   }
// }