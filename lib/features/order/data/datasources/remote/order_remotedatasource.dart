import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/api/api_client.dart';
import 'package:food_mandu/core/api/api_endpoints.dart';
import 'package:food_mandu/core/services/storage/token_service.dart';

import '../order_datasource.dart';
import '../../models/order_api_model.dart';

final orderRemoteDatasourceProvider =
    Provider<IOrderRemoteDatasource>((ref) {
  return OrderRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class OrderRemoteDatasource implements IOrderRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  OrderRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  /// Add auth headers
  Options _authOptions(String token) {
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Create order
  @override
  Future<OrderApiModel> createOrder(OrderApiModel order) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) throw Exception("Token is null");

      final response = await _apiClient.post(
        ApiEndpoints.createOrder,
        data: order.toJson(),
        options: _authOptions(token),
      );

      return OrderApiModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception("Failed to create order: $e");
    }
  }

  /// Update order
  @override
  Future<OrderApiModel> updateOrder(OrderApiModel order) async {
    try {
      if (order.id.isEmpty) throw Exception("Order ID cannot be empty");
      final token = await _tokenService.getToken();
      if (token == null) throw Exception("Token is null");

      final response = await _apiClient.put(
        ApiEndpoints.updateOrder(order.id),
        data: order.toJson(),
        options: _authOptions(token),
      );

      return OrderApiModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception("Failed to update order: $e");
    }
  }

  /// Delete order
  @override
  Future<bool> deleteOrder(String id) async {
    try {
      if (id.isEmpty) throw Exception("Order ID cannot be empty");
      final token = await _tokenService.getToken();
      if (token == null) throw Exception("Token is null");

      await _apiClient.delete(
        ApiEndpoints.deleteOrder(id),
        options: _authOptions(token),
      );

      return true;
    } catch (e) {
      throw Exception("Failed to delete order: $e");
    }
  }

  /// Get all orders (admin)
  @override
  Future<List<OrderApiModel>> getAllOrders() async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) throw Exception("Token is null");

      final response = await _apiClient.get(
        ApiEndpoints.getAllOrders,
        options: _authOptions(token),
      );

      final dataList = response.data['data'] as List;
      return dataList.map((e) => OrderApiModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Failed to fetch all orders: $e");
    }
  }

  /// Get single order by ID
  @override
  Future<OrderApiModel?> getOrderById(String id) async {
    try {
      if (id.isEmpty) throw Exception("Order ID cannot be empty");
      final token = await _tokenService.getToken();
      if (token == null) throw Exception("Token is null");

      final response = await _apiClient.get(
        ApiEndpoints.getOrderById(id),
        options: _authOptions(token),
      );

      final data = response.data['data'];
      if (data == null) return null;

      return OrderApiModel.fromJson(data);
    } catch (e) {
      throw Exception("Failed to fetch order by ID: $e");
    }
  }

  /// Get orders by user ID
  @override
  Future<List<OrderApiModel>> getOrdersByUser(String userId) async {
    try {
      if (userId.isEmpty) throw Exception("User ID cannot be empty");
      final token = await _tokenService.getToken();
      if (token == null) throw Exception("Token is null");

      final response = await _apiClient.get(
        ApiEndpoints.getOrdersByUser(userId),
        options: _authOptions(token),
      );

      final dataList = response.data['data'] as List;
      return dataList.map((e) => OrderApiModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Failed to fetch orders by user: $e");
    }
  }
}
