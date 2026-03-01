import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_mandu/features/order/domain/entities/order_entity.dart';
import 'package:food_mandu/features/order/domain/repositories/order_repository.dart';
import 'package:food_mandu/features/order/data/repositories/order_repository.dart';
import 'package:food_mandu/features/order/data/datasources/remote/order_remotedatasource.dart';
import 'package:food_mandu/features/order/presentation/view_model/order_view_model.dart';
import 'package:food_mandu/features/order/presentation/state/order_state.dart';
import 'package:food_mandu/features/order/presentation/pages/report_order_pages.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/services/storage/user_session_service.dart';
import 'package:food_mandu/core/services/storage/token_service.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}

class MockOrderRemoteDatasource extends Mock implements OrderRemoteDatasource {}

class FakeOrderEntity extends Fake implements OrderEntity {}

class FakeOrderRemoteDatasource extends Fake implements OrderRemoteDatasource {}

void main() {
  late ProviderContainer container;
  late MockOrderRepository mockRepository;
  late MockOrderRemoteDatasource mockRemoteDatasource;
  late SharedPreferences mockSharedPreferences;

  setUpAll(() {
    registerFallbackValue(FakeOrderEntity());
    registerFallbackValue(FakeOrderRemoteDatasource());
  });

  setUp(() async {
    mockRepository = MockOrderRepository();
    mockRemoteDatasource = MockOrderRemoteDatasource();

    // Set up mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    mockSharedPreferences = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        tokenServiceProvider.overrideWith(
          (ref) => TokenService(prefs: mockSharedPreferences),
        ),
        userSessionServiceProvider.overrideWith(
          (ref) => UserSessionService(prefs: mockSharedPreferences),
        ),
        orderRemoteDatasourceProvider.overrideWithValue(mockRemoteDatasource),
        orderRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Widget createTestWidget() {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ReportOrderPages()),
    );
  }

  group('ReportOrderPages Widget Tests', () {
    testWidgets(
        'should display " No orders available\ when orders list is empty',
        (tester) async {
      when(() => mockRepository.getAllOrders())
          .thenAnswer((_) async => const Right([]));
      when(() => mockRepository.updateOrder(any())).thenAnswer((_) async {
        final entity = FakeOrderEntity();
        return Right<Failure, OrderEntity>(entity);
      });
      when(() => mockRepository.deleteOrder(any()))
          .thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No orders available'), findsOneWidget);
      expect(find.text('Total Orders: 0'), findsOneWidget);
      expect(find.text('Total Revenue: Rs. 0.00'), findsOneWidget);
      expect(find.text('Average Order Value: Rs. 0.00'), findsOneWidget);
    });

    testWidgets('should display latest orders when orders are present',
        (tester) async {
      final orders = [
        OrderEntity(
          id: 'order1',
          userId: 'user1',
          foodItems: const [],
          totalAmount: 500,
          status: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        OrderEntity(
          id: 'order2',
          userId: 'user2',
          foodItems: const [],
          totalAmount: 300,
          status: 'delivered',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getAllOrders())
          .thenAnswer((_) async => Right(orders));
      when(() => mockRepository.updateOrder(any()))
          .thenAnswer((_) async => Right(orders.first));
      when(() => mockRepository.deleteOrder(any()))
          .thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Total Orders: 2'), findsOneWidget);
      expect(find.text('Total Revenue: Rs. 800.00'), findsOneWidget);
      expect(find.text('Average Order Value: Rs. 400.00'), findsOneWidget);
      expect(find.text('Order ID: order1'), findsOneWidget);
      expect(find.text('Order ID: order2'), findsOneWidget);

      expect(find.byIcon(Icons.edit), findsWidgets);
      expect(find.byIcon(Icons.delete), findsWidgets);
    });

    testWidgets('should handle error state gracefully', (tester) async {
      when(() => mockRepository.getAllOrders()).thenAnswer((_) async =>
          const Left(ApiFailure(message: 'Failed to load orders')));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
