import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/features/order/domain/entities/order_entity.dart';
import 'package:food_mandu/features/order/domain/repositories/order_repository.dart';
import 'package:food_mandu/features/order/domain/usecases/create_order_usecase.dart';
import 'package:mocktail/mocktail.dart';

// =================== MOCK ===================
class MockOrderRepository extends Mock implements IOrderRepository {}

// =================== FAKE ===================
class FakeOrderEntity extends Fake implements OrderEntity {}

void main() {
  late MockOrderRepository mockRepository;
  late CreateOrderUsecase usecase;

  setUpAll(() {
    registerFallbackValue(FakeOrderEntity());
  });

  setUp(() {
    mockRepository = MockOrderRepository();
    usecase = CreateOrderUsecase(orderRepository: mockRepository);
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

  final tParams = CreateOrderParams(
    userId: 'user_123',
    foodItems: tFoodItems,
    totalAmount: 28.5,
    status: 'pending',
  );

  group('CreateOrderUsecase', () {
    test('should return OrderEntity when repository successfully creates order',
        () async {
      // Arrange
      when(() => mockRepository.createOrder(any()))
          .thenAnswer((invocation) async {
        final OrderEntity passedOrder = invocation.positionalArguments.first;

        return Right(passedOrder);
      });

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result.isRight(), true);

      verify(() => mockRepository.createOrder(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server Error');

      when(() => mockRepository.createOrder(any()))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.createOrder(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
