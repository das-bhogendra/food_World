import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/features/category/domain/entities/category_entity.dart';
import 'package:food_mandu/features/category/domain/repositories/category_repository.dart';
import 'package:food_mandu/features/category/domain/usecases/update_category_usecase.dart';
import 'package:mocktail/mocktail.dart';

// =================== MOCK ===================
class MockCategoryRepository extends Mock implements ICategoryRepository {}

class FakeCategoryEntity extends Fake implements CategoryEntity {}

void main() {
  late MockCategoryRepository mockRepository;
  late UpdateCategoryUsecase usecase;

  setUpAll(() {
    registerFallbackValue(FakeCategoryEntity());
  });

  setUp(() {
    mockRepository = MockCategoryRepository();
    usecase = UpdateCategoryUsecase(categoryRepository: mockRepository);
  });

  final tParams = const UpdateCategoryParams(
    id: 'cat_123',
    name: 'Updated Beverages',
    description: 'Updated description',
  );

  group('UpdateCategoryUsecase', () {
    test('should return true when repository successfully updates category',
        () async {
      // Arrange
      when(() => mockRepository.updateCategory(any()))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.updateCategory(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      final failure = ServerFailure(message: 'Server Error');

      when(() => mockRepository.updateCategory(any()))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, Left(failure));
      verify(() => mockRepository.updateCategory(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
