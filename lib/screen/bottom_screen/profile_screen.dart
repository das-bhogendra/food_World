import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:food_mandu/features/auth/presentation/providers/auth_provider.dart';

import 'package:food_mandu/core/services/storage/user_session_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(userSessionServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xffFFF7F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, theme, ref, session),
            const SizedBox(height: 20),
            _buildProfileOptions(theme),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    UserSessionService session,
  ) {
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
                  ? const Icon(
                      Icons.camera_alt,
                      size: 35,
                      color: Color(0xffB33B2E),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            session.fullName ?? "User",
            style:
                theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            session.email ?? "",
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= IMAGE SOURCE SHEET =================
  void _showImageSourceSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Upload Profile Photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
        );
      },
    );
  }

  // ================= PICK & UPLOAD =================
  Future<void> _pickAndUploadImage(
    WidgetRef ref,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    await ref
        .read(authViewModelProvider.notifier)
        .uploadPhoto(file);
  }

  // ================= OPTIONS =================
  Widget _buildProfileOptions(ThemeData theme) {
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

// ================= PROFILE TILE =================
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
    final theme = Theme.of(context);

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
          color: isLogout ? Colors.red : theme.iconTheme.color,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
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
