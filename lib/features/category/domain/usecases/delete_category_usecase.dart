import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';
import 'package:food_mandu/features/category/presentation/provider/category_provider.dart';
import '../repositories/category_repository.dart';

final deleteCategoryUsecaseProvider =
    Provider<DeleteCategoryUsecase>((ref) {
  final repository = ref.read(categoryRepositoryProvider);
  return DeleteCategoryUsecase(categoryRepository: repository);
});

class DeleteCategoryUsecase implements UsecaseWithParams<bool, String> {
  final ICategoryRepository _categoryRepository;

  DeleteCategoryUsecase({required ICategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository;

  @override
  Future<Either<Failure, bool>> call(String id) {
    return _categoryRepository.deleteCategory(id);
  }
}
