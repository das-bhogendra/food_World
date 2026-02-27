import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserPaymentPage extends StatelessWidget {
  const UserPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Hard-coded payment methods
    final List<Map<String, String>> paymentMethods = [
      {"type": "Credit Card", "number": "**** **** **** 1234"},
      {"type": "Wallet", "number": "FoodWallet Balance: \$50"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Payment Methods"),
        backgroundColor: const Color(0xffB33B2E),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // QR Code Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Scan to Pay via QR Code",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                // ✅ QrImageView for qr_flutter v4.x
                QrImageView(
                  data: "https://demo-payment-link.com/user123",
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                const SizedBox(height: 8),
                const Text("Use any UPI / QR payment app to pay"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // List of saved payment methods
          ...paymentMethods.map(
            (method) => Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.payment_outlined,
                    color: Color(0xffB33B2E)),
                title: Text(method['type'] ?? ""),
                subtitle: Text(method['number'] ?? ""),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Delete functionality demo only")),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffB33B2E),
        child: const Icon(Icons.add),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add new payment method demo")),
          );
        },
      ),
    );
  }
}
