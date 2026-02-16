import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/order/domain/entities/order_entity.dart';
import 'package:food_mandu/features/order/presentation/view_model/order_view_model.dart';
import 'order_detail_pages.dart';

class MyOrderPages extends ConsumerStatefulWidget {
  final String userId;
  final String userRole; // 'admin' or 'user'

  const MyOrderPages({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  ConsumerState<MyOrderPages> createState() => _MyOrderPagesState();
}

class _MyOrderPagesState extends ConsumerState<MyOrderPages> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(orderViewModelProvider.notifier);
      if (widget.userRole == 'admin') {
        notifier.getAllOrders();
      } else {
        notifier.getOrdersByUser(widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderViewModelProvider);
    final notifier = ref.read(orderViewModelProvider.notifier);

    final isLoading = orderState.isFetching ||
        orderState.isLoading ||
        orderState.isCreating ||
        orderState.isUpdating ||
        orderState.isDeleting;

    final allOrders = orderState.orders;
    final orders = widget.userRole == 'user'
        ? allOrders.where((o) => o.userId == widget.userId).toList()
        : allOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (widget.userRole == 'admin') {
                notifier.getAllOrders();
              } else {
                notifier.getOrdersByUser(widget.userId);
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("No orders found"))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text("Order ID: ${order.id}"),
                        subtitle: Text(
                          "Total: Rs.${order.totalAmount.toStringAsFixed(2)}\nStatus: ${order.status}",
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ADMIN BUTTONS
                            if (widget.userRole == "admin") ...[
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  final updatedOrder =
                                      await Navigator.push<OrderEntity?>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          OrderDetailPages(orderId: order.id),
                                    ),
                                  );
                                  if (updatedOrder != null) {
                                    await notifier.updateOrder(updatedOrder);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Delete Order"),
                                      content: const Text(
                                          "Are you sure you want to delete this order?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text("Cancel")),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text("Delete")),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    await notifier.deleteOrder(order.id,
                                        userRole: "admin");
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text("Order deleted")));
                                    }
                                  }
                                },
                              ),
                            ],

                            // USER CANCEL BUTTON
                            if (widget.userRole == "user" &&
                                order.status == "pending") ...[
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Cancel Order"),
                                      content: const Text(
                                          "Are you sure you want to cancel this order?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text("No")),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text("Yes")),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    await notifier.updateOrder(order,
                                        isUserCancel: true);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text("Order cancelled")));
                                    }
                                  }
                                },
                              ),
                            ],

                            const Icon(Icons.arrow_forward_ios, size: 18),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderDetailPages(orderId: order.id),
                            ),
                          );
                          // Refresh after returning
                          if (widget.userRole == 'admin') {
                            await notifier.getAllOrders();
                          } else {
                            await notifier.getOrdersByUser(widget.userId);
                          }
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: widget.userRole == "admin"
          ? FloatingActionButton(
              onPressed: () async {
                final newOrder = await Navigator.push<OrderEntity?>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderDetailPages(orderId: ""),
                  ),
                );
                if (newOrder != null) {
                  await notifier.createOrder(newOrder);
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
