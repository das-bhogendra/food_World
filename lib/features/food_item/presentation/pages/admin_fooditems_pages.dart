

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/presentation/notifier/food_item_notifier.dart';
import 'package:food_mandu/features/food_item/presentation/pages/fooditems_form_page.dart';
import 'package:food_mandu/features/food_item/presentation/state/food_items_state.dart';

import 'package:food_mandu/theme/app_colors.dart';


class AdminFoodItemsPage extends ConsumerStatefulWidget {
  const AdminFoodItemsPage({super.key});

  @override
  ConsumerState<AdminFoodItemsPage> createState() => _AdminFoodItemsPageState();
}

class _AdminFoodItemsPageState extends ConsumerState<AdminFoodItemsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => ref.read(foodItemNotifierProvider.notifier).fetchFoodItems());
  }

  @override
  Widget build(BuildContext context) {
    final foodState = ref.watch(foodItemNotifierProvider);
    final notifier = ref.read(foodItemNotifierProvider.notifier);

    final availableItems = foodState.items.where((e) => e.isAvailable).toList();
    final soldOutItems = foodState.items.where((e) => !e.isAvailable).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Food Items"),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Available (${availableItems.length})"),
            Tab(text: "Sold Out (${soldOutItems.length})"),
          ],
        ),
      ),
      body: foodState.status == FoodItemStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFoodList(context, availableItems, true, notifier),
                _buildFoodList(context, soldOutItems, false, notifier),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FoodItemFormPage(),
            ),
          );
          notifier.fetchFoodItems(); // refresh list after returning
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFoodList(BuildContext context, List<FoodItemEntity> items, bool available, FoodItemNotifier notifier) {
    if (items.isEmpty) {
      return Center(
        child: Text(available ? 'No available items' : 'No sold out items'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final food = items[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: food.fullImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(food.fullImageUrl!, width: 56, height: 56, fit: BoxFit.cover),
                  )
                : Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(12))),
            title: Text(food.name),
            subtitle: Text('Added by: ${food.addedBy}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FoodItemFormPage(foodItem: food),
                      ),
                    );
                    notifier.fetchFoodItems();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, food.id, notifier),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String id, FoodItemNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Food Item"),
        content: const Text("Are you sure you want to delete this food item?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              notifier.deleteFoodItem(id);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
