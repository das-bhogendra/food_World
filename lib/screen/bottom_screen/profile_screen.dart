import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/services/hive/hive_service.dart';
import 'package:food_mandu/core/services/shake_service.dart';
import 'package:food_mandu/core/providers/theme_provider.dart';
import 'package:food_mandu/screen/login_screen.dart';
import 'package:image_picker/image_picker.dart';

import 'package:food_mandu/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_mandu/core/services/storage/user_session_service.dart';

import 'package:food_mandu/features/order/presentation/pages/my_order_pages.dart';
import 'package:food_mandu/features/food_item/presentation/pages/my_food_items_pages.dart';
import 'package:food_mandu/features/food_item/presentation/pages/report_food_items_pages.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ShakeService _shakeService = ShakeService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startShakeDetection();
    });
  }

  void _startShakeDetection() {
    _shakeService.startListening(() {
      _handleShakeLogout();
    });
  }

  Future<void> _handleShakeLogout() async {
    if (!mounted) return;
    
    await ref.read(authViewModelProvider.notifier).logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          hiveService: HiveService(),
        ),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _shakeService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(userSessionServiceProvider);

    final userRole = session.userRole ?? 'user';
    final userId = session.userId ?? '';

    return Scaffold(
      backgroundColor: const Color(0xffFFF7F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, theme, ref, session),
            const SizedBox(height: 20),
            Expanded(
              child: _buildProfileOptions(context, ref, userRole, userId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ThemeData theme, WidgetRef ref, UserSessionService session) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xffB33B2E),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showImageSourceSheet(context, ref),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              backgroundImage: session.profilePicture != null
                  ? NetworkImage(session.profilePicture!)
                  : null,
              child: session.profilePicture == null
                  ? const Icon(Icons.camera_alt, size: 35, color: Color(0xffB33B2E))
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(session.fullName ?? "User",
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text(session.email ?? "", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text("Upload Profile Photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ref, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ref, ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile == null) return;
    final file = File(pickedFile.path);
    await ref.read(authViewModelProvider.notifier).uploadPhoto(file);
  }

  Widget _buildProfileOptions(BuildContext context, WidgetRef ref, String userRole, String userId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ProfileTile(
            icon: Icons.person_outline,
            title: "Edit Profile",
            onTap: () {
              // TODO: Navigate to Edit Profile
            },
          ),
          ProfileTile(
            icon: Icons.location_on_outlined,
            title: "Delivery Address",
            onTap: () {
              // TODO: Navigate to Address Management
            },
          ),
          
          ProfileTile(
            icon: Icons.receipt_long_outlined,
            title: "My Orders",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyOrderPages(userId: userId, userRole: userRole),
                ),
              );
            },
          ),
          if (userRole == "admin") ...[
            ProfileTile(
              icon: Icons.restaurant_menu,
              title: "My Food Items",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyFoodItemsPage()),
                );
              },
            ),
            ProfileTile(
              icon: Icons.add,
              title: "Report Food Item",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportFoodItemPage()),
                );
              },
            ),
          ],
          ProfileTile(
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () {
              // TODO: Navigate to Settings
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeProvider);
              return ProfileTile(
                icon: themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                title: themeMode == ThemeMode.dark ? "Light Mode" : "Dark Mode",
                onTap: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              );
            },
          ),
          ProfileTile(
            icon: Icons.logout,
            title: "Logout",
            isLogout: true,
            onTap: () async {
               await ref.read(authViewModelProvider.notifier).logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => LoginScreen(
                    hiveService: HiveService(),
              ),
           ),
          (route) => false,
        );
      },
          ),
        ],
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLogout;
  final VoidCallback? onTap;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    this.isLogout = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : theme.iconTheme.color),
        title: Text(title,
            style: theme.textTheme.bodyLarge?.copyWith(color: isLogout ? Colors.red : Colors.black, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
