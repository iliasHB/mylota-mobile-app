import 'package:flutter/material.dart';
import 'payment_screen.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Basic Plan Card
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: const Icon(
                  Icons.star_border,
                  color: Colors.blue,
                  size: 32,
                ),
                title: const Text(
                  'Basic Plan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Monthly subscription • Access to basic features',
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: const Text(
                  '\$9.99',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentScreen(
                        amount: 9.99,
                        productName: 'Basic Plan',
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Premium Plan Card
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 32,
                ),
                title: const Text(
                  'Premium Membership',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Monthly subscription • All premium features',
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: const Text(
                  '\$19.99',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentScreen(
                        amount: 19.99, // ✅ Fixed: Changed from 9.99 to 19.99
                        productName: 'Premium Membership',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}