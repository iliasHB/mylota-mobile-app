import 'package:flutter/material.dart';
import 'package:mylota/widgets/appBar_widget.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context: context, title: "Transactions"),
      body: const Center(child: Text("No transactions available")),
    );
  }
}
