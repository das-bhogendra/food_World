import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/domain/usecases/create_food_items_usecase.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:mocktail/mocktail.dart';

// =================== MOCK ===================
class MockFoodItemsRepository extends Mock implements IFoodItemsRepository {}

void main() {
  late MockFoodItemsRepository mockRepository;
  late CreateFoodItemUsecase usecase;

  setUp(() {
    mockRepository = MockFoodItemsRepository();
    usecase = CreateFoodItemUsecase(foodItemRepository: mockRepository);
  });

  final tParams = CreateFoodItemParams(
    id: 'test_id',
    name: 'Pizza',
    description: 'Delicious cheese pizza',
    type: FoodItemType.veg,
    price: 12.5,
    imageUrl: 'https://example.com/pizza.jpg',
    isAvailable: true,
    addedBy: 'Restaurant A',
  );

  final tEntity = FoodItemEntity(
    id: tParams.id,
    name: tParams.name,
    description: tParams.description,
    type: tParams.type,
    price: tParams.price,
    imageUrl: tParams.imageUrl,
    isAvailable: tParams.isAvailable,
    addedBy: tParams.addedBy,
    isBestSeller: tParams.isBestSeller,
    isDiscounted: tParams.isDiscounted,
  );

  group('CreateFoodItemUsecase', () {
    test('should return true when repository successfully creates a food item',
        () async {
      // Arrange: repository returns Right(true) for the exact entity
      when(() => mockRepository.createFoodItem(tEntity))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.createFoodItem(tEntity)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange: repository returns a ServerFailure
      final failure = ServerFailure(message: 'Server Error');

      when(() => mockRepository.createFoodItem(tEntity))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.createFoodItem(tEntity)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
