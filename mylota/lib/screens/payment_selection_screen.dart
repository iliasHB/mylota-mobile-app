import 'package:flutter/material.dart';
import '../services/stripe_service.dart';
import '../controller/transactions_controller.dart';
import '../controller/verify_payment_controller.dart'; // Add this import for DataModel

class PaymentSelectionScreen extends StatefulWidget {
  final double amount;
  final String productName;
  final String productType;
  // Add optional parameters for better integration
  final String? email;
  final String? planDescription;

  const PaymentSelectionScreen({
    Key? key,
    required this.amount,
    required this.productName,
    required this.productType,
    this.email,
    this.planDescription,
  }) : super(key: key);

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  bool _isLoading = false;

  Future<void> _handleStripePayment() async {
    // setState(() {
    //   _isLoading = true;
    // });
    //
    // try {
    //   final success = await StripeService.makePayment(
    //     amount: (widget.amount * 100).toInt(),
    //     currency: 'usd',
    //     merchantDisplayName: 'Mylota Fitness',
    //   );
    //
    //   if (success) {
    //     // Create DataModel instance for your existing transaction controller
    //     final transactionData = DataModel(
    //       reference: 'stripe_${DateTime.now().millisecondsSinceEpoch}',
    //       status: 'success',
    //       amount: (widget.amount * 100).toInt(), // Amount in cents
    //       currency: 'USD',
    //       gatewayResponse: 'Payment successful via Stripe',
    //       paidAt: DateTime.now().toIso8601String(),
    //       createdAt: DateTime.now().toIso8601String(),
    //     );
    //
    //     // Save transaction to Firebase using your existing controller
    //     await TransactionController.saveTransactions(transactionData);
    //
    //     _showSuccessDialog();
    //   }
    // } catch (e) {
    //   _showErrorDialog(e.toString());
    // } finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Options'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.productName, style: Theme.of(context).textTheme.headlineSmall),
                    Text('\$${widget.amount.toStringAsFixed(2)}', 
                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.green)),
                    // Show additional info if available
                    if (widget.planDescription != null) ...[
                      const SizedBox(height: 8),
                      Text(widget.planDescription!, 
                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                    ],
                    if (widget.email != null) ...[
                      const SizedBox(height: 4),
                      Text('Email: ${widget.email}', 
                           style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Payment method buttons
            Text('Choose Payment Method:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            // Stripe Payment Button - NEW INTEGRATION
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleStripePayment,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : const Icon(Icons.credit_card, color: Colors.white),
              label: Text(
                _isLoading ? 'Processing...' : 'Pay with Card (Stripe)',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Security info for Stripe
            if (!_isLoading) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue.shade600, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Secure payment powered by Stripe',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Your existing payment method - PRESERVED
            /* COMMENTED OUT - ORIGINAL PAYSTACK BUTTON
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to your existing payment flow
                // You can uncomment and implement this when needed
              },
              icon: const Icon(Icons.account_balance, color: Colors.white),
              label: const Text('Pay with Paystack', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            */
            
            // Alternative: Show both options
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement your existing Paystack payment flow here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paystack integration - Coming soon!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              icon: const Icon(Icons.account_balance, color: Colors.white),
              label: const Text('Pay with Paystack', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your payment of \$${widget.amount.toStringAsFixed(2)} was processed successfully.'),
            const SizedBox(height: 8),
            Text('Subscription: ${widget.productName}'),
            if (widget.email != null) Text('Email: ${widget.email}'),
            const SizedBox(height: 8),
            const Text('Payment Method: Stripe', 
                 style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
              // If you have more screens in the stack (like subscription alert), 
              // add more Navigator.pop() calls as needed
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Payment Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment failed: $error'),
            const SizedBox(height: 8),
            const Text('Please try again or contact support if the problem persists.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}