import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/features/order/domain/repositories/order_repository.dart';
import 'package:food_mandu/features/order/domain/usecases/delete_order_usecase.dart';
import 'package:mocktail/mocktail.dart';

// =================== MOCK ===================
class MockOrderRepository extends Mock implements IOrderRepository {}

void main() {
  late MockOrderRepository mockRepository;
  late DeleteOrderUsecase usecase;

  setUp(() {
    mockRepository = MockOrderRepository();
    usecase = DeleteOrderUsecase(orderRepository: mockRepository);
  });

  const tOrderId = 'order_123';
  const tParams = DeleteOrderParams(id: tOrderId);

  group('DeleteOrderUsecase', () {
    test('should return true when repository successfully deletes an order',
        () async {
      // Arrange
      when(() => mockRepository.deleteOrder(tOrderId))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.deleteOrder(tOrderId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server Error');

      when(() => mockRepository.deleteOrder(tOrderId))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.deleteOrder(tOrderId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}