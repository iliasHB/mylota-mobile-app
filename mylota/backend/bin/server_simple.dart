// import 'dart:convert';
// import 'dart:io';
// import 'package:shelf/shelf.dart';
// import 'package:shelf/shelf_io.dart';
// import 'package:shelf_router/shelf_router.dart';
// import 'package:shelf_cors_headers/shelf_cors_headers.dart';
// import 'package:http/http.dart' as http;
// import 'package:dotenv/dotenv.dart';
//
// void main() async {
//   final env = DotEnv()..load();
//   final stripeSecretKey = env['STRIPE_SECRET_KEY']!;
//
//   final router = Router();
//
//   // Simple payment intent creation using HTTP calls
//   router.post('/create-payment-intent', (Request request) async {
//     try {
//       final body = await request.readAsString();
//       final data = jsonDecode(body) as Map<String, dynamic>;
//
//       if (!data.containsKey('amount') || !data.containsKey('email')) {
//         return Response(
//           400,
//           body: jsonEncode({'error': 'Missing required fields: amount, email'}),
//           headers: {'Content-Type': 'application/json'},
//         );
//       }
//
//       final amount = data['amount'] as int;
//       final currency = data['currency'] as String? ?? 'usd';
//       final email = data['email'] as String;
//       final description = data['description'] as String? ?? 'Mylota Fitness Subscription';
//       final metadata = data['metadata'] as Map<String, dynamic>? ?? {};
//
//       // Call Stripe API directly
//       final response = await http.post(
//         Uri.parse('https://api.stripe.com/v1/payment_intents'),
//         headers: {
//           'Authorization': 'Bearer $stripeSecretKey',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: {
//           'amount': amount.toString(),
//           'currency': currency,
//           'description': description,
//           'receipt_email': email,
//           'metadata[email]': email,
//           'metadata[type]': metadata['type'] ?? 'subscription',
//           'metadata[firstname]': metadata['firstname'] ?? '',
//           'metadata[lastname]': metadata['lastname'] ?? '',
//           'metadata[app]': 'mylota_fitness',
//           'automatic_payment_methods[enabled]': 'true',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final paymentIntent = jsonDecode(response.body);
//         print('✅ Payment Intent created: ${paymentIntent['id']} for $email');
//
//         return Response.ok(
//           jsonEncode({
//             'client_secret': paymentIntent['client_secret'],
//             'payment_intent_id': paymentIntent['id'],
//             'status': 'success',
//           }),
//           headers: {'Content-Type': 'application/json'},
//         );
//       } else {
//         throw Exception('Stripe API error: ${response.body}');
//       }
//     } catch (e) {
//       print('❌ Error creating payment intent: $e');
//       return Response(
//         500,
//         body: jsonEncode({
//           'error': 'Failed to create payment intent',
//           'message': e.toString()
//         }),
//         headers: {'Content-Type': 'application/json'},
//       );
//     }
//   });
//
//   router.get('/health', (Request request) {
//     return Response.ok(
//       jsonEncode({'status': 'healthy', 'service': 'mylota-payment-server'}),
//       headers: {'Content-Type': 'application/json'},
//     );
//   });
//
//   final handler = Pipeline()
//       .addMiddleware(corsHeaders())
//       .addMiddleware(logRequests())
//       .addHandler(router);
//
//   final port = int.parse(env['PORT'] ?? '8080');
//   final server = await serve(handler, InternetAddress.anyIPv4, port);
//
//   print('🚀 Mylota Payment Server (Simple) running on http://localhost:${server.port}');
// }