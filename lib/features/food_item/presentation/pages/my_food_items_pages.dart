import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/presentation/notifier/food_item_notifier.dart';
import 'package:food_mandu/features/food_item/presentation/state/food_items_state.dart';


import 'package:food_mandu/theme/app_colors.dart';
import 'package:food_mandu/theme/theme_extensions.dart';

class MyFoodItemsPage extends ConsumerStatefulWidget {
  const MyFoodItemsPage({super.key});

  @override
  ConsumerState<MyFoodItemsPage> createState() => _MyFoodItemsPageState();
}

class _MyFoodItemsPageState extends ConsumerState<MyFoodItemsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => _loadData());
  }

  void _loadData() {
    // Fetch food items from your FoodItemViewModel
    ref.read(foodItemNotifierProvider.notifier).fetchFoodItems();
  }

  @override
  Widget build(BuildContext context) {
    final foodState = ref.watch(foodItemNotifierProvider);
    final availableFood = foodState.items
        .where((item) => item.type == FoodItemType.veg) // Temporary filter for demo
        .toList();
    final soldOutFood = foodState.items
        .where((item) => item.type == FoodItemType.nonVeg) // Temporary filter for demo
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Food Items',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track your menu',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: context.softShadow,
                    ),
                    child: Icon(Icons.sort_rounded, color: context.textPrimary),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: context.softShadow,
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: AppColors.primaryGradient,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: context.textSecondary,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restaurant_menu_rounded, size: 18),
                        const SizedBox(width: 6),
                        const Text('Available'),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${availableFood.length}', style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.remove_shopping_cart_rounded, size: 18),
                        const SizedBox(width: 6),
                        const Text('Sold Out'),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${soldOutFood.length}', style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tab Views
            Expanded(
              child: foodState.status == FoodItemStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildFoodList(availableFood, true),
                        _buildFoodList(soldOutFood, false),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodList(List<FoodItemEntity> items, bool available) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu_rounded, size: 64, color: context.textTertiary.withAlpha(128)),
            const SizedBox(height: 16),
            Text(
              available ? 'No available items' : 'No sold out items',
              style: TextStyle(fontSize: 16, color: context.textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final food = items[index];
        return _FoodItemCard(
          name: food.name,
          addedBy: food.addedBy,
          isAvailable: available,
          onTap: () {},
          onOrder: () {},
        );
      },
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final String name;
  final String addedBy;
  final bool isAvailable;
  final VoidCallback? onTap;
  final VoidCallback? onOrder;

  const _FoodItemCard({
    required this.name,
    required this.addedBy,
    required this.isAvailable,
    this.onTap,
    this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isAvailable ? AppColors.foundGradient : AppColors.lostGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimary)),
                      const SizedBox(height: 4),
                      Text('Added by $addedBy', style: TextStyle(fontSize: 12, color: context.textSecondary)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onOrder,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isAvailable ? 'Order' : 'Sold Out',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
