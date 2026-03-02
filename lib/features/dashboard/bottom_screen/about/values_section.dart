import 'package:flutter/material.dart';

class ValuesSection extends StatelessWidget {
  const ValuesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Our Core Values",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        ValueTile(
          icon: Icons.verified,
          title: "Trust & Transparency",
          description:
              "We maintain honesty in pricing, quality, and customer communication.",
        ),
        ValueTile(
          icon: Icons.favorite,
          title: "Customer First",
          description:
              "Every decision we make prioritizes user satisfaction and safety.",
        ),
        ValueTile(
          icon: Icons.eco,
          title: "Sustainability",
          description:
              "Supporting local kitchens while reducing food waste.",
        ),
      ],
    );
  }
}

class ValueTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const ValueTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.red, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
