import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_mandu/theme/theme_extensions.dart';
import 'package:food_mandu/theme/app_colors.dart';
import 'package:food_mandu/core/utils/snackbar_utils.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';

class FoodItemDetailPage extends StatelessWidget {
  final FoodItemEntity foodItem;
  final String category;
  final String location;

  const FoodItemDetailPage({
    super.key,
    required this.foodItem,
    required this.category,
    required this.location,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fast food':
        return Icons.fastfood_rounded;
      case 'beverages':
        return Icons.local_cafe_rounded;
      case 'desserts':
        return Icons.icecream_rounded;
      case 'fruits':
        return Icons.apple_rounded;
      case 'vegetables':
        return Icons.grass_rounded;
      default:
        return Icons.restaurant_menu_rounded;
    }
  }

  // Correct URL handling
  Widget _buildFoodImage() {
    if (foodItem.fullImageUrl == null || foodItem.fullImageUrl!.isEmpty) {
      // No image: placeholder icon
      return Container(
        decoration: BoxDecoration(
          gradient: foodItem.isAvailable
              ? AppColors.foundGradient
              : AppColors.lostGradient,
        ),
        child: Center(
          child: Icon(
            _getCategoryIcon(category),
            size: 80,
            color: Colors.white,
          ),
        ),
      );
    }

    final path = foodItem.fullImageUrl!;
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: foodItem.isAvailable
                  ? AppColors.foundGradient
                  : AppColors.lostGradient,
            ),
            child: Center(
              child: Icon(
                _getCategoryIcon(category),
                size: 80,
                color: Colors.white,
              ),
            ),
          );
        },
      );
    } else {
      // local file
      final file = File(path.replaceFirst('file://', ''));
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            gradient: foodItem.isAvailable
                ? AppColors.foundGradient
                : AppColors.lostGradient,
          ),
          child: Center(
            child: Icon(
              _getCategoryIcon(category),
              size: 80,
              color: Colors.white,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                child: _buildFoodImage(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Category
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    foodItem.name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(26),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _InfoChip(icon: Icons.location_on_rounded, text: location),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Description
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.description_rounded, size: 20, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              foodItem.description ?? 'No description provided.',
                              style: TextStyle(
                                fontSize: 14,
                                color: context.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Added By
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Added by', style: TextStyle(fontSize: 12, color: context.textSecondary)),
                                  const SizedBox(height: 4),
                                  Text(foodItem.addedBy, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimary)),
                                ],
                              ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(26),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.chat_rounded, color: AppColors.primary, size: 22),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: AppColors.primary.withAlpha(26), borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showOrderDialog(context),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: foodItem.isAvailable ? AppColors.foundGradient : AppColors.lostGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.buttonShadow,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(foodItem.isAvailable ? Icons.shopping_cart_rounded : Icons.remove_shopping_cart_rounded, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(foodItem.isAvailable ? 'Order Now' : 'Sold Out', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(foodItem.isAvailable ? 'Order Food Item' : 'Unavailable'),
        content: Text(foodItem.isAvailable ? 'Do you want to order this item?' : 'This food item is currently sold out.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: context.textSecondary))),
          if (foodItem.isAvailable)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                SnackbarUtils.showSuccess(context, 'Order placed successfully!');
              },
              child: Text('Confirm', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: context.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
