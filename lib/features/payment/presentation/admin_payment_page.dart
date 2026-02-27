import 'package:flutter/material.dart';

class AdminPaymentPage extends StatelessWidget {
  const AdminPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample hard-coded payment report data
    final List<Map<String, String>> payments = [
      {"user": "John Doe", "method": "Credit Card", "amount": "\$25"},
      {"user": "Jane Smith", "method": "Wallet", "amount": "\$40"},
      {"user": "Admin Demo", "method": "Debit Card", "amount": "\$60"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Reports"),
        backgroundColor: const Color(0xffB33B2E),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xffB33B2E)),
              title: Text(payment['user'] ?? ""),
              subtitle: Text("${payment['method']} | Amount: ${payment['amount']}"),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.blue),
                onPressed: () {
                  // TODO: implement detailed view if needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Payment details demo")),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}