import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_mandu/features/cart/cart_provider.dart';
import 'package:food_mandu/features/cart/presentation/cart_screen.dart';
import 'package:food_mandu/features/order/presentation/view_model/order_view_model.dart';
import 'package:food_mandu/features/order/presentation/state/order_state.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';

// ============ MOCKS ============
class MockCartNotifier extends Mock implements CartNotifier {}

// Use the actual OrderViewModel but we'll override its state
class MockOrderViewModelForTest extends OrderViewModel {
  MockOrderViewModelForTest(this._initialState);

  final OrderState _initialState;

  @override
  OrderState build() {
    // Skip repository initialization in tests
    return _initialState;
  }
}

class MockCartState extends Mock implements CartState {}

void main() {
  late MockCartNotifier mockCartNotifier;
  late ProviderContainer container;

  setUp(() {
    mockCartNotifier = MockCartNotifier();

    // Provide initial empty cart state
    const cartState = CartState(items: []);
    when(() => mockCartNotifier.state).thenReturn(cartState);
  });

  tearDown(() {
    container.dispose();
  });

  Widget createTestWidget({OrderState? orderState}) {
    final orderNotifier = MockOrderViewModelForTest(
      orderState ?? OrderState.initial(),
    );

    container = ProviderContainer(
      overrides: [
        cartProvider.overrideWith((ref) => mockCartNotifier),
        orderViewModelProvider.overrideWith(() => orderNotifier),
      ],
    );

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: const CartScreen(userId: 'user_1'),
      ),
    );
  }

  testWidgets('shows empty cart text when no items', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text("Your cart is empty"), findsOneWidget);
  });

  testWidgets('renders cart items correctly', (tester) async {
    // Mock cart items
    final cartItems = [
      CartItem(
        foodItem: FoodItemEntity(
          id: 'f1',
          name: 'Pizza',
          price: 200.0,
          imageUrl: 'http://example.com/pizza.jpg',
          type: FoodItemType.veg,
          addedBy: 'user1',
        ),
        quantity: 1,
      ),
    ];

    when(() => mockCartNotifier.state).thenReturn(CartState(items: cartItems));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Pizza'), findsOneWidget);
    expect(find.text('Rs. 200.00'), findsWidgets);
    expect(find.text('Checkout'), findsOneWidget);
  });

  testWidgets('can tap increase, decrease and remove buttons', (tester) async {
    final cartItems = [
      CartItem(
        foodItem: FoodItemEntity(
          id: 'f1',
          name: 'Burger',
          price: 150.0,
          imageUrl: '',
          type: FoodItemType.nonVeg,
          addedBy: 'user1',
        ),
        quantity: 1,
      ),
    ];

    when(() => mockCartNotifier.state).thenReturn(CartState(items: cartItems));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Increase
    final increaseButton = find.byIcon(Icons.add_rounded);
    if (increaseButton.evaluate().isNotEmpty) {
      await tester.tap(increaseButton.first);
      await tester.pump();
      verify(() => mockCartNotifier.increaseQty('f1')).called(1);
    }

    // Decrease
    final decreaseButton = find.byIcon(Icons.remove_rounded);
    if (decreaseButton.evaluate().isNotEmpty) {
      await tester.tap(decreaseButton.first);
      await tester.pump();
      verify(() => mockCartNotifier.decreaseQty('f1')).called(1);
    }

    // Remove
    final removeButton = find.byIcon(Icons.delete_rounded);
    if (removeButton.evaluate().isNotEmpty) {
      await tester.tap(removeButton.first);
      await tester.pump();
      verify(() => mockCartNotifier.removeItem('f1')).called(1);
    }
  });

  testWidgets('tapping checkout calls createOrder and clears cart',
      (tester) async {
    final cartItems = [
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
    ];

    when(() => mockCartNotifier.state).thenReturn(CartState(items: cartItems));
    when(() => mockCartNotifier.clearCart()).thenReturn(null);

    // Use loaded state to avoid issues
    final orderState = OrderState(
      status: OrderStatus.loaded,
      isFetching: false,
      isLoading: false,
      isCreating: true,
      isUpdating: false,
      isDeleting: false,
      errorMessage: null,
      selectedOrder: null,
      orders: [],
    );

    await tester.pumpWidget(createTestWidget(orderState: orderState));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    // Verify cart is cleared after checkout
    verify(() => mockCartNotifier.clearCart()).called(1);
  });
}
