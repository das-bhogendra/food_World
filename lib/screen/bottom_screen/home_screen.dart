import 'package:flutter/material.dart';
import 'package:food_mandu/screen/best_sellers_screen.dart';
import 'package:food_mandu/screen/discount_offer_screen.dart';
import 'package:food_mandu/screen/main_dishes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xffFFF7F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 20),

              _sectionTitle("Main Dishes", context, theme),
              _foodCard(
                image: "assets/images/noodles.jpg",
                rating: "4.9 (355 ratings)",
                price: "Starts at ₦2500",
                tag: "FREE DRINK",
                theme: theme,
              ),

              _sectionTitle("Best Sellers", context, theme),
              _foodCard(
                image: "assets/images/pizza.jpg",
                rating: "4.8 (105 ratings)",
                price: "Starts at ₦2000",
                theme: theme,
              ),

              _sectionTitle("Discounted Offers", context, theme),
              _foodCard(
                image: "assets/images/burger.jpg",
                rating: "4.6 (500 ratings)",
                price: "Starts from ₦500",
                theme: theme,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildHeader(ThemeData theme) {
    return Container(
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
              Icon(Icons.shopping_bag_outlined, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Welcome",
            style: theme.textTheme.headlineSmall
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            "Homemade meals prepared with\nlove. Richest ingredients.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          _searchBar(),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search),
          hintText: "Search Menu",
          border: InputBorder.none,
        ),
      ),
    );
  }

  
  Widget _sectionTitle(String title, BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: () {
          if (title == "Main Dishes") {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MainDishesScreen()));
          } else if (title == "Best Sellers") {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BestSellersScreen()));
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DiscountOfferScreen()));
          }
        },
        child: Text(
          title,
          style: theme.textTheme.titleLarge,
        ),
      ),
    );
  }

  
  Widget _foodCard({
    required String image,
    required String rating,
    required String price,
    required ThemeData theme,
    String? tag,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    image,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (tag != null)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Chip(
                      backgroundColor: Colors.red,
                      label: Text(
                        tag,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.red, size: 16),
                      const SizedBox(width: 5),
                      Text(rating),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    price,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.red),
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
