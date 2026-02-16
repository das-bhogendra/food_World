import 'package:dartz/dartz.dart';
import 'package:food_mandu/core/error/failures.dart';
import '../entities/order_entity.dart';

abstract interface class IOrderRepository {
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order);
  Future<Either<Failure, OrderEntity>> updateOrder(OrderEntity order);
  Future<Either<Failure, bool>> deleteOrder(String id);

  Future<Either<Failure, List<OrderEntity>>> getAllOrders();
  Future<Either<Failure, OrderEntity>> getOrderById(String id);
  Future<Either<Failure, List<OrderEntity>>> getOrdersByUser(String userId);
}
