import '../models/order_api_model.dart';
import '../models/order_hive_model.dart';

abstract interface class IOrderLocalDatasource {
  Future<bool> createOrder(OrderHiveModel order);
  Future<bool> updateOrder(OrderHiveModel order);
  Future<bool> deleteOrder(String id);

  Future<List<OrderHiveModel>> getAllOrders();
  Future<OrderHiveModel?> getOrderById(String id);
  Future<List<OrderHiveModel>> getOrdersByUser(String userId);
}

abstract interface class IOrderRemoteDatasource {
  Future<OrderApiModel> createOrder(OrderApiModel order);
  Future<OrderApiModel> updateOrder(OrderApiModel order);
  Future<bool> deleteOrder(String id);

  Future<List<OrderApiModel>> getAllOrders();
  Future<OrderApiModel?> getOrderById(String id);
  Future<List<OrderApiModel>> getOrdersByUser(String userId);
}
