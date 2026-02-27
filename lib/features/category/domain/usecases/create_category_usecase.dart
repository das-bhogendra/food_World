import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';

import 'package:food_mandu/features/category/presentation/provider/category_provider.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class CreateCategoryParams extends Equatable {
  final String name;
  final String? description;
  final String addedBy;

  const CreateCategoryParams({
    required this.name,
    this.description,
    required this.addedBy,
  });

  @override
  List<Object?> get props => [name, description, addedBy];
}

final createCategoryUsecaseProvider =
    Provider<CreateCategoryUsecase>((ref) {
  final repository = ref.read(categoryRepositoryProvider);
  return CreateCategoryUsecase(categoryRepository: repository);
});

class CreateCategoryUsecase
    implements UsecaseWithParams<bool, CreateCategoryParams> {
  final ICategoryRepository _categoryRepository;

  CreateCategoryUsecase({required ICategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository;

  @override
  Future<Either<Failure, bool>> call(CreateCategoryParams params) {
    final categoryEntity = CategoryEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: params.name,
      description: params.description,
      createdBy: params.addedBy,
      createdAt: DateTime.now(),
    );

    return _categoryRepository.createCategory(categoryEntity);
  }
}
