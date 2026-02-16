import '../../food_item/domain/entities/food_items_entity.dart';

class CartItem {
  final FoodItemEntity foodItem; // must be 'foodItem'
  int quantity;

  CartItem({required this.foodItem, this.quantity = 1});
}
