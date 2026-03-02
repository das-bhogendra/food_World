import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/services/storage/user_session_service.dart';
import 'package:food_mandu/features/cart/cart_provider.dart';
import 'package:food_mandu/features/payment/data/repositories/payment_repository.dart';
import 'package:food_mandu/features/payment/domain/repositories/payment_repository.dart';
import 'package:food_mandu/features/payment/presentation/state/payment_state.dart';

final paymentViewModelProvider =
    NotifierProvider<PaymentViewModel, PaymentState>(
  () => PaymentViewModel(),
);

class PaymentViewModel extends Notifier<PaymentState> {
  late final IPaymentRepository _repository;
  late final UserSessionService _userSession;

  @override
  PaymentState build() {
    _repository = ref.read(paymentRepositoryProvider);
    _userSession = ref.read(userSessionServiceProvider);
    return PaymentState.initial();
  }

  String get _userId => _userSession.getCurrentUserId();

  void initPaymentData(List<CartItem> items, double totalAmount) {
    final itemsData = items
        .map((item) => {
              'foodId': item.foodItem.id,
              'name': item.foodItem.name,
              'quantity': item.quantity,
              'price': item.foodItem.price,
              'imageUrl': item.foodItem.imageUrl,
            })
        .toList();

    state = state.copyWith(
      cartItems: itemsData,
      totalAmount: totalAmount,
      status: PaymentStatus.initial,
    );
  }

  Future<bool> processPayment({
    required String paymentMethod,
    String? transactionId,
  }) async {
    state = state.copyWith(status: PaymentStatus.processing);

    final result = await _repository.createPayment(
      userId: _userId,
      items: state.cartItems,
      totalAmount: state.totalAmount,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: failure.message,
        );
        return false;
      },
      (payment) {
        state = state.copyWith(
          status: PaymentStatus.success,
          payment: payment,
        );
        return true;
      },
    );
  }

  Future<bool> updatePaymentStatus({
    required String orderId,
    required String status,
    String? transactionId,
  }) async {
    state = state.copyWith(status: PaymentStatus.processing);

    final result = await _repository.updatePaymentStatus(
      orderId: orderId,
      status: status,
      transactionId: transactionId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: failure.message,
        );
        return false;
      },
      (payment) {
        state = state.copyWith(
          status: PaymentStatus.success,
          payment: payment,
        );
        return true;
      },
    );
  }

  void reset() {
    state = PaymentState.initial();
  }
}
