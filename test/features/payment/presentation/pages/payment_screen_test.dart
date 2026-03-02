import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_mandu/features/cart/cart_provider.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/payment/presentation/state/payment_state.dart';
import 'package:food_mandu/features/payment/presentation/view_model/payment_view_model.dart';
import 'package:food_mandu/features/payment/presentation/pages/payment_screen.dart';
import 'package:food_mandu/app/theme/app_colors.dart';

// ================= MOCK CLASSES =================
class MockCartNotifier extends Mock implements CartNotifier {}

class MockPaymentViewModel extends Mock implements PaymentViewModel {}

class MockCartState extends Mock implements CartState {}

class MockPaymentState extends Mock implements PaymentState {}

void main() {
  late MockCartNotifier mockCartNotifier;
  late MockPaymentViewModel mockPaymentNotifier;
  late ProviderContainer container;

  setUp(() {
    mockCartNotifier = MockCartNotifier();
    mockPaymentNotifier = MockPaymentViewModel();

    // Default cart state with items
    final cartState = CartState(
      items: [
        CartItem(
          foodItem: FoodItemEntity(
            id: 'f1',
            name: 'Pizza',
            price: 200.0,
            imageUrl: '',
            type: FoodItemType.veg,
            addedBy: 'user1',
          ),
          quantity: 1,
        ),
      ],
    );
    when(() => mockCartNotifier.state).thenReturn(cartState);
    // total is a getter on CartState, accessed via state
    when(() => mockCartNotifier.clearCart()).thenReturn(null);

    // Default payment state
    when(() => mockPaymentNotifier.state).thenReturn(PaymentState.initial());
    when(() => mockPaymentNotifier.processPayment(
            paymentMethod: any(named: 'paymentMethod')))
        .thenAnswer((_) async => true);
    when(() => mockPaymentNotifier.initPaymentData(any(), any()))
        .thenReturn(null);
    when(() => mockPaymentNotifier.reset()).thenReturn(null);

    container = ProviderContainer(overrides: [
      cartProvider.overrideWith((ref) => mockCartNotifier),
      paymentViewModelProvider.overrideWith(() => mockPaymentNotifier),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  Widget createTestWidget() {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: PaymentScreen(),
      ),
    );
  }

  testWidgets('renders PaymentScreen with order summary', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify title
    expect(find.text('Payment'), findsOneWidget);

    // Verify order summary shows total items and amount
    expect(find.text('1'), findsOneWidget); // total items
    expect(find.textContaining('Rs 200.00'), findsOneWidget);
  });

  testWidgets('can select payment method', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Default selected method is cash_on_delivery
    final codOption = find.text('Cash on Delivery');
    final onlineOption = find.text('Online Payment');

    expect(codOption, findsOneWidget);
    expect(onlineOption, findsOneWidget);

    // Tap online payment
    await tester.tap(onlineOption);
    await tester.pump();

    // selectedPaymentMethod should now be online (we can't directly access private state, but visually it will show selected indicator)
    final selectedIndicator = find.byWidgetPredicate((widget) {
      return widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == AppColors.primary;
    });
    expect(selectedIndicator,
        findsWidgets); // At least one selected indicator is shown
  });

  testWidgets('tapping Pay button calls processPayment', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final payButton = find.textContaining('Pay Rs');
    expect(payButton, findsOneWidget);

    await tester.tap(payButton);
    await tester.pumpAndSettle();

    verify(() => mockPaymentNotifier.processPayment(
        paymentMethod: any(named: 'paymentMethod'))).called(1);
    verify(() => mockCartNotifier.clearCart()).called(1);
    verify(() => mockPaymentNotifier.reset()).called(1);

    // Success dialog should appear
    expect(find.text('Order Placed!'), findsOneWidget);
  });

  testWidgets('shows error message when payment fails', (tester) async {
    // Override to simulate failure
    when(() => mockPaymentNotifier.state).thenReturn(
      PaymentState(
          status: PaymentStatus.failure, errorMessage: 'Payment failed'),
    );

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Payment failed'), findsOneWidget);
  });
}
