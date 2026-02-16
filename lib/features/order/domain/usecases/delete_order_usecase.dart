import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';

import '../../data/repositories/order_repository.dart';
import '../repositories/order_repository.dart';

class DeleteOrderParams extends Equatable {
  final String id;

  const DeleteOrderParams({required this.id});

  @override
  List<Object?> get props => [id];
}

final deleteOrderUsecaseProvider = Provider<DeleteOrderUsecase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return DeleteOrderUsecase(orderRepository: repository);
});

class DeleteOrderUsecase implements UsecaseWithParams<bool, DeleteOrderParams> {
  final IOrderRepository _orderRepository;

  DeleteOrderUsecase({required IOrderRepository orderRepository})
      : _orderRepository = orderRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteOrderParams params) {
    return _orderRepository.deleteOrder(params.id);
  }
}
