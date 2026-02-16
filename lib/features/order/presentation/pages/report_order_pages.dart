import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/order/domain/entities/order_entity.dart';
import 'package:food_mandu/features/order/presentation/view_model/order_view_model.dart';
import 'order_detail_pages.dart';

class ReportOrderPages extends ConsumerStatefulWidget {
  const ReportOrderPages({super.key});

  @override
  ConsumerState<ReportOrderPages> createState() => _ReportOrderPagesState();
}

class _ReportOrderPagesState extends ConsumerState<ReportOrderPages> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderViewModelProvider.notifier).getAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderViewModelProvider);
    final notifier = ref.read(orderViewModelProvider.notifier);

    final orders = orderState.orders;
    final totalOrders = orders.length;
    final totalRevenue =
        orders.fold<double>(0, (sum, order) => sum + order.totalAmount);
    final averageOrderValue =
        totalOrders == 0 ? 0 : totalRevenue / totalOrders;
    final latestOrders = orders.reversed.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Report"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: orderState.isFetching
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Orders: $totalOrders",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                              "Total Revenue: Rs. ${totalRevenue.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                              "Average Order Value: Rs. ${averageOrderValue.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Latest Orders",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: latestOrders.isEmpty
                        ? const Center(child: Text("No orders available"))
                        : ListView.builder(
                            itemCount: latestOrders.length,
                            itemBuilder: (context, index) {
                              final order = latestOrders[index];
                              return Card(
                                child: ListTile(
                                  title: Text("Order ID: ${order.id}"),
                                  subtitle: Text(
                                      "Total: Rs. ${order.totalAmount.toStringAsFixed(2)}"),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () async {
                                          final updatedOrder =
                                              await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => OrderDetailPages(
                                                orderId: order.id,
                                              ),
                                            ),
                                          );

                                          if (updatedOrder != null) {
                                            await notifier.updateOrder(updatedOrder);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          final confirmed =
                                              await showDialog<bool>(
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
                                                      content:
                                                          Text("Order deleted")));
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
