import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_mandu/features/order/domain/entities/order_entity.dart';
import 'package:food_mandu/features/order/presentation/view_model/order_view_model.dart';
import 'package:food_mandu/features/order/presentation/state/order_state.dart';
import 'package:food_mandu/features/order/presentation/pages/my_order_pages.dart';

void main() {
  group('MyOrderPages Widget Tests', () {
    testWidgets('should display CircularProgressIndicator when loading',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          orderViewModelProvider.overrideWith(() => _TestOrderViewModel(
                OrderState(
                  status: OrderStatus.loading,
                  isFetching: true,
                  isLoading: true,
                  isCreating: false,
                  isUpdating: false,
                  isDeleting: false,
                  errorMessage: null,
                  orders: [],
                  selectedOrder: null,
                ),
              )),
        ],
      );

      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: MyOrderPages(userId: '1', userRole: 'user'),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display "No orders found" when orders list is empty',
        (tester) async {
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
                  orders: [],
                  selectedOrder: null,
                ),
              )),
        ],
      );

      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: MyOrderPages(userId: '1', userRole: 'user'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No orders found'), findsOneWidget);
    });

    testWidgets('should display list of orders for user', (tester) async {
      final orders = [
        OrderEntity(
          id: 'order1',
          userId: '1',
          foodItems: const [],
          totalAmount: 500,
          status: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        OrderEntity(
          id: 'order2',
          userId: '1',
          foodItems: const [],
          totalAmount: 300,
          status: 'delivered',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

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
                  orders: orders,
                  selectedOrder: null,
                ),
              )),
        ],
      );

      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: MyOrderPages(userId: '1', userRole: 'user'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Should display order cards
      expect(find.text('Order ID: order1'), findsOneWidget);
      expect(find.text('Order ID: order2'), findsOneWidget);
    });

    testWidgets('should display admin actions when userRole is admin',
        (tester) async {
      final orders = [
        OrderEntity(
          id: 'order1',
          userId: '1',
          foodItems: const [],
          totalAmount: 500,
          status: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

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
                  orders: orders,
                  selectedOrder: null,
                ),
              )),
        ],
      );

      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: MyOrderPages(userId: '1', userRole: 'admin'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Admin buttons should be visible
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget); // Floating button
    });
  });
}

/// Test helper class that extends OrderViewModel with a pre-set state
/// and overrides methods to prevent repository access
class _TestOrderViewModel extends OrderViewModel {
  _TestOrderViewModel(this._initialState);

  final OrderState _initialState;

  @override
  OrderState build() {
    // Override to skip repository initialization and return our test state
    return _initialState;
  }

  @override
  Future<void> getAllOrders() async {
    // Do nothing - we don't want to access the repository in tests
    // The state is already set in the constructor
  }

  @override
  Future<void> getOrdersByUser(String userId) async {
    // Do nothing - we don't want to access the repository in tests
  }

  @override
  Future<void> createOrder(OrderEntity order) async {
    // Do nothing - we don't want to access the repository in tests
  }

  @override
  Future<void> updateOrder(OrderEntity order,
      {bool isUserCancel = false}) async {
    // Do nothing - we don't want to access the repository in tests
  }

  @override
  Future<void> deleteOrder(String id, {required String userRole}) async {
    // Do nothing - we don't want to access the repository in tests
  }
}
