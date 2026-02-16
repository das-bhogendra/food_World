class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });
}
