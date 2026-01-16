import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_screen.dart';
import 'package:food_mandu/core/providers/shared_prefs_provider.dart';

// Splash screen for FoodWorld App
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiveService = ref.watch(hiveServiceProvider);

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(hiveService: hiveService),
          ),
        );
      }
    });

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
