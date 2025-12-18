import 'package:flutter/material.dart';
import 'package:food_mandu/screen/best_sellers_screen.dart';
import 'package:food_mandu/screen/discount_offer_screen.dart';
import 'package:food_mandu/screen/main_dishes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF7F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),

              _buildSectionTitle("Main Dishes", context, isClickable: true),
              _buildFoodCard(
                image: "assets/images/noodles.jpg",
                rating: "4.9 (355 ratings)",
                price: "Starts at ₦2500",
                tag: "FREE DRINK",
              ),

              _buildSectionTitle("Best Sellers", context, isClickable:true ),
              _buildFoodCard(
                image: "assets/images/pizza.jpg",
                rating: "4.8 (105 ratings)",
                price: "Starts at ₦2000",
              ),

              _buildSectionTitle("Discounted Offers", context, isClickable:true),
              _buildFoodCard(
                image: "assets/images/burger.jpg",
                rating: "4.6 (500 ratings)",
                price: "Starts from ₦500",
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // 🔴 HEADER
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xffB33B2E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.menu, color: Colors.white, size: 28),
              Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Welcome",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Homemade meals prepared with\nlove. Richest ingredients.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
        ],
      ),
    );
  }

  // 🔍 SEARCH BAR
  Widget _buildSearchBar() {
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

  // 📌 SECTION TITLE
  Widget _buildSectionTitle(String title, BuildContext context, {bool isClickable = false}) {
    Widget textWidget = Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );

    // Wrap with GestureDetector only if isClickable is true
    if (isClickable) {
    textWidget = GestureDetector(
      onTap: () {
        if (title == "Main Dishes") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MainDishesScreen(),
            ),
          );
        } else if (title == "Best Sellers") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BestSellersScreen(),
            ),
          );
        }else if (title == "Discounted Offers") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DiscountOfferScreen(),

            ),
            );
        }
      },
      child: textWidget,
    );
  }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: textWidget,
    );
  }

  // 🍽 FOOD CARD
  Widget _buildFoodCard({
    required String image,
    required String rating,
    required String price,
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
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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
                    style: const TextStyle(color: Colors.red),
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
