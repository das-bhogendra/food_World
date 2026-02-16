import 'package:equatable/equatable.dart';
import '../domain/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  // Subtotal = sum of (foodItem.price * quantity)
  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.foodItem.price * item.quantity);

  // Delivery fee example
  double get deliveryFee => items.isEmpty ? 0 : 500;

  // Total = subtotal + delivery
  double get total => subtotal + deliveryFee;

  // CopyWith for immutability
  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}
