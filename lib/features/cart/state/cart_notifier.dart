import 'package:flutter_riverpod/legacy.dart';
import 'cart_state.dart';
import '../domain/cart_item.dart';
import '../../food_item/domain/entities/food_items_entity.dart';

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(FoodItemEntity foodItem) {
    final index = state.items.indexWhere((item) => item.foodItem.id == foodItem.id);
    if (index != -1) {
      final updatedItems = [...state.items];
      updatedItems[index].quantity += 1;
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(items: [...state.items, CartItem(foodItem: foodItem, quantity: 1)]);
    }
  }

  void removeItem(String foodItemId) {
    state = state.copyWith(
      items: state.items.where((item) => item.foodItem.id != foodItemId).toList(),
    );
  }

  void incrementQuantity(String foodItemId) {
    final updatedItems = [...state.items];
    final index = updatedItems.indexWhere((item) => item.foodItem.id == foodItemId);
    if (index != -1) {
      updatedItems[index].quantity += 1;
      state = state.copyWith(items: updatedItems);
    }
  }

  void decrementQuantity(String foodItemId) {
    final updatedItems = [...state.items];
    final index = updatedItems.indexWhere((item) => item.foodItem.id == foodItemId);
    if (index != -1) {
      if (updatedItems[index].quantity > 1) {
        updatedItems[index].quantity -= 1;
      } else {
        updatedItems.removeAt(index);
      }
      state = state.copyWith(items: updatedItems);
    }
  }

  void clearCart() {
    state = state.copyWith(items: []);
  }
}
