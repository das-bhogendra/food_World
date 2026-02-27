import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/features/order/domain/entities/order_entity.dart';
import 'package:food_mandu/features/order/domain/repositories/order_repository.dart';
import 'package:food_mandu/features/order/domain/usecases/update_order_usecase.dart';
import 'package:mocktail/mocktail.dart';

// =================== MOCK ===================
class MockOrderRepository extends Mock implements IOrderRepository {}

void main() {
  late MockOrderRepository mockRepository;
  late UpdateOrderUsecase usecase;

  setUp(() {
    mockRepository = MockOrderRepository();
    usecase = UpdateOrderUsecase(orderRepository: mockRepository);
  });

  final tFoodItems = [
    const FoodItem(
      id: '1',
      name: 'Pizza',
      price: 12.5,
      quantity: 1,
    ),
    const FoodItem(
      id: '2',
      name: 'Burger',
      price: 8.0,
      quantity: 2,
    ),
  ];

  final createdAt = DateTime.parse('2026-02-27T10:00:00');
  final updatedAt = DateTime.parse('2026-02-27T10:05:00');

  final tParams = UpdateOrderParams(
    id: 'order_123',
    userId: 'user_123',
    foodItems: tFoodItems,
    totalAmount: 28.5,
    status: 'completed',
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  group('UpdateOrderUsecase', () {
    test('should return OrderEntity when repository successfully updates order',
        () async {
      // Arrange
      when(() => mockRepository.updateOrder(any()))
          .thenAnswer((invocation) async {
        final OrderEntity passedOrder =
            invocation.positionalArguments.first;

        return Right(passedOrder);
      });

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.updateOrder(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server Error');

      when(() => mockRepository.updateOrder(any()))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.updateOrder(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}