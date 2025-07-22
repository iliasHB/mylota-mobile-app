import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

// Change from 172.16.11.123 to 169.254.177.96
const String backendUrl = 'http://192.168.0.5:8081';

void main() async {
  // Load environment variables - FIXED
  final env = DotEnv(); // Don't load the corrupted file
  
  // TEMPORARY: Hardcode the fresh key for testing
  const port = '8081';

  // Debug: Print loaded values (without exposing the full key)
  print('📋 Environment variables status:');
  print('  STRIPE_SECRET_KEY: ${stripeSecretKey.isNotEmpty ? 'loaded (${stripeSecretKey.length} chars)' : 'NOT FOUND'}');
  print('  PORT: $port');
  
  // Enhanced debugging
  if (stripeSecretKey.isNotEmpty) {
    print('🔍 Stripe key details:');
    print('  Length: ${stripeSecretKey.length}');
    print('  Starts with: ${stripeSecretKey.substring(0, 10)}...');
    print('  Ends with: ...${stripeSecretKey.substring(stripeSecretKey.length - 4)}');
  }
  
  // Clean the key (remove any whitespace/newlines)
  final cleanStripeKey = stripeSecretKey.trim();
  
  // Check if Stripe key is loaded
  if (cleanStripeKey.isEmpty) {
    print('❌ STRIPE_SECRET_KEY not found in .env file!');
    print('📁 Make sure .env file exists in backend folder');
    print('📄 Current directory: ${Directory.current.path}');
    print('📄 .env file exists: ${File('.env').existsSync()}');
    if (File('.env').existsSync()) {
      print('📄 .env file content:');
      try {
        final content = File('.env').readAsStringSync();
        print(content.replaceAll(RegExp(r'sk_[a-zA-Z0-9_]+'), 'sk_***HIDDEN***'));
      } catch (e) {
        print('Error reading .env file: $e');
      }
    }
    exit(1);
  }
  
  // Validate key format
  if (!cleanStripeKey.startsWith('sk_test_') && !cleanStripeKey.startsWith('sk_live_')) {
    print('❌ Invalid Stripe key format! Key should start with sk_test_ or sk_live_');
    print('🔍 Current key starts with: ${cleanStripeKey.substring(0, 10)}');
    exit(1);
  }
  
  print('✅ Valid Stripe key loaded. Length: ${cleanStripeKey.length}');
  print('🔑 Key validated and ready to use');
  
  final router = Router();

  // Enhanced Create Payment Intent endpoint for Mylota
  router.post('/create-payment-intent', (Request request) async {
    print('📥 Received payment intent request');
    print('📍 Request method: ${request.method}');
    print('📍 Request headers: ${request.headers}');
    
    try {
      final body = await request.readAsString();
      print('📍 Request body received: $body');
      
      final data = jsonDecode(body) as Map<String, dynamic>;
      print('📍 Parsed data: $data');
      
      // Validate required fields
      if (!data.containsKey('amount') || !data.containsKey('email')) {
        return Response(
          400,
          body: jsonEncode({'error': 'Missing required fields: amount, email'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      final amount = data['amount'] as int;
      final currency = data['currency'] as String? ?? 'usd';
      final email = data['email'] as String;
      final description = data['description'] as String? ?? 'Mylota Fitness Subscription';
      final metadata = data['metadata'] as Map<String, dynamic>? ?? {};

      print('🔄 Creating payment intent for $email, amount: \$${amount / 100}');

      // Call Stripe API directly using HTTP with cleaned key
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $cleanStripeKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency,
          'description': description,
          'receipt_email': email,
          'metadata[email]': email,
          'metadata[type]': metadata['type']?.toString() ?? 'subscription',
          'metadata[firstname]': metadata['firstname']?.toString() ?? '',
          'metadata[lastname]': metadata['lastname']?.toString() ?? '',
          'metadata[app]': 'mylota_fitness',
          'automatic_payment_methods[enabled]': 'true',
        },
      );

      print('📊 Stripe response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final paymentIntent = jsonDecode(response.body);
        print('✅ Payment Intent created: ${paymentIntent['id']} for $email');
        
        return Response.ok(
          jsonEncode({
            'client_secret': paymentIntent['client_secret'],
            'payment_intent_id': paymentIntent['id'],
            'status': 'success',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        print('❌ Stripe API error: ${response.statusCode} - ${response.body}');
        throw Exception('Stripe API error: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating payment intent: $e');
      return Response(
        500,
        body: jsonEncode({
          'error': 'Failed to create payment intent',
          'message': e.toString()
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Create customer endpoint
  router.post('/create-customer', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final email = data['email'] as String;
      final name = data['name'] as String?;
      final phone = data['phone'] as String?;

      print('🔄 Creating customer for $email');

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer $cleanStripeKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          'metadata[app]': 'mylota_fitness',
          'metadata[created_from]': 'mobile_app',
        },
      );

      if (response.statusCode == 200) {
        final customer = jsonDecode(response.body);
        print('✅ Customer created: ${customer['id']} for $email');

        return Response.ok(
          jsonEncode({
            'customer_id': customer['id'],
            'email': customer['email'],
            'status': 'success',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        throw Exception('Stripe API error: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating customer: $e');
      return Response(
        500,
        body: jsonEncode({
          'error': 'Failed to create customer',
          'message': e.toString()
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Debug endpoint - FIXED
  router.get('/debug', (Request request) {
    return Response.ok(
      jsonEncode({
        'env_file_exists': File('.env').existsSync(),
        'stripe_key_length': cleanStripeKey.length,
        'stripe_key_prefix': cleanStripeKey.isNotEmpty ? cleanStripeKey.substring(0, 10) : 'not loaded',
        'port': port,
        'stripe_configured': cleanStripeKey.isNotEmpty,
        'current_directory': Directory.current.path,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Health check endpoint
  router.get('/health', (Request request) {
    return Response.ok(
      jsonEncode({
        'status': 'healthy', 
        'timestamp': DateTime.now().toIso8601String(),
        'service': 'mylota-payment-server',
        'version': '1.0.0',
        'stripe_configured': cleanStripeKey.isNotEmpty,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Test Stripe connection endpoint - FIXED
  router.get('/test-stripe', (Request request) async {
    try {
      print('🧪 Testing Stripe connection...');
      
      final response = await http.get(
        Uri.parse('https://api.stripe.com/v1/account'),
        headers: {
          'Authorization': 'Bearer $cleanStripeKey',
        },
      );

      print('📊 Stripe test response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final account = jsonDecode(response.body);
        print('✅ Stripe connection successful!');
        return Response.ok(
          jsonEncode({
            'stripe_connected': true,
            'account_id': account['id'],
            'country': account['country'],
            'business_type': account['business_type'],
            'details_submitted': account['details_submitted'],
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        print('❌ Stripe test failed: ${response.body}');
        throw Exception('Stripe connection failed: ${response.body}');
      }
    } catch (e) {
      print('❌ Stripe test error: $e');
      return Response(
        500,
        body: jsonEncode({
          'stripe_connected': false,
          'error': e.toString()
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Add CORS middleware
  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(router);

  // Start server with automatic port finding
  var serverPort = int.parse(port);
  HttpServer? server;
  
  // Try the preferred port first, then find an available one
  for (int attemptPort = serverPort; attemptPort <= serverPort + 10; attemptPort++) {
    try {
      server = await serve(handler, InternetAddress.anyIPv4, attemptPort);
      print('🚀 Mylota Payment Server running on http://localhost:${server.port}');
      break;
    } catch (e) {
      if (attemptPort == serverPort + 10) {
        print('❌ Could not find an available port between $serverPort and ${serverPort + 10}');
        exit(1);
      }
      print('⚠️  Port $attemptPort is busy, trying ${attemptPort + 1}...');
    }
  }
  
  if (server != null) {
    print('📍 Health check: http://localhost:${server.port}/health');
    print('🔧 Debug info: http://localhost:${server.port}/debug');
    print('🧪 Test Stripe: http://localhost:${server.port}/test-stripe');
    print('💳 Create payment: http://localhost:${server.port}/create-payment-intent');
  }
}

// CORS function (keep this)
Middleware corsHeaders() {
  return createMiddleware(
    requestHandler: (Request request) {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        });
      }
      return null;
    },
    responseHandler: (Response response) {
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      });
    },
  );
}