import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/order/domain/entities/order_entity.dart';
import 'package:food_mandu/features/order/presentation/view_model/order_view_model.dart';

class OrderDetailPages extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailPages({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailPages> createState() => _OrderDetailPagesState();
}

class _OrderDetailPagesState extends ConsumerState<OrderDetailPages> {
  final TextEditingController _totalAmountController = TextEditingController();

  bool _isInitialized = false;

  /// Dropdown selected status
  String? _selectedStatus;

  String formatDateTime(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year} "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.orderId.isNotEmpty) {
        ref.read(orderViewModelProvider.notifier).getOrderById(widget.orderId);
      }
    });
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderViewModelProvider);
    final notifier = ref.read(orderViewModelProvider.notifier);
    final order = orderState.selectedOrder;

    /// Initialize once when order is loaded
    if (!_isInitialized && order != null) {
      _totalAmountController.text = order.totalAmount.toString();

      _selectedStatus = OrderStatusConstants.normalizeStatus(order.status);

      /// If backend sends unknown status, fallback
      if (!OrderStatusConstants.isValidStatus(_selectedStatus!)) {
        _selectedStatus = OrderStatusConstants.pending;
      }

      _isInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: orderState.isFetching
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text("Order not found"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order ID: ${order.id}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text("User ID: ${order.userId}"),
                      const SizedBox(height: 12),

                      /// Total Amount
                      TextField(
                        controller: _totalAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Total Amount",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// STATUS DROPDOWN (Fix)
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: "Status",
                          border: OutlineInputBorder(),
                        ),
                        items: OrderStatusConstants.validStatuses
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),

                      const SizedBox(height: 12),
                      Text("Created At: ${formatDateTime(order.createdAt)}"),
                      const SizedBox(height: 6),
                      Text("Updated At: ${formatDateTime(order.updatedAt)}"),
                      const SizedBox(height: 16),

                      const Text(
                        "Food Items:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      /// Food items list
                      Expanded(
                        child: ListView.builder(
                          itemCount: order.foodItems.length,
                          itemBuilder: (context, index) {
                            final food = order.foodItems[index];

                            final imageUrl = (food.imageUrl == null ||
                                    food.imageUrl!.isEmpty)
                                ? 'https://via.placeholder.com/150'
                                : (food.imageUrl!.startsWith('http')
                                    ? food.imageUrl!
                                    : 'http://10.0.2.2:5005/public/food_photos/${food.imageUrl}');

                            return ListTile(
                              leading: Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/placeholder_food.jpg',
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                              title: Text(food.name),
                              subtitle:
                                  Text("Rs.${food.price.toStringAsFixed(2)}"),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// Update Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text("Update Order"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            final newTotalAmount = double.tryParse(
                              _totalAmountController.text.trim(),
                            );

                            if (_selectedStatus == null ||
                                newTotalAmount == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Please select status & valid amount"),
                                ),
                              );
                              return;
                            }

                            final normalizedStatus =
                                OrderStatusConstants.normalizeStatus(
                                    _selectedStatus!);

                            if (!OrderStatusConstants.isValidStatus(
                                normalizedStatus)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Invalid status. Valid values are: ${OrderStatusConstants.validStatuses.join(', ')}",
                                  ),
                                ),
                              );
                              return;
                            }

                            final updatedOrder = order.copyWith(
                              status: normalizedStatus,
                              totalAmount: newTotalAmount,
                              updatedAt: DateTime.now(),
                            );

                            await notifier.updateOrder(updatedOrder);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Order updated successfully ✅"),
                                ),
                              );
                              Navigator.pop(context, updatedOrder);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
