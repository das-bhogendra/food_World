import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int pageIndex = 0;

  final List<Map<String, String>> pages = [
    {
      "title": "Order Delicious and tasty Food",
      "subtitle": "Choose from top restaurants near you.",
      "image": "https://cdn-icons-png.flaticon.com/512/3075/3075977.png"
    },
    {
      "title": "Fast Home Delivery",
      "subtitle": "Hot & fresh meals delivered on time!",
      "image": "https://cdn-icons-png.flaticon.com/512/4151/4151403.png"
    },
    {
      "title": "Easy & Secure Payments",
      "subtitle": "Pay via eSewa, Khalti or Cash on Delivery.",
      "image": "https://cdn-icons-png.flaticon.com/512/891/891462.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Pages
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() => pageIndex = index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(pages[index]["image"]!, height: 220),
                      const SizedBox(height: 25),
                      Text(
                        pages[index]["title"]!,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pages[index]["subtitle"]!,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 17, color: Colors.black54),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 10,
                width: pageIndex == index ? 25 : 10,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: pageIndex == index ? Colors.orange : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text("Skip", style: TextStyle(fontSize: 18)),
                ),

                // Next / Get Started
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    if (pageIndex == pages.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    pageIndex == pages.length - 1
                        ? "Get Started"
                        : "Next",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
