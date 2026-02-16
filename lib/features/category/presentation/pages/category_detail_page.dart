import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/cart/cart_provider.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/domain/usecases/get_all_food_items_usecase.dart';

class CategoryDetailPage extends ConsumerWidget {
  final String categoryId;
  final String categoryName;
  final String userRole;

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.userRole,
  });

  /// ✅ categoryName बाट FoodItemType निकाल्ने
  FoodItemType? _mapCategoryNameToFoodType(String name) {
    final n = name.trim().toLowerCase();

    // veg momo, veg, vegetarian
    if (n.contains("veg")) return FoodItemType.veg;

    // non veg momo, chicken, buff
    if (n.contains("non") || n.contains("chicken") || n.contains("buff")) {
      return FoodItemType.nonVeg;
    }

    // beverage, drink, cold drink
    if (n.contains("beverage") || n.contains("drink")) {
      return FoodItemType.drink;
    }

    // dessert, sweet
    if (n.contains("dessert") || n.contains("sweet")) {
      return FoodItemType.dessert;
    }

    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodsAsync = ref.watch(allFoodItemsProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final FoodItemType? selectedType = _mapCategoryNameToFoodType(categoryName);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: foodsAsync.when(
        data: (foods) {
          // ✅ Filter by enum type
          final categoryFoods = selectedType == null
              ? <FoodItemEntity>[]
              : foods.where((f) => f.type == selectedType).toList();

          if (selectedType == null) {
            return Center(
              child: Text(
                "Category '$categoryName' is not mapped to any FoodItemType.\n\n"
                "Valid types: veg, nonVeg, drink, dessert",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            );
          }

          if (categoryFoods.isEmpty) {
            return Center(
              child: Text(
                "No food items found in '$categoryName'",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categoryFoods.length,
            itemBuilder: (context, index) {
              final food = categoryFoods[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      food.fullImageUrl ?? "",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.fastfood),
                      ),
                    ),
                  ),
                  title: Text(
                    food.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Rs. ${food.price.toStringAsFixed(0)}"),
                  trailing: userRole == "user"
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            cartNotifier.addToCart(food);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${food.name} added to cart"),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Text(
                            "Add",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : null,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            "Error: $err",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
