import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';

import '../../data/repositories/order_repository.dart';
import '../entities/order_entity.dart';

import '../repositories/order_repository.dart';

/// ================= CREATE ORDER PARAMS =================
class CreateOrderParams extends Equatable {
  final String userId;
  final List<FoodItem> foodItems; // ✅ Pass full objects now
  final double totalAmount;
  final String status; // e.g., "pending", "confirmed", "delivered", "cancelled"

  const CreateOrderParams({
    required this.userId,
    required this.foodItems,
    required this.totalAmount,
    required this.status,
  });

  @override
  List<Object?> get props => [userId, foodItems, totalAmount, status];
}

/// ================= CREATE ORDER USECASE PROVIDER =================
final createOrderUsecaseProvider = Provider<CreateOrderUsecase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return CreateOrderUsecase(orderRepository: repository);
});

/// ================= CREATE ORDER USECASE =================
class CreateOrderUsecase
    implements UsecaseWithParams<OrderEntity, CreateOrderParams> {
  final IOrderRepository _orderRepository;

  CreateOrderUsecase({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository;

  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) {
    final now = DateTime.now();

    // ✅ Construct OrderEntity with full FoodItem objects
    final orderEntity = OrderEntity(
      id: now.millisecondsSinceEpoch.toString(),
      userId: params.userId,
      foodItems: params.foodItems,
      totalAmount: params.totalAmount,
      status: params.status,
      createdAt: now,
      updatedAt: now,
    );

    return _orderRepository.createOrder(orderEntity);
  }
}
