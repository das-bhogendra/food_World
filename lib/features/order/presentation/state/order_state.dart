import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

/// ================= ORDER STATUS ENUM =================
enum OrderStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  updating,
  updated,
  deleting,
  deleted,
  cancelled, // ✅ Added this
  error
}

/// ================= ORDER STATE =================
class OrderState extends Equatable {
  final OrderStatus status;
  final bool isLoading;
  final bool isFetching;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? errorMessage;
  final List<OrderEntity> orders;
  final OrderEntity? selectedOrder;

  const OrderState({
    required this.status,
    required this.isLoading,
    required this.isFetching,
    required this.isCreating,
    required this.isUpdating,
    required this.isDeleting,
    required this.errorMessage,
    required this.orders,
    required this.selectedOrder,
  });

  /// Initial state
  factory OrderState.initial() => const OrderState(
        status: OrderStatus.initial,
        isLoading: false,
        isFetching: false,
        isCreating: false,
        isUpdating: false,
        isDeleting: false,
        errorMessage: null,
        orders: [],
        selectedOrder: null,
      );

  /// Copy state with modifications
  OrderState copyWith({
    OrderStatus? status,
    bool? isLoading,
    bool? isFetching,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? errorMessage,
    bool clearError = false,
    List<OrderEntity>? orders,
    OrderEntity? selectedOrder,
    bool clearSelectedOrder = false,
  }) {
    return OrderState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isFetching: isFetching ?? this.isFetching,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      orders: orders ?? this.orders,
      selectedOrder: clearSelectedOrder ? null : selectedOrder ?? this.selectedOrder,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isLoading,
        isFetching,
        isCreating,
        isUpdating,
        isDeleting,
        errorMessage,
        orders,
        selectedOrder,
      ];
}
