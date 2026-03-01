import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/api/api_client.dart';
import 'package:food_mandu/core/api/api_endpoints.dart';
import 'package:food_mandu/features/payment/data/datasources/remote/models/payment_api_model.dart';

final paymentRemoteDatasourceProvider =
    Provider<PaymentRemoteDatasource>((ref) {
  return PaymentRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class PaymentRemoteDatasource {
  final ApiClient _apiClient;

  PaymentRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<PaymentApiModel> createPayment({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String paymentMethod,
    String? transactionId,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.orders,
      data: {
        'items': items,
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        if (transactionId != null) 'transactionId': transactionId,
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return PaymentApiModel.fromJson(data);
    }

    throw Exception('Failed to create payment');
  }

  Future<PaymentApiModel> getPaymentStatus(String orderId) async {
    final response = await _apiClient.get('${ApiEndpoints.orders}/$orderId');

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return PaymentApiModel.fromJson(data);
    }

    throw Exception('Failed to get payment status');
  }

  Future<PaymentApiModel> updatePaymentStatus({
    required String orderId,
    required String status,
    String? transactionId,
  }) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.orders}/$orderId/payment',
      data: {
        'status': status,
        if (transactionId != null) 'transactionId': transactionId,
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return PaymentApiModel.fromJson(data);
    }

    throw Exception('Failed to update payment status');
  }
}
