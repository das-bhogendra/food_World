import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_mandu/features/order/domain/entities/order_entity.dart';
import 'package:food_mandu/features/order/presentation/view_model/order_view_model.dart';
import 'package:food_mandu/features/order/presentation/state/order_state.dart';
import 'package:food_mandu/features/order/presentation/pages/order_detail_pages.dart';

void main() {
  group('OrderDetailPages Widget Tests', () {
    testWidgets('displays CircularProgressIndicator when fetching',
        (WidgetTester tester) async {
      // Use a container with the actual provider but set initial state
      final container = ProviderContainer(
        overrides: [
          // Override with a function that returns OrderViewModel with modified state
          orderViewModelProvider.overrideWith(() => _TestOrderViewModel(
                OrderState(
                  status: OrderStatus.loading,
                  isFetching: true,
                  isLoading: true,
                  isCreating: false,
                  isUpdating: false,
                  isDeleting: false,
                  errorMessage: null,
                  selectedOrder: null,
                  orders: [],
                ),
              )),
        ],
      );

      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: OrderDetailPages(orderId: 'order1'),
          ),
        ),
      );

      // Use pump instead of pumpAndSettle to avoid timeout from the async call
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays "Order not found" when selectedOrder is null',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          orderViewModelProvider.overrideWith(() => _TestOrderViewModel(
                OrderState(
                  status: OrderStatus.loaded,
                  isFetching: false,
                  isLoading: false,
                  isCreating: false,
                  isUpdating: false,
                  isDeleting: false,
                  errorMessage: null,
                  selectedOrder: null,
                  orders: [],
                ),
              )),
        ],
      );

      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: OrderDetailPages(orderId: 'order1'),
          ),
        ),
      );

      // Use pump with a duration instead of pumpAndSettle
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Order not found'), findsOneWidget);
    });

    testWidgets('displays order details when order is loaded',
        (WidgetTester tester) async {
      final order = OrderEntity(
        id: 'order1',
        userId: 'user1',
        foodItems: const [],
        totalAmount: 500,
        status: 'pending',
        createdAt: DateTime(2026, 2, 27, 10, 30),
        updatedAt: DateTime(2026, 2, 27, 12, 0),
      );

      final container = ProviderContainer(
        overrides: [
          orderViewModelProvider.overrideWith(() => _TestOrderViewModel(
                OrderState(
                  status: OrderStatus.loaded,
                  isFetching: false,
                  isLoading: false,
                  isCreating: false,
                  isUpdating: false,
                  isDeleting: false,
                  errorMessage: null,
                  selectedOrder: order,
                  orders: [order],
                ),
              )),
        ],
      );

      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: OrderDetailPages(orderId: 'order1'),
          ),
        ),
      );

      // Use pump with a duration instead of pumpAndSettle
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Order ID: order1'), findsOneWidget);
      expect(find.text('User ID: user1'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('Update Order'), findsOneWidget);
    });

    testWidgets('shows snackbar if Update Order pressed with invalid amount',
        (WidgetTester tester) async {
      final order = OrderEntity(
        id: 'order1',
        userId: 'user1',
        foodItems: const [],
        totalAmount: 500,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          orderViewModelProvider.overrideWith(() => _TestOrderViewModel(
                OrderState(
                  status: OrderStatus.loaded,
                  isFetching: false,
                  isLoading: false,
                  isCreating: false,
                  isUpdating: false,
                  isDeleting: false,
                  errorMessage: null,
                  selectedOrder: order,
                  orders: [order],
                ),
              )),
        ],
      );

      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: OrderDetailPages(orderId: 'order1'),
          ),
        ),
      );

      // Use pump with a duration instead of pumpAndSettle
      await tester.pump(const Duration(milliseconds: 100));

      // Clear the text field and try to update
      final textField = find.byType(TextField);
      await tester.enterText(textField, '');
      await tester.tap(find.text('Update Order'));
      await tester.pump();

      expect(find.text('Please select status & valid amount'), findsOneWidget);
    });
  });
}

/// Test helper class that extends OrderViewModel with a pre-set state
/// and overrides getOrderById to prevent repository access
class _TestOrderViewModel extends OrderViewModel {
  _TestOrderViewModel(this._initialState);

  final OrderState _initialState;

  @override
  OrderState build() {
    // Override to skip repository initialization and return our test state
    return _initialState;
  }

  @override
  Future<void> getOrderById(String orderId) async {
    // Do nothing - we don't want to access the repository in tests
    // The state is already set in the constructor
  }

  @override
  Future<void> updateOrder(OrderEntity order,
      {bool isUserCancel = false}) async {
    // Do nothing - we don't want to access the repository in tests
  }
}
