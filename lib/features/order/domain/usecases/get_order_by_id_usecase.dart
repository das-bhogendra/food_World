import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';

import '../../data/repositories/order_repository.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrderByIdParams extends Equatable {
  final String id;

  const GetOrderByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}

final getOrderByIdUsecaseProvider = Provider<GetOrderByIdUsecase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return GetOrderByIdUsecase(orderRepository: repository);
});

class GetOrderByIdUsecase
    implements UsecaseWithParams<OrderEntity, GetOrderByIdParams> {
  final IOrderRepository _orderRepository;

  GetOrderByIdUsecase({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository;

  @override
  Future<Either<Failure, OrderEntity>> call(GetOrderByIdParams params) {
    return _orderRepository.getOrderById(params.id);
  }
}
