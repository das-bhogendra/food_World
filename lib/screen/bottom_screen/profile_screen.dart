import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF7F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildProfileOptions(),
          ],
        ),
      ),
    );
  }

  // 🔴 Header with Avatar
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
        children: const [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 50,
              color: Color(0xffB33B2E),
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Bhogendra Kumar Das",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "bhogendra@email.com",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // 📌 Profile Options
  Widget _buildProfileOptions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: const [
          ProfileTile(
            icon: Icons.person_outline,
            title: "Edit Profile",
          ),
          ProfileTile(
            icon: Icons.location_on_outlined,
            title: "Delivery Address",
          ),
          ProfileTile(
            icon: Icons.payment_outlined,
            title: "Payment Methods",
          ),
          ProfileTile(
            icon: Icons.receipt_long_outlined,
            title: "My Orders",
          ),
          ProfileTile(
            icon: Icons.settings_outlined,
            title: "Settings",
          ),
          ProfileTile(
            icon: Icons.logout,
            title: "Logout",
            isLogout: true,
          ),
        ],
      ),
    );
  }
}

// 🧩 Profile Option Tile
class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLogout;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : Colors.black,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
