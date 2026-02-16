import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';
import 'package:food_mandu/features/category/presentation/provider/category_provider.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

final getCategoryByIdUsecaseProvider =
    Provider<GetCategoryByIdUsecase>((ref) {
  final repository = ref.read(categoryRepositoryProvider);
  return GetCategoryByIdUsecase(categoryRepository: repository);
});

class GetCategoryByIdUsecase
    implements UsecaseWithParams<CategoryEntity?, String> {
  final ICategoryRepository _categoryRepository;

  GetCategoryByIdUsecase({required ICategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository;

  @override
  Future<Either<Failure, CategoryEntity?>> call(String id) {
    return _categoryRepository.getCategoryById(id);
  }
}
