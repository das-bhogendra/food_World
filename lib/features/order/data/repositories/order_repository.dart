import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/services/connectivity/network_info.dart';
import 'package:food_mandu/features/order/data/datasources/order_datasource.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/local/order_localdatasource.dart';
import '../datasources/remote/order_remotedatasource.dart';
import '../models/order_api_model.dart';
import '../models/order_hive_model.dart';

final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  final local = ref.read(orderLocalDatasourceProvider);
  final remote = ref.read(orderRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return OrderRepositoryImpl(
    localDatasource: local,
    remoteDatasource: remote,
    networkInfo: networkInfo,
  );
});

class OrderRepositoryImpl implements IOrderRepository {
  final IOrderLocalDatasource _local;
  final IOrderRemoteDatasource _remote;
  final INetworkInfo _networkInfo;

  OrderRepositoryImpl({
    required IOrderLocalDatasource localDatasource,
    required IOrderRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  })  : _local = localDatasource,
        _remote = remoteDatasource,
        _networkInfo = networkInfo;

  // ================= CREATE ORDER =================
  @override
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order) async {
    try {
      final safeOrder = order.id.isEmpty
          ? OrderEntity(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: order.userId,
              foodItems: order.foodItems,
              totalAmount: order.totalAmount,
              status: order.status,
              createdAt: order.createdAt,
              updatedAt: order.updatedAt,
            )
          : order;

      if (await _networkInfo.isConnected) {
        final apiModel = OrderApiModel.fromEntity(safeOrder);
        final remoteResult = await _remote.createOrder(apiModel);

        // Cache locally
        final hiveModel = OrderHiveModel.fromEntity(remoteResult.toEntity());
        await _local.createOrder(hiveModel);

        return Right(remoteResult.toEntity());
      } else {
        final hiveModel = OrderHiveModel.fromEntity(safeOrder);
        await _local.createOrder(hiveModel);
        return Right(safeOrder);
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // ================= UPDATE ORDER =================
  @override
  Future<Either<Failure, OrderEntity>> updateOrder(OrderEntity order) async {
    try {
      if (order.id.isEmpty) return Left(ApiFailure(message: "Order ID cannot be empty"));

      if (await _networkInfo.isConnected) {
        final apiModel = OrderApiModel.fromEntity(order);
        final remoteResult = await _remote.updateOrder(apiModel);

        final hiveModel = OrderHiveModel.fromEntity(remoteResult.toEntity());
        await _local.updateOrder(hiveModel);

        return Right(remoteResult.toEntity());
      } else {
        final hiveModel = OrderHiveModel.fromEntity(order);
        await _local.updateOrder(hiveModel);
        return Right(order);
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // ================= DELETE ORDER =================
  @override
  Future<Either<Failure, bool>> deleteOrder(String id) async {
    try {
      if (id.isEmpty) return Left(ApiFailure(message: "Order ID cannot be empty"));

      if (await _networkInfo.isConnected) {
        final remoteResult = await _remote.deleteOrder(id);
        if (remoteResult) {
          await _local.deleteOrder(id);
          return const Right(true);
        }
        return Left(ApiFailure(message: "Failed to delete from server"));
      } else {
        final localResult = await _local.deleteOrder(id);
        if (localResult) return const Right(true);
        return Left(LocalDatabaseFailure(message: "Failed to delete locally"));
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // ================= GET ALL ORDERS =================
  @override
  Future<Either<Failure, List<OrderEntity>>> getAllOrders() async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteList = await _remote.getAllOrders();
        for (final apiOrder in remoteList) {
          final hiveModel = OrderHiveModel.fromEntity(apiOrder.toEntity());
          await _local.createOrder(hiveModel);
        }
        return Right(remoteList.map((e) => e.toEntity()).toList());
      } else {
        final localList = await _local.getAllOrders();
        return Right(localList.map((e) => e.toEntity()).toList());
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // ================= GET ORDER BY ID =================
  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String id) async {
    try {
      if (id.isEmpty) return Left(ApiFailure(message: "Order ID cannot be empty"));

      if (await _networkInfo.isConnected) {
        final remoteOrder = await _remote.getOrderById(id);
        if (remoteOrder == null) return Left(ApiFailure(message: "Order not found on server"));

        final hiveModel = OrderHiveModel.fromEntity(remoteOrder.toEntity());
        await _local.createOrder(hiveModel);

        return Right(remoteOrder.toEntity());
      } else {
        final localOrder = await _local.getOrderById(id);
        if (localOrder == null) return Left(LocalDatabaseFailure(message: "Order not found locally"));
        return Right(localOrder.toEntity());
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // ================= GET ORDERS BY USER =================
  @override
  Future<Either<Failure, List<OrderEntity>>> getOrdersByUser(String userId) async {
    try {
      if (userId.isEmpty) return Left(ApiFailure(message: "User ID cannot be empty"));

      if (await _networkInfo.isConnected) {
        final remoteList = await _remote.getOrdersByUser(userId);
        for (final apiOrder in remoteList) {
          final hiveModel = OrderHiveModel.fromEntity(apiOrder.toEntity());
          await _local.createOrder(hiveModel);
        }
        return Right(remoteList.map((e) => e.toEntity()).toList());
      } else {
        final localList = await _local.getOrdersByUser(userId);
        return Right(localList.map((e) => e.toEntity()).toList());
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
