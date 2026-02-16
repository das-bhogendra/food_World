import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/features/order/domain/entities/order_entity.dart';
import 'package:food_mandu/features/order/domain/repositories/order_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../state/order_state.dart';

/// ---------------- PROVIDER ----------------
final orderViewModelProvider =
    NotifierProvider<OrderViewModel, OrderState>(() => OrderViewModel());

/// ---------------- VIEW MODEL ----------------
class OrderViewModel extends Notifier<OrderState> {
  late final IOrderRepository _repository;
  String? _currentUserId;

  @override
  OrderState build() {
    _repository = ref.read(orderRepositoryProvider);
    return OrderState.initial();
  }

  /// ---------------- FETCH ALL ORDERS (Admin) ----------------
  Future<void> getAllOrders() async {
    _currentUserId = null;

    state = state.copyWith(
      isLoading: true,
      status: OrderStatus.loading,
      clearError: true,
    );

    final result = await _repository.getAllOrders();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          status: OrderStatus.error,
          errorMessage: failure.message,
        );
      },
      (orders) {
        state = state.copyWith(
          isLoading: false,
          status: OrderStatus.loaded,
          orders: orders,
        );
      },
    );
  }

  /// ---------------- FETCH ORDERS BY USER ----------------
  Future<void> getOrdersByUser(String userId) async {
    _currentUserId = userId;

    state = state.copyWith(
      isFetching: true,
      status: OrderStatus.loading,
      clearError: true,
    );

    final result = await _repository.getOrdersByUser(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isFetching: false,
          status: OrderStatus.error,
          errorMessage: failure.message,
          orders: [],
        );
      },
      (orders) {
        state = state.copyWith(
          isFetching: false,
          status: OrderStatus.loaded,
          orders: orders,
        );
      },
    );
  }

  /// ---------------- CREATE ORDER ----------------
  Future<void> createOrder(OrderEntity order) async {
    state = state.copyWith(
      isCreating: true,
      status: OrderStatus.creating,
      clearError: true,
    );

    final result = await _repository.createOrder(order);

    result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          status: OrderStatus.error,
          errorMessage: failure.message,
        );
      },
      (createdOrder) async {
        state = state.copyWith(
          isCreating: false,
          status: OrderStatus.created,
        );

        // Refresh orders for current user if exists
        if (_currentUserId != null) {
          await getOrdersByUser(_currentUserId!);
        } else {
          await getAllOrders();
        }
      },
    );
  }

  /// ---------------- UPDATE ORDER ----------------
  Future<void> updateOrder(
    OrderEntity order, {
    bool isUserCancel = false,
  }) async {
    state = state.copyWith(
      isUpdating: true,
      status: OrderStatus.updating,
      clearError: true,
    );

    final result = await _repository.updateOrder(order);

    result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          status: OrderStatus.error,
          errorMessage: failure.message,
        );
      },
      (updatedOrder) async {
        state = state.copyWith(
          isUpdating: false,
          status: isUserCancel ? OrderStatus.cancelled : OrderStatus.updated,
        );

        // Refresh orders
        if (_currentUserId != null) {
          await getOrdersByUser(_currentUserId!);
        } else {
          await getAllOrders();
        }
      },
    );
  }

  /// ---------------- DELETE ORDER ----------------
  Future<void> deleteOrder(String id, {required String userRole}) async {
    if (userRole != "admin") {
      state = state.copyWith(
        isDeleting: false,
        status: OrderStatus.error,
        errorMessage: "Unauthorized: Only admin can delete orders",
      );
      return;
    }

    state = state.copyWith(
      isDeleting: true,
      status: OrderStatus.deleting,
      clearError: true,
    );

    final result = await _repository.deleteOrder(id);

    result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          status: OrderStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) async {
        if (!success) {
          state = state.copyWith(
            isDeleting: false,
            status: OrderStatus.error,
            errorMessage: "Failed to delete order",
          );
          return;
        }

        state = state.copyWith(
          isDeleting: false,
          status: OrderStatus.deleted,
        );

        if (_currentUserId != null) {
          await getOrdersByUser(_currentUserId!);
        } else {
          await getAllOrders();
        }
      },
    );
  }

  /// ---------------- FETCH SINGLE ORDER ----------------
  Future<void> getOrderById(String orderId) async {
    state = state.copyWith(
      isFetching: true,
      status: OrderStatus.loading,
      clearError: true,
      clearSelectedOrder: true,
    );

    final result = await _repository.getOrderById(orderId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isFetching: false,
          status: OrderStatus.error,
          errorMessage: failure.message,
        );
      },
      (order) {
        state = state.copyWith(
          isFetching: false,
          status: OrderStatus.loaded,
          selectedOrder: order,
        );
      },
    );
  }
}
