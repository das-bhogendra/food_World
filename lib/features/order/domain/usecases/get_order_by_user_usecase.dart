import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';

import '../../data/repositories/order_repository.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersByUserParams extends Equatable {
  final String userId;

  const GetOrdersByUserParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final getOrdersByUserUsecaseProvider = Provider<GetOrdersByUserUsecase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return GetOrdersByUserUsecase(orderRepository: repository);
});

class GetOrdersByUserUsecase
    implements UsecaseWithParams<List<OrderEntity>, GetOrdersByUserParams> {
  final IOrderRepository _orderRepository;

  GetOrdersByUserUsecase({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository;

  @override
  Future<Either<Failure, List<OrderEntity>>> call(GetOrdersByUserParams params) {
    return _orderRepository.getOrdersByUser(params.userId);
  }
}
