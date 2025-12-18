import 'package:flutter/material.dart';

class DiscountOfferScreen extends StatelessWidget {
  const DiscountOfferScreen({super.key});

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
            _buildBottomNav(context, currentIndex: 2),
          ],
        ),
      ),
    );
  }

  // 🔴 Header
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
              const Icon(Icons.local_offer, color: Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Discount Offers",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Grab delicious food at\nspecial prices!",
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
                hintText: "Search Offers",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🧩 Discount Grid
  Widget _buildGrid() {
    final offers = [
      {
        "name": "Pizza Combo",
        "image": "assets/images/pizza.jpg",
        "discount": "30% OFF"
      },
      {
        "name": "Burger Deal",
        "image": "assets/images/burger.jpg",
        "discount": "25% OFF"
      },
      {
        "name": "Fried Chicken",
        "image": "assets/images/fried_chicken.jpg",
        "discount": "20% OFF"
      },
      {
        "name": "Sandwich Offer",
        "image": "assets/images/sandwich.jpg",
        "discount": "15% OFF"
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: offers.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final offer = offers[index];
          return _OfferCard(
            name: offer["name"]!,
            image: offer["image"]!,
            discount: offer["discount"]!,
          );
        },
      ),
    );
  }

  // 🔽 Bottom Navigation
  Widget _buildBottomNav(BuildContext context, {int currentIndex = 2}) {
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
            icon: const Icon(Icons.local_offer_outlined),
            color: currentIndex == 2 ? Colors.red : Colors.black54,
            onPressed: () {},
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

// 🍽 Offer Card
class _OfferCard extends StatelessWidget {
  final String name;
  final String image;
  final String discount;

  const _OfferCard({
    required this.name,
    required this.image,
    required this.discount,
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
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              discount,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
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
              child: const Text("Order Now"),
            ),
          ),
        ],
      ),
    );
  }
}
