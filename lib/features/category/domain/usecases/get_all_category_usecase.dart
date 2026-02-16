import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';

import 'package:food_mandu/features/category/presentation/provider/category_provider.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

final getAllCategoriesUsecaseProvider =
    Provider<GetAllCategoriesUsecase>((ref) {
  final repository = ref.read(categoryRepositoryProvider);
  return GetAllCategoriesUsecase(categoryRepository: repository);
});

class GetAllCategoriesUsecase
    implements UsecaseWithoutParams<List<CategoryEntity>> {
  final ICategoryRepository _categoryRepository;

  GetAllCategoriesUsecase({required ICategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository;

  @override
  Future<Either<Failure, List<CategoryEntity>>> call() {
    return _categoryRepository.getAllCategories();
  }
}
