import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'package:food_mandu/core/services/hive/hive_service.dart';

// Splash screen for FoodWorld App
class SplashScreen extends StatefulWidget {
  final HiveService hiveService; // ✅ Add HiveService

  const SplashScreen({super.key, required this.hiveService});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(hiveService: widget.hiveService), // ✅ Pass HiveService
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Text(
          "FoodWorld",
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
