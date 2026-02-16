import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/features/auth/presentation/providers/auth_provider.dart';

import 'package:food_mandu/screen/bottom_screen/about/about_screen.dart';
import 'package:food_mandu/screen/bottom_screen/cart_screen.dart';
import 'package:food_mandu/screen/bottom_screen/home_screen.dart';
import 'package:food_mandu/screen/bottom_screen/profile_screen.dart';

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
      ),
    );
  }
}
