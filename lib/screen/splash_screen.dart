import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_screen.dart';
import 'package:food_mandu/core/providers/shared_prefs_provider.dart';
import 'package:food_mandu/core/services/storage/user_session_service.dart';
import 'package:food_mandu/screen/buttom_screen.dart';

// Splash screen for FoodWorld App
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiveService = ref.watch(hiveServiceProvider);
    final userSession = ref.watch(userSessionServiceProvider);

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        if (userSession.isLoggedIn) {
          final userRole = userSession.role ?? 'user';
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomScreenLayout(userRole: userRole),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OnboardingScreen(hiveService: hiveService),
            ),
          );
        }
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
