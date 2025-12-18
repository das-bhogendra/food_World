import 'package:flutter/material.dart';

class BestSellersScreen extends StatelessWidget {
  const BestSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 15),
            Expanded(child: _buildGrid()),
            _buildBottomNav(context, currentIndex: 1),
          ],
        ),
      ),
    );
  }

  // 🔴 Header with back button
  Widget _buildHeader(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Icon(Icons.shopping_bag, color: Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Best Sellers",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Our most loved dishes.\nChosen by customers.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search),
                hintText: "Search Best Sellers",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🧩 Grid of Best Sellers
  Widget _buildGrid() {
    final foods = [
      {"name": "Pepperoni Pizza", "image": "assets/images/pizza.jpg"},
      {"name": "Cheese Burger", "image": "assets/images/burger.jpg"},
      {"name": "Chicken Wings", "image": "assets/images/chicken.jpg"},
      {"name": "Grilled Sandwich", "image": "assets/images/sandwich.jpg"},
      {"name": "Fried Chicken", "image": "assets/images/fried_chicken.jpg"},
      {"name": "Hotdog", "image": "assets/images/hotdog.jpg"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: foods.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final food = foods[index];
          return _FoodCard(
            name: food["name"]!,
            image: food["image"]!,
          );
        },
      ),
    );
  }

  // 🔽 Bottom Navigation (same as Main Dishes)
  Widget _buildBottomNav(BuildContext context, {int currentIndex = 1}) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            color: currentIndex == 0 ? Colors.red : Colors.black54,
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            color: currentIndex == 1 ? Colors.red : Colors.black54,
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/home'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            color: currentIndex == 2 ? Colors.red : Colors.black54,
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            color: currentIndex == 3 ? Colors.red : Colors.black54,
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/about'),
          ),
        ],
      ),
    );
  }
}

// 🍽 Food Card Widget
class _FoodCard extends StatelessWidget {
  final String name;
  final String image;

  const _FoodCard({
    required this.name,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.asset(
              image,
              height: 110,
              width: 110,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffB33B2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {},
              child: const Text("Buy Now"),
            ),
          ),
        ],
      ),
    );
  }
}
