import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../order_datasource.dart';
import '../../models/order_hive_model.dart';
import 'package:hive/hive.dart';

final orderLocalDatasourceProvider = Provider<IOrderLocalDatasource>((ref) {
  return OrderLocalDatasource();
});

class OrderLocalDatasource implements IOrderLocalDatasource {
  final String _boxName = "orderBox";

  Future<Box<OrderHiveModel>> _openBox() async {
    return Hive.openBox<OrderHiveModel>(_boxName);
  }

  @override
  Future<bool> createOrder(OrderHiveModel order) async {
    final box = await _openBox();
    await box.put(order.id, order);
    return true;
  }

  @override
  Future<bool> updateOrder(OrderHiveModel order) async {
    final box = await _openBox();
    await box.put(order.id, order);
    return true;
  }

  @override
  Future<bool> deleteOrder(String id) async {
    final box = await _openBox();
    await box.delete(id);
    return true;
  }

  @override
  Future<List<OrderHiveModel>> getAllOrders() async {
    final box = await _openBox();
    return box.values.toList();
  }

  @override
  Future<OrderHiveModel?> getOrderById(String id) async {
    final box = await _openBox();
    return box.get(id);
  }

  @override
  Future<List<OrderHiveModel>> getOrdersByUser(String userId) async {
    final box = await _openBox();
    return box.values.where((e) => e.userId == userId).toList();
  }
}
