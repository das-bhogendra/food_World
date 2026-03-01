import 'package:equatable/equatable.dart';
import 'package:food_mandu/features/payment/domain/entities/payment_entity.dart';

enum PaymentStatus { initial, loading, processing, success, failure }

class PaymentState extends Equatable {
  final PaymentStatus status;
  final PaymentEntity? payment;
  final String? errorMessage;
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  const PaymentState({
    required this.status,
    this.payment,
    this.errorMessage,
    this.cartItems = const [],
    this.totalAmount = 0,
  });

  factory PaymentState.initial() {
    return const PaymentState(
      status: PaymentStatus.initial,
      payment: null,
      errorMessage: null,
      cartItems: [],
      totalAmount: 0,
    );
  }

  PaymentState copyWith({
    PaymentStatus? status,
    PaymentEntity? payment,
    String? errorMessage,
    List<Map<String, dynamic>>? cartItems,
    double? totalAmount,
  }) {
    return PaymentState(
      status: status ?? this.status,
      payment: payment ?? this.payment,
      errorMessage: errorMessage,
      cartItems: cartItems ?? this.cartItems,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  List<Object?> get props =>
      [status, payment, errorMessage, cartItems, totalAmount];
}
