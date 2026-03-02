import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/api/api_client.dart';
import 'package:food_mandu/core/api/api_endpoints.dart';
import 'package:food_mandu/core/services/storage/token_service.dart';
import 'package:food_mandu/features/payment/data/datasources/remote/models/payment_api_model.dart';

final paymentRemoteDatasourceProvider =
    Provider<PaymentRemoteDatasource>((ref) {
  return PaymentRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class PaymentRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  PaymentRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  Future<Options> _authOptions() async {
    final token = await _tokenService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<PaymentApiModel> createPayment({
    required String userId,
    required List<Map<String, dynamic>> foodItems,
    required double totalAmount,
    required String paymentMethod,
    String? transactionId,
  }) async {
    final options = await _authOptions();

    final response = await _apiClient.post(
      ApiEndpoints.createPayment,
      data: {
        'userId': userId,
        'foodItems': foodItems,
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        if (transactionId != null) 'transactionId': transactionId,
      },
      options: options,
    );

    if (response.data['success'] == true) {
      final data = response.data['payment'] as Map<String, dynamic>;
      return PaymentApiModel.fromJson(data);
    }

    throw Exception('Failed to create payment');
  }

  Future<PaymentApiModel> getPaymentByOrder(String orderId) async {
    final options = await _authOptions();

    final response = await _apiClient.get(
      ApiEndpoints.getPaymentByOrder(orderId),
      options: options,
    );

    if (response.data['success'] == true) {
      final data = response.data['payment'] as Map<String, dynamic>;
      return PaymentApiModel.fromJson(data);
    }

    throw Exception('Failed to get payment');
  }

  Future<PaymentApiModel> updatePaymentStatus({
    required String orderId,
    required String status,
    String? transactionId,
  }) async {
    final options = await _authOptions();

    final response = await _apiClient.put(
      ApiEndpoints.updatePaymentStatus(orderId),
      data: {
        'status': status,
        if (transactionId != null) 'transactionId': transactionId,
      },
      options: options,
    );

    if (response.data['success'] == true) {
      final data = response.data['payment'] as Map<String, dynamic>;
      return PaymentApiModel.fromJson(data);
    }

    throw Exception('Failed to update payment status');
  }
}
