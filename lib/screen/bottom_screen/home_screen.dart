import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:food_mandu/features/cart/presentation/cart_screen.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/presentation/notifier/food_item_notifier.dart';
import 'package:food_mandu/features/food_item/presentation/pages/admin_fooditems_pages.dart';
import 'package:food_mandu/features/food_item/presentation/pages/food_items_detail_pages.dart';
import 'package:food_mandu/features/food_item/presentation/pages/fooditems_form_page.dart';
import 'package:food_mandu/features/food_item/presentation/state/food_items_state.dart';
import 'package:food_mandu/features/category/presentation/pages/my_category_page.dart';
import 'package:food_mandu/features/order/presentation/pages/my_order_pages.dart';
import 'package:food_mandu/features/cart/cart_provider.dart';

class HomeScreen extends ConsumerWidget {
  final String userRole; // 'admin' or 'user'
  final String userId;

  const HomeScreen({super.key, required this.userRole, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodState = ref.watch(foodItemNotifierProvider);
    final foodNotifier = ref.read(foodItemNotifierProvider.notifier);
    final cartState = ref.watch(cartProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (foodState.status == FoodItemStatus.initial) {
        foodNotifier.fetchFoodItems();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xffFFF7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffB33B2E),
        title: const Text("Food World"),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(userId: userId),
                    ),
                  );
                },
              ),
              if (cartState.items.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      cartState.items.length.toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          if (userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: "Manage Food Items",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminFoodItemsPage(),
                  ),
                );
              },
            ),
          if (userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: "Add Food Item",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FoodItemFormPage(foodItem: null),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: "My Orders",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyOrderPages(userId: userId, userRole: userRole),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, ref),
              const SizedBox(height: 20),
              _buildCategorySection(context),
              const SizedBox(height: 20),
              if (foodState.status == FoodItemStatus.loading)
                const Center(child: CircularProgressIndicator())
              else if (foodState.status == FoodItemStatus.error)
                Center(child: Text(foodState.errorMessage ?? "Error"))
              else
                _buildFoodSections(context, ref, foodState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xffB33B2E),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.menu, color: Colors.white),
              SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Welcome",
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            "Homemade meals prepared with love.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          _searchBar(ref),
        ],
      ),
    );
  }

  Widget _searchBar(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        onChanged: (query) {
          ref.read(foodItemNotifierProvider.notifier).filterFoodItems(query);
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          hintText: "Search Menu",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryPage(userRole: userRole),
          ),
        );
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.orange.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            "Browse Categories",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodSections(
      BuildContext context, WidgetRef ref, FoodItemsState foodState) {
    final sections = [
      if (foodState.items.any((f) => f.isBestSeller))
        {'title': 'Best Sellers', 'items': foodState.items.where((f) => f.isBestSeller).toList()},
      if (foodState.items.any((f) => f.isDiscounted))
        {'title': 'Discounted Offers', 'items': foodState.items.where((f) => f.isDiscounted).toList()},
      if (foodState.vegItems.isNotEmpty) {'title': 'Veg', 'items': foodState.vegItems},
      if (foodState.nonVegItems.isNotEmpty) {'title': 'Non-Veg', 'items': foodState.nonVegItems},
      if (foodState.drinkItems.isNotEmpty) {'title': 'Drinks', 'items': foodState.drinkItems},
      if (foodState.dessertItems.isNotEmpty) {'title': 'Desserts', 'items': foodState.dessertItems},
    ];

    return Column(
      children: sections.map((section) {
        return _buildSection(
          title: section['title'] as String,
          items: section['items'] as List<FoodItemEntity>,
          context: context,
          ref: ref,
        );
      }).toList(),
    );
  }

  Widget _buildSection({
    required String title,
    required List<FoodItemEntity> items,
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 260,
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemExtent: 175, // fixed width for smooth scrolling
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) => _foodCard(items[index], context, ref),
            ),
          ),
        ),
      ],
    );
  }

  Widget _foodCard(FoodItemEntity food, BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodItemDetailPage(
              foodItem: food,
              category: food.type.name.toUpperCase(),
              location: "Lalgadh, Nepal",
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: food.fullImageUrl != null && food.fullImageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: food.fullImageUrl!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                      memCacheWidth: 300,
                      placeholder: (context, url) => Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.fastfood, size: 50, color: Colors.white),
                      ),
                    )
                  : Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.fastfood, size: 50, color: Colors.white),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text("₹${food.price.toStringAsFixed(2)}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.red)),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => cartNotifier.addToCart(food),
                      child: const Text("Add to Cart"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
