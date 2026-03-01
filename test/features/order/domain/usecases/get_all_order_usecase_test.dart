import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/features/order/domain/entities/order_entity.dart';
import 'package:food_mandu/features/order/domain/repositories/order_repository.dart';
import 'package:food_mandu/features/order/domain/usecases/get_all_order_usecase.dart';
import 'package:mocktail/mocktail.dart';

// =================== MOCK ===================
class MockOrderRepository extends Mock implements IOrderRepository {}

void main() {
  late MockOrderRepository mockRepository;
  late GetAllOrdersUsecase usecase;

  setUp(() {
    mockRepository = MockOrderRepository();
    usecase = GetAllOrdersUsecase(orderRepository: mockRepository);
  });

  final tOrders = [
    OrderEntity(
      id: 'order_1',
      userId: 'user_123',
      foodItems: const [
        FoodItem(id: '1', name: 'Pizza', price: 12.5, quantity: 1),
      ],
      totalAmount: 12.5,
      status: 'pending',
      createdAt: DateTime.parse('2026-02-27T10:00:00'),
      updatedAt: DateTime.parse('2026-02-27T10:00:00'),
    ),
    OrderEntity(
      id: 'order_2',
      userId: 'user_456',
      foodItems: const [
        FoodItem(id: '2', name: 'Burger', price: 8.0, quantity: 2),
      ],
      totalAmount: 16.0,
      status: 'delivered',
      createdAt: DateTime.parse('2026-02-27T11:00:00'),
      updatedAt: DateTime.parse('2026-02-27T11:10:00'),
    ),
  ];

  group('GetAllOrdersUsecase', () {
    test('should return list of orders when repository call is successful',
        () async {
      // Arrange
      when(() => mockRepository.getAllOrders())
          .thenAnswer((_) async => Right(tOrders));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(tOrders));
      verify(() => mockRepository.getAllOrders()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository call fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server Error');

      when(() => mockRepository.getAllOrders())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.getAllOrders()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
