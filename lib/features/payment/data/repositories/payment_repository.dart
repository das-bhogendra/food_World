import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/features/payment/data/datasources/remote/payment_remote_datasource.dart';
import 'package:food_mandu/features/payment/domain/entities/payment_entity.dart';
import 'package:food_mandu/features/payment/domain/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<IPaymentRepository>((ref) {
  return PaymentRepositoryImpl(
    remoteDatasource: ref.read(paymentRemoteDatasourceProvider),
  );
});

class PaymentRepositoryImpl implements IPaymentRepository {
  final PaymentRemoteDatasource remoteDatasource;

  PaymentRepositoryImpl({
    required this.remoteDatasource,
  });

  @override
  Future<Either<Failure, PaymentEntity>> createPayment({
    required String userId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String paymentMethod,
    String? transactionId,
  }) async {
    try {
      final payment = await remoteDatasource.createPayment(
        userId: userId,
        foodItems: items,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
      );
      return Right(payment.toEntity());
    } on DioException catch (e) {
      return Left(
          ApiFailure(message: e.response?.data['message'] ?? 'Payment failed'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> getPaymentByOrder(String orderId) async {
    try {
      final model = await remoteDatasource.getPaymentByOrder(orderId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to get payment status'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> updatePaymentStatus({
    required String orderId,
    required String status,
    String? transactionId,
  }) async {
    try {
      final model = await remoteDatasource.updatePaymentStatus(
        orderId: orderId,
        status: status,
        transactionId: transactionId,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to update payment'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
