
import 'package:flutter_riverpod/legacy.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';

class CartItem {
  final FoodItemEntity foodItem;
  final int quantity;

  CartItem({
    required this.foodItem,
    required this.quantity,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      foodItem: foodItem,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get subtotal {
    return items.fold(
      0,
      (sum, item) => sum + (item.foodItem.price * item.quantity),
    );
  }

  double get deliveryFee => items.isEmpty ? 0 : 100;

  double get total => subtotal + deliveryFee;
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addToCart(FoodItemEntity fooditem) {
    final existingIndex =
        state.items.indexWhere((item) => item.foodItem.id == fooditem.id);

    if (existingIndex != -1) {
      final updated = [...state.items];
      updated[existingIndex] =
          updated[existingIndex].copyWith(quantity: updated[existingIndex].quantity + 1);
      state = CartState(items: updated);
    } else {
      state = CartState(items: [...state.items, CartItem(foodItem: fooditem, quantity: 1)]);
    }
  }

  void increaseQty(String foodId) {
    final updated = state.items.map((item) {
      if (item.foodItem.id == foodId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();

    state = CartState(items: updated);
  }

  void decreaseQty(String foodId) {
    final updated = state.items.map((item) {
      if (item.foodItem.id == foodId) {
        return item.copyWith(quantity: item.quantity - 1);
      }
      return item;
    }).where((item) => item.quantity > 0).toList();

    state = CartState(items: updated);
  }

  void removeItem(String foodId) {
    state = CartState(items: state.items.where((e) => e.foodItem.id != foodId).toList());
  }

  void clearCart() {
    state = const CartState(items: []);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);
