import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/cart/cart_provider.dart';
import 'package:food_mandu/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:food_mandu/features/order/domain/entities/order_entity.dart';
import 'package:food_mandu/features/order/presentation/view_model/order_view_model.dart';
import 'package:food_mandu/features/payment/presentation/pages/payment_screen.dart';
import 'package:food_mandu/app/theme/app_colors.dart';

class CartScreen extends ConsumerStatefulWidget {
  final String userId;
  const CartScreen({super.key, required this.userId});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);

    final cartItems = cartState.items;
    final subtotal = cartItems.fold<double>(
        0.0, (sum, item) => sum + item.foodItem.price * item.quantity);
    final deliveryFee = cartItems.isEmpty ? 0.0 : 100.0;
    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          "My Cart",
          style: theme.textTheme.titleLarge
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      return CartItemCard(
                        title: cartItem.foodItem.name,
                        price: cartItem.foodItem.price,
                        imageUrl: cartItem.foodItem.imageUrl ?? '', // ✅ fix
                        quantity: cartItem.quantity,
                        onIncrease: () =>
                            cartNotifier.increaseQty(cartItem.foodItem.id),
                        onDecrease: () =>
                            cartNotifier.decreaseQty(cartItem.foodItem.id),
                        onRemove: () =>
                            cartNotifier.removeItem(cartItem.foodItem.id),
                      );
                    },
                  ),
                ),
                _checkoutSection(
                  context,
                  subtotal: subtotal,
                  delivery: deliveryFee,
                  total: total,
                  isLoading: ref.watch(orderViewModelProvider).isCreating,
                  onCheckout: () {
                    if (cartItems.isEmpty) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _checkoutSection(
    BuildContext context, {
    required double subtotal,
    required double delivery,
    required double total,
    required bool isLoading,
    required VoidCallback onCheckout,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          _priceRow(context, "Subtotal", subtotal),
          const SizedBox(height: 8),
          _priceRow(context, "Delivery", delivery),
          const Divider(height: 30),
          _priceRow(context, "Total", total, isBold: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "Checkout",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(BuildContext context, String title, double value,
      {bool isBold = false}) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          "Rs. ${value.toStringAsFixed(2)}",
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
