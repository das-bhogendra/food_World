import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_mandu/features/cart/cart_provider.dart';

import 'package:food_mandu/features/dashboard/bottom_screen/about/about_screen.dart';
import 'package:food_mandu/features/dashboard/bottom_screen/cart_screen.dart';
import 'package:food_mandu/features/dashboard/bottom_screen/home_screen.dart';
import 'package:food_mandu/features/dashboard/bottom_screen/profile_screen.dart';
import 'package:food_mandu/app/theme/app_colors.dart';

class BottomScreenLayout extends ConsumerStatefulWidget {
  final String userRole;

  const BottomScreenLayout({
    super.key,
    required this.userRole,
  });

  @override
  ConsumerState<BottomScreenLayout> createState() =>
      _BottomScreenLayoutState();
}

class _BottomScreenLayoutState extends ConsumerState<BottomScreenLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final userId = authState.authEntity?.authId ?? '';

    final screens = [
      HomeScreen(userRole: widget.userRole, userId: userId),
      CartScreen(userId: userId),
      const ProfileScreen(),
      const AboutScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildCartIcon(),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
        backgroundColor: AppColors.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
    );
  }

  Widget _buildCartIcon() {
    final cartState = ref.watch(cartProvider);
    return Stack(
      children: [
        const Icon(Icons.shopping_cart),
        if (cartState.items.isNotEmpty)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${cartState.items.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
