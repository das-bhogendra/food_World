import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/features/category/domain/entities/category_entity.dart';
import 'package:food_mandu/features/category/domain/repositories/category_repository.dart';
import 'package:food_mandu/features/category/domain/usecases/get_all_category_usecase.dart';
import 'package:mocktail/mocktail.dart';

// =================== MOCK ===================
class MockCategoryRepository extends Mock implements ICategoryRepository {}

void main() {
  late MockCategoryRepository mockRepository;
  late GetAllCategoriesUsecase usecase;

  setUp(() {
    mockRepository = MockCategoryRepository();
    usecase = GetAllCategoriesUsecase(categoryRepository: mockRepository);
  });

  final tCategories = [
    CategoryEntity(
      id: 'cat_1',
      name: 'Beverages',
      description: 'Drinks and juices',
      createdBy: 'Admin',
      createdAt: DateTime.parse('2026-02-27T10:00:00'),
    ),
    CategoryEntity(
      id: 'cat_2',
      name: 'Snacks',
      description: 'Fast food and snacks',
      createdBy: 'Admin',
      createdAt: DateTime.parse('2026-02-27T11:00:00'),
    ),
  ];

  group('GetAllCategoriesUsecase', () {
    test('should return list of categories when repository call is successful',
        () async {
      // Arrange
      when(() => mockRepository.getAllCategories())
          .thenAnswer((_) async => Right(tCategories));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(tCategories));
      verify(() => mockRepository.getAllCategories()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository call fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server Error');

      when(() => mockRepository.getAllCategories())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.getAllCategories()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
