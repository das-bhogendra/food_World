import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: const [
          Divider(),
          SizedBox(height: 10),
          Text(
            "© 2025 Homemade Food Platform",
            style: TextStyle(color: Colors.black54),
          ),
          SizedBox(height: 5),
          Text(
            "Built with ❤️ for quality & trust",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
