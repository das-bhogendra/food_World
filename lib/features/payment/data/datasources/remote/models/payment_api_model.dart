import 'package:food_mandu/features/payment/domain/entities/payment_entity.dart';

class PaymentApiModel {
  final String? orderId;
  final double? totalAmount;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? transactionId;
  final DateTime? paidAt;
  final DateTime? createdAt;

  PaymentApiModel({
    this.orderId,
    this.totalAmount,
    this.paymentMethod,
    this.paymentStatus,
    this.transactionId,
    this.paidAt,
    this.createdAt,
  });

  factory PaymentApiModel.fromJson(Map<String, dynamic> json) {
    return PaymentApiModel(
      orderId: json['_id'] ?? json['orderId'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'cash_on_delivery',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      transactionId: json['transactionId'],
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (orderId != null) '_id': orderId,
      if (totalAmount != null) 'totalAmount': totalAmount,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
      if (transactionId != null) 'transactionId': transactionId,
      if (paidAt != null) 'paidAt': paidAt?.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
    };
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      orderId: orderId ?? '',
      amount: totalAmount ?? 0,
      paymentMethod: paymentMethod ?? 'cash_on_delivery',
      paymentStatus: paymentStatus ?? 'pending',
      transactionId: transactionId,
      paidAt: paidAt,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}
