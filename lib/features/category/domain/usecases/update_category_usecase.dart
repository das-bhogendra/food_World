import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';

import 'package:food_mandu/features/category/presentation/provider/category_provider.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class UpdateCategoryParams extends Equatable {
  final String id;
  final String name;
  final String? description;

  const UpdateCategoryParams({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}

final updateCategoryUsecaseProvider =
    Provider<UpdateCategoryUsecase>((ref) {
  final repository = ref.read(categoryRepositoryProvider);
  return UpdateCategoryUsecase(categoryRepository: repository);
});

class UpdateCategoryUsecase
    implements UsecaseWithParams<bool, UpdateCategoryParams> {
  final ICategoryRepository _categoryRepository;

  UpdateCategoryUsecase({required ICategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateCategoryParams params) {
    final categoryEntity = CategoryEntity(
      id: params.id,
      name: params.name,
      description: params.description,
      updatedAt: DateTime.now(),
    );

    return _categoryRepository.updateCategory(categoryEntity);
  }
}
