import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/features/food_item/domain/entities/food_items_entity.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/domain/usecases/get_food_items_by_user_usecase.dart';
import 'package:mocktail/mocktail.dart';

// =================== MOCK ===================
class MockFoodItemsRepository extends Mock implements IFoodItemsRepository {}

void main() {
  late MockFoodItemsRepository mockRepository;
  late GetFoodItemsByUserUsecase usecase;

  setUp(() {
    mockRepository = MockFoodItemsRepository();
    usecase = GetFoodItemsByUserUsecase(repository: mockRepository);
  });

  const tUserId = 'user_123';

  final tParams = const GetFoodItemsByUserParams(userId: tUserId);

  final tFoodItems = [
    const FoodItemEntity(
      id: '1',
      name: 'Pizza',
      description: 'Cheese Pizza',
      type: FoodItemType.veg,
      price: 10.0,
      imageUrl: 'https://example.com/pizza.jpg',
      isAvailable: true,
      addedBy: tUserId,
      isBestSeller: false,
      isDiscounted: false,
    ),
    const FoodItemEntity(
      id: '2',
      name: 'Burger',
      description: 'Chicken Burger',
      type: FoodItemType.nonVeg,
      price: 8.5,
      imageUrl: 'https://example.com/burger.jpg',
      isAvailable: true,
      addedBy: tUserId,
      isBestSeller: true,
      isDiscounted: true,
    ),
  ];

  group('GetFoodItemsByUserUsecase', () {
    test('should return list of food items for given user when successful',
        () async {
      // Arrange
      when(() => mockRepository.getFoodItemsByUser(tUserId))
          .thenAnswer((_) async => Right(tFoodItems));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, Right(tFoodItems));
      verify(() => mockRepository.getFoodItemsByUser(tUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository call fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server Error');

      when(() => mockRepository.getFoodItemsByUser(tUserId))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.getFoodItemsByUser(tUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}