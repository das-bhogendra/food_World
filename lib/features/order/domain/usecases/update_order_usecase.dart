import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';

import '../../data/repositories/order_repository.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class UpdateOrderParams extends Equatable {
  final String id;
  final String userId;
  final List<FoodItem> foodItems;
  final double totalAmount;
  final String status;          // ✅ status is required now
  final DateTime createdAt;     // required
  final DateTime updatedAt;

  const UpdateOrderParams({
    required this.id,
    required this.userId,
    required this.foodItems,
    required this.totalAmount,
    required this.status,        // ✅ added
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, foodItems, totalAmount, status, createdAt,updatedAt];
}

final updateOrderUsecaseProvider = Provider<UpdateOrderUsecase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return UpdateOrderUsecase(orderRepository: repository);
});

class UpdateOrderUsecase implements UsecaseWithParams<OrderEntity, UpdateOrderParams> {
  final IOrderRepository _orderRepository;

  UpdateOrderUsecase({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository;

  @override
  Future<Either<Failure, OrderEntity>> call(UpdateOrderParams params) {
    final now = DateTime.now();

    final orderEntity = OrderEntity(
      id: params.id,
      userId: params.userId,
      foodItems: params.foodItems,
      totalAmount: params.totalAmount,
      status: params.status,          // ✅ updated
      createdAt: params.createdAt,
      updatedAt: now,
    );

    return _orderRepository.updateOrder(orderEntity);
  }
}
