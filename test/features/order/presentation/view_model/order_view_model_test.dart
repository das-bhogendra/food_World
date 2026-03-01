import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:food_mandu/features/order/domain/entities/order_entity.dart';
import 'package:food_mandu/features/order/domain/repositories/order_repository.dart';
import 'package:food_mandu/features/order/data/repositories/order_repository.dart';
import 'package:food_mandu/features/order/presentation/view_model/order_view_model.dart';
import 'package:food_mandu/features/order/presentation/state/order_state.dart';
import 'package:food_mandu/core/error/failures.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}

void main() {
  late ProviderContainer container;
  late MockOrderRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(OrderEntity(
      id: '1',
      userId: 'u1',
      foodItems: const [],
      totalAmount: 0,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  });

  setUp(() {
    mockRepository = MockOrderRepository();

    container = ProviderContainer(
      overrides: [
        orderRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final tOrder = OrderEntity(
    id: '1',
    userId: 'u1',
    foodItems: const [],
    totalAmount: 100,
    status: 'pending',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('OrderViewModel - getAllOrders', () {
    test('should load all orders successfully', () async {
      when(() => mockRepository.getAllOrders())
          .thenAnswer((_) async => Right([tOrder]));

      await container.read(orderViewModelProvider.notifier).getAllOrders();

      final state = container.read(orderViewModelProvider);
      expect(state.status, OrderStatus.loaded);
      expect(state.orders.length, 1);
      expect(state.orders.first.id, '1');
      verify(() => mockRepository.getAllOrders()).called(1);
    });

    test('should handle error when loading fails', () async {
      when(() => mockRepository.getAllOrders())
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Failed')));

      await container.read(orderViewModelProvider.notifier).getAllOrders();

      final state = container.read(orderViewModelProvider);
      expect(state.status, OrderStatus.error);
      expect(state.errorMessage, 'Failed');
    });
  });

  group('OrderViewModel - getOrdersByUser', () {
    test('should fetch orders for a user successfully', () async {
      when(() => mockRepository.getOrdersByUser('u1'))
          .thenAnswer((_) async => Right([tOrder]));

      await container
          .read(orderViewModelProvider.notifier)
          .getOrdersByUser('u1');

      final state = container.read(orderViewModelProvider);
      expect(state.status, OrderStatus.loaded);
      expect(state.orders.first.userId, 'u1');
    });

    test('should handle error when fetching user orders fails', () async {
      when(() => mockRepository.getOrdersByUser('u1'))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Error')));

      await container
          .read(orderViewModelProvider.notifier)
          .getOrdersByUser('u1');

      final state = container.read(orderViewModelProvider);
      expect(state.status, OrderStatus.error);
      expect(state.orders, isEmpty);
      expect(state.errorMessage, 'Error');
    });
  });

  group('OrderViewModel - createOrder', () {
    test('should create order successfully', () async {
      when(() => mockRepository.createOrder(tOrder))
          .thenAnswer((_) async => Right(tOrder));
      when(() => mockRepository.getAllOrders())
          .thenAnswer((_) async => Right([tOrder]));

      await container.read(orderViewModelProvider.notifier).createOrder(tOrder);

      final state = container.read(orderViewModelProvider);
      expect(state.status, OrderStatus.created);
      expect(state.orders.length, 1);
    });

    test('should handle error when creation fails', () async {
      when(() => mockRepository.createOrder(tOrder))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Failed')));

      await container.read(orderViewModelProvider.notifier).createOrder(tOrder);

      final state = container.read(orderViewModelProvider);
      expect(state.status, OrderStatus.error);
      expect(state.errorMessage, 'Failed');
    });
  });

  group('OrderViewModel - updateOrder', () {
    final updatedOrder = tOrder.copyWith(status: 'delivered');

    test('should update order successfully', () async {
      when(() => mockRepository.updateOrder(updatedOrder))
          .thenAnswer((_) async => Right(updatedOrder));
      when(() => mockRepository.getAllOrders())
          .thenAnswer((_) async => Right([updatedOrder]));

      await container
          .read(orderViewModelProvider.notifier)
          .updateOrder(updatedOrder);

      final state = container.read(orderViewModelProvider);
      expect(state.status, OrderStatus.updated);
      expect(state.orders.first.status, 'delivered');
    });

    test('should handle error when update fails', () async {
      when(() => mockRepository.updateOrder(updatedOrder))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Fail')));

      await container
          .read(orderViewModelProvider.notifier)
          .updateOrder(updatedOrder);

      final state = container.read(orderViewModelProvider);
      expect(state.status, OrderStatus.error);
      expect(state.errorMessage, 'Fail');
    });
  });

  group('OrderViewModel - deleteOrder', () {
    test('should delete order successfully for admin', () async {
      when(() => mockRepository.deleteOrder('1'))
          .thenAnswer((_) async => Right(true));
      when(() => mockRepository.getAllOrders())
          .thenAnswer((_) async => Right([]));

      await container
          .read(orderViewModelProvider.notifier)
          .deleteOrder('1', userRole: 'admin');

      final state = container.read(orderViewModelProvider);
      expect(state.status, OrderStatus.deleted);
      expect(state.orders, isEmpty);
    });

    test('should fail to delete for non-admin', () async {
      await container
          .read(orderViewModelProvider.notifier)
          .deleteOrder('1', userRole: 'user');

      final state = container.read(orderViewModelProvider);
      expect(state.status, OrderStatus.error);
      expect(state.errorMessage, 'Unauthorized: Only admin can delete orders');
    });

    test('should handle error when deletion fails', () async {
      when(() => mockRepository.deleteOrder('1'))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Fail')));

      await container
          .read(orderViewModelProvider.notifier)
          .deleteOrder('1', userRole: 'admin');

      final state = container.read(orderViewModelProvider);
      expect(state.status, OrderStatus.error);
      expect(state.errorMessage, 'Fail');
    });
  });

  group('OrderViewModel - getOrderById', () {
    test('should fetch single order successfully', () async {
      when(() => mockRepository.getOrderById('1'))
          .thenAnswer((_) async => Right(tOrder));

      await container.read(orderViewModelProvider.notifier).getOrderById('1');

      final state = container.read(orderViewModelProvider);
      expect(state.status, OrderStatus.loaded);
      expect(state.selectedOrder!.id, '1');
    });

    test('should handle error when fetching single order fails', () async {
      when(() => mockRepository.getOrderById('1'))
          .thenAnswer((_) async => const Left(ApiFailure(message: 'Fail')));

      await container.read(orderViewModelProvider.notifier).getOrderById('1');

      final state = container.read(orderViewModelProvider);
      expect(state.status, OrderStatus.error);
      expect(state.errorMessage, 'Fail');
      expect(state.selectedOrder, null);
    });
  });
}
