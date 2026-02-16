import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/food_item/presentation/notifier/food_item_notifier.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/presentation/state/food_items_state.dart';

class BestSellersScreen extends ConsumerWidget {
  const BestSellersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodState = ref.watch(foodItemNotifierProvider); // use notifier provider

    return Scaffold(
      appBar: AppBar(
        title: const Text("Best Sellers"),
        backgroundColor: Colors.orange,
      ),
      body: _buildBody(foodState),
    );
  }

  Widget _buildBody(FoodItemsState foodState) {
    if (foodState.status == FoodItemStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (foodState.status == FoodItemStatus.error) {
      return Center(child: Text(foodState.errorMessage ?? 'Something went wrong'));
    }

    if (foodState.bestSellers.isEmpty) {
      return const Center(child: Text("No Best Sellers Available"));
    }

    return ListView.builder(
      itemCount: foodState.bestSellers.length,
      itemBuilder: (context, index) {
        final FoodItemEntity item = foodState.bestSellers[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: item.fullImageUrl != null && item.fullImageUrl!.isNotEmpty
                ? Image.network(item.fullImageUrl!, width: 60, height: 60, fit: BoxFit.cover)
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.fastfood, color: Colors.white),
                  ),
            title: Text(item.name),
            subtitle: Text("Price: \$${item.price.toStringAsFixed(2)}"),
            trailing: const Icon(Icons.star, color: Colors.red),
          ),
        );
      },
    );
  }
}
