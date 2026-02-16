import 'package:flutter/material.dart';
import '../../../../core/api/api_endpoints.dart';

class CartItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double price;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl.startsWith('http')
                  ? imageUrl
                  : '${ApiEndpoints.baseUrl}/uploads/$imageUrl',
              height: 70,
              width: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 70,
                width: 70,
                color: Colors.grey.shade300,
                child: const Icon(Icons.fastfood, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "Rs. ${price.toStringAsFixed(2)}",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.red),
                ),
              ],
            ),
          ),

          // Quantity & Remove Buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.red),
                onPressed: onIncrease,
              ),
              Text(quantity.toString()),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: onDecrease,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
