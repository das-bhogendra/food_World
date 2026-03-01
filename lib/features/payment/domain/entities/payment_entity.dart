class PaymentEntity {
  final String orderId;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final String? transactionId;
  final DateTime? paidAt;
  final DateTime createdAt;

  PaymentEntity({
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.transactionId,
    this.paidAt,
    required this.createdAt,
  });

  bool get isPaid => paymentStatus == 'paid';
  bool get isPending => paymentStatus == 'pending';
  bool get isFailed => paymentStatus == 'failed';
}