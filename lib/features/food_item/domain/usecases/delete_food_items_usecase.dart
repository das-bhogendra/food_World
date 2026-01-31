import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:food_mandu/core/error/failures.dart';
import 'package:food_mandu/core/usecases/app_usecase.dart';
import 'package:food_mandu/features/food_item/data/repositories/food_items_repository.dart';
import 'package:food_mandu/features/food_item/domain/repositories/food_items_repository.dart';

/// ================= PARAMS =================
class DeleteFoodItemParams extends Equatable {
  final String foodItemId;

  const DeleteFoodItemParams({
    required this.foodItemId,
  });

  @override
  List<Object?> get props => [foodItemId];
}

/// ================= PROVIDER =================
final deleteFoodItemUsecaseProvider =
    Provider<DeleteFoodItemUsecase>((ref) {
  final repository = ref.read(foodItemsRepositoryProvider);
  return DeleteFoodItemUsecase(repository: repository);
});

/// ================= USECASE =================
class DeleteFoodItemUsecase
    implements UsecaseWithParams<bool, DeleteFoodItemParams> {
  final IFoodItemsRepository _repository;

  DeleteFoodItemUsecase({required IFoodItemsRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(DeleteFoodItemParams params) {
    return _repository.deleteFoodItem(params.foodItemId);
  }
}
