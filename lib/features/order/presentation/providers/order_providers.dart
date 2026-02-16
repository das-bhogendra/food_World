import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/order/data/repositories/order_repository.dart';
import 'package:food_mandu/features/order/domain/entities/order_entity.dart';

import 'package:food_mandu/features/order/domain/repositories/order_repository.dart';

// ================= Order State =================
class OrderState {
  final bool isFetching;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final List<OrderEntity> orders;
  final OrderEntity? selectedOrder;
  final String? errorMessage;

  const OrderState({
    this.isFetching = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.orders = const [],
    this.selectedOrder,
    this.errorMessage,
  });

  OrderState copyWith({
    bool? isFetching,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    List<OrderEntity>? orders,
    OrderEntity? selectedOrder,
    String? errorMessage,
  }) {
    return OrderState(
      isFetching: isFetching ?? this.isFetching,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ================= Order Notifier =================
class OrderNotifier extends Notifier<OrderState> {
  late final IOrderRepository repository;

  @override
  OrderState build() {
    repository = ref.read(orderRepositoryProvider);
    return const OrderState();
  }

  // ================= CREATE ORDER =================
  Future<void> createOrder({
    required String userId,
    required List<FoodItem> foodItems, // ✅ full objects now
    required double totalAmount,
    required String status,
  }) async {
    state = state.copyWith(isCreating: true);

    final order = OrderEntity(
      id: '', // Will be set by backend
      userId: userId,
      foodItems: foodItems,
      totalAmount: totalAmount,
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await repository.createOrder(order);

    result.fold(
      (failure) => state = state.copyWith(
        isCreating: false,
        errorMessage: failure.message,
      ),
      (createdOrder) => state = state.copyWith(
        isCreating: false,
        orders: [...state.orders, createdOrder],
      ),
    );
  }

  // ================= UPDATE ORDER =================
  Future<void> updateOrder({
    required String id,
    required String userId,
    required List<FoodItem> foodItems, // ✅ full objects
    required double totalAmount,
    required String status,
  }) async {
    state = state.copyWith(isUpdating: true);

    final order = OrderEntity(
      id: id,
      userId: userId,
      foodItems: foodItems,
      totalAmount: totalAmount,
      status: status,
      createdAt: DateTime.now(), // Could keep original if needed
      updatedAt: DateTime.now(),
    );

    final result = await repository.updateOrder(order);

    result.fold(
      (failure) => state = state.copyWith(
        isUpdating: false,
        errorMessage: failure.message,
      ),
      (updatedOrder) {
        final updatedList = state.orders
            .map((o) => o.id == updatedOrder.id ? updatedOrder : o)
            .toList();

        state = state.copyWith(
          isUpdating: false,
          orders: updatedList,
        );
      },
    );
  }

  // ================= DELETE ORDER =================
  Future<void> deleteOrder(String id) async {
    state = state.copyWith(isDeleting: true);

    final result = await repository.deleteOrder(id);

    result.fold(
      (failure) => state = state.copyWith(
        isDeleting: false,
        errorMessage: failure.message,
      ),
      (_) {
        final updatedList = state.orders.where((o) => o.id != id).toList();
        state = state.copyWith(
          isDeleting: false,
          orders: updatedList,
        );
      },
    );
  }

  // ================= FETCH ORDERS =================
  Future<void> fetchOrders(String userId) async {
    state = state.copyWith(isFetching: true, errorMessage: null);

    final result = await repository.getOrdersByUser(userId);

    result.fold(
      (failure) => state = state.copyWith(
        isFetching: false,
        errorMessage: failure.message,
      ),
      (orders) => state = state.copyWith(
        isFetching: false,
        orders: orders,
      ),
    );
  }

  // ================= FETCH ALL ORDERS =================
  Future<void> fetchAllOrders() async {
    state = state.copyWith(isFetching: true, errorMessage: null);

    final result = await repository.getAllOrders();

    result.fold(
      (failure) => state = state.copyWith(
        isFetching: false,
        errorMessage: failure.message,
      ),
      (orders) => state = state.copyWith(
        isFetching: false,
        orders: orders,
      ),
    );
  }

  // ================= FETCH ORDER BY ID =================
  Future<void> fetchOrderById(String id) async {
    state = state.copyWith(isFetching: true, errorMessage: null);

    final result = await repository.getOrderById(id);

    result.fold(
      (failure) => state = state.copyWith(
        isFetching: false,
        errorMessage: failure.message,
      ),
      (order) => state = state.copyWith(
        isFetching: false,
        selectedOrder: order,
      ),
    );
  }

  // ================= CLEAR ERROR =================
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // ================= CLEAR SELECTED ORDER =================
  void clearSelectedOrder() {
    state = state.copyWith(selectedOrder: null);
  }
}

// ================= Riverpod Provider =================
final orderNotifierProvider =
    NotifierProvider<OrderNotifier, OrderState>(OrderNotifier.new);
