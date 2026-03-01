import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/domain/usecases/update_food_items_usecase.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:mocktail/mocktail.dart';

// =================== MOCK ===================
class MockFoodItemsRepository extends Mock implements IFoodItemsRepository {}

void main() {
  late MockFoodItemsRepository mockRepository;
  late UpdateFoodItemUsecase usecase;

  setUp(() {
    mockRepository = MockFoodItemsRepository();
    usecase = UpdateFoodItemUsecase(foodItemRepository: mockRepository);
  });

  final tParams = UpdateFoodItemParams(
    id: 'test_id',
    name: 'Updated Pizza',
    description: 'Updated delicious cheese pizza',
    type: FoodItemType.veg,
    price: 15.0,
    imageUrl: 'https://example.com/pizza_updated.jpg',
    isAvailable: true,
    addedBy: 'Restaurant A',
    isBestSeller: true,
    isDiscounted: false,
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

  group('UpdateFoodItemUsecase', () {
    test('should return true when repository successfully updates a food item',
        () async {
      // Arrange
      when(() => mockRepository.updateFoodItem(tEntity))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.updateFoodItem(tEntity)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server Error');

      when(() => mockRepository.updateFoodItem(tEntity))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.updateFoodItem(tEntity)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}